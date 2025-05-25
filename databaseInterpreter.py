import sqlite3
from typing import List, Tuple, Optional, Dict, Callable
from PySide6.QtCore import QObject, Signal, Slot
from notificationHandler import NotificationSubType
from enum import Enum
from user import User
import re

class DatabaseInterpreter(QObject):
    commandExecuted = Signal(str, str)  # command, result


    def __init__(self, db_handler, notification_handler, current_user_id=-1, parent=None):
        super().__init__(parent)
        self.db = db_handler
        self.notification = notification_handler
        self._current_user_id = current_user_id
        self._current_user = User()
        self._table_permissions = {}
        self._last_result = None
        self._last_columns = None

        self._admin_only_operations = [
        'create table', 'create index', 'insert into',
        'update ', 'delete from', 'transaction',
        'rollback', 'savepoint'
        ]

        # Command to handler mapping
        self.command_handlers: Dict[str, Callable[[str], str]] = {
            # 'create': self._handle_create,
            'insert': self._handle_insert,
            'display': self._handle_display,
            'update': self._handle_update,
            'delete': self._handle_delete,
            'sql': self._handle_raw_sql,
            'help': self._handle_help
        }

        self._initialize_table_permissions()

    def get_last_result(self) -> Tuple[Optional[List[Tuple]], Optional[List[str]]]:
        """Get the last query result that can be exported"""
        return self._last_result, self._last_columns

    def export_last_result_to_csv(self, file_path: str) -> bool:
        """
        Export the last query result to CSV file
        Returns True if successful, False otherwise
        """
        if not self._last_result or not self._last_columns:
            return False

        try:
            import csv
            with open(file_path, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(self._last_columns)
                writer.writerows(self._last_result)
            return True
        except Exception as e:
            self.notification.showError(
                "Export Error",
                f"Failed to export to CSV: {str(e)}",
                NotificationSubType.SYSTEM.value
            )
            return False

    def _initialize_table_permissions(self):
           """Cache which tables have audit columns at startup"""
           cursor = self.db.conn.cursor()
           cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")

           for (table_name,) in cursor.fetchall():
               cursor.execute(f"PRAGMA table_info({table_name})")
               columns = [col[1] for col in cursor.fetchall()]
               self._table_permissions[table_name] = {
                   'has_created_by': 'created_by' in columns,
                   'has_updated_by': 'updated_by' in columns,
               }


    def _check_table_permission(self, table_name: str) -> bool:
        """Check if current user has permission to access this table"""
        if self.isUserAdmin(self._current_user):  # Admin bypass
            return True

        if table_name in ('species', 'units'):
            return True

        table_info = self._table_permissions.get(table_name)
        if not table_info:
            print(f"Table '{table_name}' does not exist")
            return False

        if not table_info['has_created_by']:
            return True

        return True


    @Slot(str)
    def execute_command(self, command_text: str) -> None:
        """Parse and execute a database command.

        Args:
            command_text: The command string to execute

        Emits:
            commandExecuted signal with the command and result
        """
        parts = command_text.strip().split(maxsplit=1)
        if not parts:
            result = "Error: Empty command"
            self.commandExecuted.emit(command_text, result)
            return

        cmd = parts[0].lower()
        args = parts[1] if len(parts) > 1 else ""

        if cmd not in self.command_handlers:
            available = ', '.join(self.command_handlers.keys())
            result = f"Error: Unknown command '{cmd}'. Available commands: {available}"
            self.commandExecuted.emit(command_text, result)
            return

        try:
            result = self.command_handlers[cmd](args)
            self.commandExecuted.emit(command_text, result)
        except Exception as e:
            error_msg = f"Error executing command: {str(e)}"
            self.notification.showError(
                "Command Error",
                error_msg,
                "database"
            )
            self.commandExecuted.emit(command_text, error_msg)


    def _execute_sql(self, sql: str, params: tuple = (),
    table_name: str = None, action_type: str = None) ->  Tuple[Optional[List[Tuple]], Optional[List[str]], int]:
       """Execute SQL and return (rows, columns) or (None, None) on error"""
       try:
           cursor = self.db.conn.cursor()
           action_type = sql.strip().split()[0].upper()
           table_name = table_name if not None else self._extract_table_name(sql)

           cursor = self.db.execute(
                      sql,
                      params,
                      table_name=table_name,
                      action_type=action_type,
                      user_id=self._current_user_id
                  )

           rowcount = cursor.rowcount

           if sql.strip().lower().startswith('select'):
               rows = cursor.fetchall()
               columns = [desc[0] for desc in cursor.description]
               self._last_result = rows
               self._last_columns = columns
               return rows, columns, rowcount

           # Clear last result for non-select queries
           self._last_result = None
           self._last_columns = None
           return None, None, rowcount
       except sqlite3.Error as e:
           self._last_result = None
           self._last_columns = None
           raise Exception(f"SQL Error: {str(e)}")


    def set_current_user(self, user_id: int):
        """Update the current user ID for permission checks"""
        self._current_user_id = user_id

    def _extract_table_name(self, sql: str) -> str:
        """Helper to extract table name from SQL"""
        sql_lower = sql.lower()
        if sql_lower.startswith('insert into', 'select from'):
            return sql.split()[2]
        elif sql_lower.startswith(('update ', 'delete from ')):
            return sql.split()[1]
        return None

    # def _check_table_permission(self, table_name: str) -> bool:
    #     """Check if table has created_by column and user has permission"""
    #     if self._current_user_id == 1:  # Admin bypass
    #         return True

    #     try:
    #         cursor = self.db.conn.cursor()
    #         cursor.execute(f"PRAGMA table_info({table_name})")
    #         columns = cursor.fetchall()
    #         has_created_by = any(col[1] == 'created_by' for col in columns)

    #         if not has_created_by:
    #             return False

    #         # Verify at least one record belongs to user
    #         cursor.execute(f"SELECT 1 FROM {table_name} WHERE created_by = ? LIMIT 1",
    #                       (self._current_user_id,))
    #         return cursor.fetchone() is not None

    #     except sqlite3.Error:
    #         return False


    def _handle_create(self, args: str) -> str:
        """Handle table creation command without trigger creation.
        Format: create table_name column1:type1 column2:type2 ...
        """
        if not args:
            self.notification.showError(
                "Create Error",
                "Missing table name and columns for create command",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            parts = args.split()
            if len(parts) < 2:
                self.notification.showError(
                    "Syntax Error",
                    "Need at least one column definition",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            table_name = parts[0]
            if not table_name.replace('_', '').isalnum():
                self.notification.showError(
                    "Invalid Name",
                    "Table name can only contain letters, numbers and underscores",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            # Convert user columns (col:type) to SQL
            user_columns = [col.replace(':', ' ') for col in parts[1:]]

            # Add standard audit columns
            standard_columns = [
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP",
                f"created_by INTEGER NOT NULL DEFAULT {self._current_user_id}",
                "updated_at TIMESTAMP",
                f"updated_by INTEGER DEFAULT {self._current_user_id}"
            ]

            # Combine all columns
            all_columns = user_columns + standard_columns
            columns_sql = ', '.join(all_columns)

            sql = f"CREATE TABLE IF NOT EXISTS {table_name} ({columns_sql})"
            self._execute_sql(sql, table_name = table_name)

            self.notification.showSuccess(
                "Record Created",
                f"Record for '{table_name}' created successfully",
                NotificationSubType.DATABASE.value
            )
            return f"Table '{table_name}' created with columns: {', '.join(user_columns)}"

        except Exception as e:
            error_msg = f"Failed to create table: {str(e)}"
            self.notification.showError(
                "Creation Error",
                error_msg,
                NotificationSubType.DATABASE.value
            )
            return ""



    def _handle_insert(self, args: str) -> str:
        """Handle record insertion command.
        Format: insert table_name column1=value1 column2=value2 ...
        """
        if not args:
            self.notification.showError(
                "Insert Error",
                "Missing table name and values for insert command",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            # Split into table name and key-value pairs
            parts = args.split(maxsplit=1)
            if len(parts) < 2:
                self.notification.showError(
                    "Syntax Error",
                    "Need at least one column value pair",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            table_name = parts[0]
            if not self._check_table_permission(table_name):
                return ""

            # Parse key-value pairs
            kv_pairs = []
            remaining = parts[1]
            while remaining:
                match = re.match(r'(\w+)=("[^"]*"|\'[^\']*\'|\S+)', remaining)
                if not match:
                    break
                key = match.group(1)
                value = match.group(2)
                # Remove quotes if present
                if (value.startswith('"') and value.endswith('"')) or \
                   (value.startswith("'") and value.endswith("'")):
                    value = value[1:-1]
                kv_pairs.append((key, value))
                remaining = remaining[match.end():].strip()

            if not kv_pairs:
                self.notification.showError(
                    "Syntax Error",
                    "Invalid key-value pairs format",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            # Build SQL
            columns = []
            values = []
            params = []
            for key, value in kv_pairs:
                columns.append(key)
                values.append('?')
                params.append(value)

            # Add audit fields if table has them
            table_info = self._table_permissions.get(table_name, {})
            if table_info.get('has_created_by'):
                columns.append('created_by')
                values.append('?')
                params.append(self._current_user_id)

            columns_sql = ', '.join(columns)
            values_sql = ', '.join(values)

            sql = f"INSERT INTO {table_name} ({columns_sql}) VALUES ({values_sql})"
            self._execute_sql(sql, tuple(params), table_name = table_name)

            self.notification.showSuccess(
                "Record Created",
                f"Record inserted into '{table_name}' successfully",
                NotificationSubType.DATABASE.value
            )
            return f"Inserted 1 row into '{table_name}'"

        except Exception as e:
            error_msg = f"Failed to insert record: {str(e)}"
            self.notification.showError(
                "Insert Error",
                error_msg,
                NotificationSubType.DATABASE.value
            )
            return ""


    def _handle_display(self, args: str) -> str:
        """Handle data display command with proper notifications."""
        if not args:
            self.notification.showError(
                "Display Command Error",
                "Missing table name for display command",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            parts = args.split(' where ', maxsplit=1)
            table_name = parts[0].strip()

            if not self._check_table_permission(table_name):
                self.notification.showError(
                    "Permission Denied",
                    f"No permission to access table '{table_name}' or table doesn't exist",
                    NotificationSubType.DATABASE.value
                )
                return ""

            # Check if table has created_by column and is not species or units
            table_info = self._table_permissions.get(table_name, {})
            has_created_by = table_info.get('has_created_by', False)

            # Base query differs based on user role and table
            if self.isUserAdmin(self._current_user) or table_name in ('species', 'units'):
                base_query = f"SELECT * FROM {table_name}"
                access_type = "All records"
            elif has_created_by:
                base_query = f"SELECT * FROM {table_name} WHERE created_by = {self._current_user_id}"
                access_type = "Your records"
            else:
                base_query = f"SELECT * FROM {table_name}"
                access_type = "All records"

            # Handle WHERE clause if present
            if len(parts) == 1:
                sql = base_query
            else:
                condition = parts[1].strip()
                if self.isUserAdmin(self._current_user) or table_name in ('species', 'units') or not has_created_by:
                    sql = f"{base_query} WHERE {condition}"
                else:
                    sql = f"{base_query} AND ({condition})"

            rows, columns, rowCount = self._execute_sql(sql, table_name=table_name)

            if not rows:
                self.notification.showInfo(
                    "No Results",
                    f"No matching records found in '{table_name}'",
                    NotificationSubType.DATABASE.value
                )
                return ""

            self.notification.showSuccess(
                "Query Successful",
                f"Found {len(rows)} records in '{table_name}'",
                NotificationSubType.DATABASE.value
            )

            return self._format_results(f"{table_name} ({access_type})", columns, rows)

        except Exception as e:
            error_msg = f"Error executing query: {str(e)}"
            self.notification.showError(
                "Query Error",
                error_msg,
                NotificationSubType.DATABASE.value
            )
            return ""


    def _handle_update(self, args: str) -> str:
        """Handle data update command with permission enforcement and updated_by tracking."""
        if not args:
            self.notification.showError(
                "Update Error",
                "Missing arguments for update command",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            parts = args.split(' set ', maxsplit=1)
            if len(parts) < 2:
                self.notification.showError(
                    "Syntax Error",
                    "Invalid update format. Expected: update table_name set column=value where condition",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            table_name = parts[0].strip()
            set_where = parts[1].split(' where ', maxsplit=1)

            if len(set_where) < 2:
                self.notification.showError(
                    "Syntax Error",
                    "Missing WHERE clause in update command",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            if not self._check_table_permission(table_name):
                self.notification.showError(
                    "Permission Denied",
                    f"No permission to update table '{table_name}'",
                    NotificationSubType.DATABASE.value
                )
                return ""

            # Check table columns
            cursor = self.db.conn.cursor()
            cursor.execute(f"PRAGMA table_info({table_name})")
            columns = [col[1] for col in cursor.fetchall()]
            has_updated_by = 'updated_by' in columns
            has_updated_at = 'updated_at' in columns
            has_created_by = 'created_by' in columns

            set_clause = set_where[0].strip()

            # Add updated_by and updated_at if columns exist
            if has_updated_by:
                set_clause = f"{set_clause}, updated_by = {self._current_user_id}" if set_clause else f"updated_by = {self._current_user_id}"
            if has_updated_at:
                set_clause = f"{set_clause}, updated_at = CURRENT_TIMESTAMP" if set_clause else "updated_at = CURRENT_TIMESTAMP"

            # Build WHERE clause with ownership enforcement only if created_by exists and table is not species/units
            where_clause = set_where[1].strip()
            if not self.isUserAdmin(self._current_user) and has_created_by and table_name not in ('species', 'units'):
                where_clause = f"(created_by = {self._current_user_id}) AND ({where_clause})"

            sql = f"UPDATE {table_name} SET {set_clause} WHERE {where_clause}"

            # Execute and get results
            _, _, rowcount = self._execute_sql(sql, table_name=table_name, action_type='UPDATE')

            if rowcount == 0:
                self.notification.showWarning(
                    "No Updates",
                    "No records matched your criteria",
                    NotificationSubType.DATABASE.value
                )
                return "No matching records found to update"
            self.notification.showSuccess(
                "Update Successful",
                f"Updated {rowcount} record(s) in '{table_name}'",
                NotificationSubType.DATABASE.value
            )
            return f"Updated {rowcount} row(s) in '{table_name}'"

        except Exception as e:
            error_msg = f"Update failed: {str(e)}"
            self.notification.showError(
                "Update Error",
                error_msg,
                NotificationSubType.DATABASE.value
            )
            return ""


    def _handle_delete(self, args: str) -> str:
        """Handle data deletion command with ownership enforcement."""
        if not args:
            self.notification.showError(
                "Delete Error",
                "Missing arguments for delete command",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            parts = args.split(' where ', maxsplit=1)
            if len(parts) < 2:
                self.notification.showError(
                    "Syntax Error",
                    "Missing WHERE clause in delete command",
                    NotificationSubType.VALIDATION.value
                )
                return ""

            table_name = parts[0].strip()
            where_clause = parts[1].strip()

            if not self._check_table_permission(table_name):
                self.notification.showError(
                    "Permission Denied",
                    f"No permission to delete from table '{table_name}'",
                    NotificationSubType.DATABASE.value
                )
                return ""

            # Check if table has created_by column
            cursor = self.db.conn.cursor()
            cursor.execute(f"PRAGMA table_info({table_name})")
            columns = [col[1] for col in cursor.fetchall()]
            has_created_by = 'created_by' in columns

            if not self.isUserAdmin(self._current_user) and has_created_by and table_name not in ('species', 'units'):
                where_clause = f"created_by = {self._current_user_id} AND ({where_clause})"

            sql = f"DELETE FROM {table_name} WHERE {where_clause}"
            _, _, rowcount = self._execute_sql(sql, table_name=table_name, action_type='DELETE')

            if rowcount > 0:
                self.notification.showSuccess(
                    "Deletion Successful",
                    f"Deleted {rowcount} record(s) from '{table_name}'",
                    NotificationSubType.DATABASE.value
                )
            else:
                self.notification.showWarning(
                    "No Deletions",
                    "No matching records found to delete",
                    NotificationSubType.DATABASE.value
                )

            return f"Deleted {rowcount} row(s) from '{table_name}'"

        except Exception as e:
            self.notification.showError(
                "Delete Error",
                f"Delete failed: {str(e)}",
                NotificationSubType.DATABASE.value
            )
            return ""


    def _handle_raw_sql(self, args: str) -> str:
        """Handle raw SQL command execution with security checks."""
        if not args:
            self.notification.showError(
                "SQL Error",
                "Missing SQL query",
                NotificationSubType.VALIDATION.value
            )
            return ""

        try:
            sql = args.strip()
            sql_lower = sql.lower()

            absolutely_blocked = [
                'drop table', 'drop database', 'alter table',
                'attach database', 'detach database', 'pragma',
                'vacuum', 'reindex', 'shutdown', '--', '/*'
            ]

            if any(op in sql_lower for op in absolutely_blocked):
                self.notification.showError(
                    "Security Block",
                    "This operation is permanently disabled",
                    NotificationSubType.SYSTEM.value
                )
                return ""

            if any(op in sql_lower for op in self._admin_only_operations):
                if not self.isUserAdmin(self._current_user):
                    self.notification.showError(
                        "Permission Denied",
                        "This operation requires admin privileges",
                        NotificationSubType.AUTHENTICATION.value
                    )
                    return ""

                if 'create table' in sql_lower:
                    if not re.search(r'created_by\s+INTEGER', sql_lower):
                        self.notification.showError(
                            "Security Policy",
                            "New tables must include created_by INTEGER column",
                            NotificationSubType.DATABASE.value
                        )
                        return ""

            # For non-admin users, filter protected tables with created_by
            if not self.isUserAdmin(self._current_user):
                protected_tables = ['users', 'studies', 'compounds', 'subjects']
                table_matches = [tbl for tbl in protected_tables if f' {tbl}' in sql_lower]

                for table in table_matches:
                    table_info = self._table_permissions.get(table, {})
                    if table_info.get('has_created_by', False):
                        if not sql_lower.startswith('select '):
                            self.notification.showError(
                                "Permission Denied",
                                "Only SELECT queries allowed on protected tables with ownership",
                                NotificationSubType.DATABASE.value
                            )
                            return ""
                        if f' where ' in sql_lower:
                            sql = re.sub(
                                fr'(\bwhere\b)(.*)(\b{table}\b)',
                                fr'\1 created_by = {self._current_user_id} AND \2\3',
                                sql,
                                flags=re.IGNORECASE
                            )
                        else:
                            sql = re.sub(
                                fr'(\bfrom\b)(.*)(\b{table}\b)',
                                fr'\1 \2\3 WHERE created_by = {self._current_user_id}',
                                sql,
                                flags=re.IGNORECASE
                            )

            rows, columns, _ = self._execute_sql(sql)

            if rows is not None:  # SELECT query
                self.notification.showSuccess(
                    "Query Successful",
                    f"Retrieved {len(rows)} rows",
                    NotificationSubType.DATABASE.value
                )
                return self._format_results("SQL Query Results", columns, rows)
            else:  # Other queries
                rowcount = self.db.conn.cursor().rowcount
                self.notification.showSuccess(
                    "Command Successful",
                    f"Rows affected: {rowcount}",
                    NotificationSubType.DATABASE.value
                )
                return f"Command executed successfully. Rows affected: {rowcount}"

        except Exception as e:
            self.notification.showError(
                "SQL Error",
                f"Execution failed: {str(e)}",
                NotificationSubType.DATABASE.value
            )
            return ""


    def _format_results(self, title: str, columns: List[str], rows: List[Tuple]) -> str:
        """Format query results as a text table."""
        if not rows:
            return f"{title}\nNo results found"

        # Determine column widths
        col_widths = [max(len(str(col)), 10) for col in columns]
        for row in rows:
            for i, value in enumerate(row):
                col_widths[i] = max(col_widths[i], len(str(value)))

        # We build the header
        header = " | ".join(f"{col:<{width}}" for col, width in zip(columns, col_widths))
        separator = "-+-".join("-" * width for width in col_widths)

        # Then build the rows
        formatted_rows = []
        for row in rows:
            formatted_row = " | ".join(f"{str(value):<{width}}" for value, width in zip(row, col_widths))
            formatted_rows.append(formatted_row)

        result = [f"{title}\n{separator}", header, separator]
        result.extend(formatted_rows)
        result.append(separator)
        result.append(f"Total: {len(rows)} row(s)")

        return "\n".join(result)


    def _handle_help(self, args: str = "") -> str:
        """Display help information about available commands.
        Format: help [command]
        """
        command_docs = {
            # 'create': (
            #     "Create a new table\n"
            #     "Format: create table_name column1:type1 column2:type2 ...\n"
            #     "Example: create experiments name:TEXT start_date:TIMESTAMP"
            # ),
            'insert': (
                "Insert a new record\n"
                "Format: insert table_name column1=value1 column2=value2 ...\n"
                "Available tables: species, compounds, studies, subjects, etc.\n"
                "Example: insert species common_name='Mouse' scientific_name='Mus musculus'"
            ),
            'display': (
                "Display records from a table\n"
                "Format: display table_name [where condition]\n"
                "Available tables: species, compounds, studies, subjects, etc.\n"
                "Examples:\n"
                "  display species\n"
                "  display compounds where molecular_formula LIKE 'C%'\n"
                "  display subjects where species_id=1"
            ),
            'update': (
                "Update existing records\n"
                "Format: update table_name set column1=value1,column2=value2 where condition\n"
                "Example: update subjects set status='inactive' where lab_id='AA0001'"
            ),
            'delete': (
                "Delete records (admin only)\n"
                "Format: delete table_name where condition\n"
                "Example: delete subject_conditions where subject_id=3"
            ),
            'sql': (
                "Execute raw SQL (admin only)\n"
                "Format: sql SQL_STATEMENT\n"
                "Example: sql SELECT study_code, title FROM studies WHERE status='active'"
            ),
            'help': (
                "Show this help message\n"
                "Format: help [command]\n"
                "Examples:\n"
                "  help\n"
                "  help insert"
            )
        }

        # Add to command_handlers in __init__ if not already present
        if 'help' not in self.command_handlers:
            self.command_handlers['help'] = self._handle_help

        # Database schema information
        schema_info = [
            "\nDatabase Schema Overview:",
            "- species: Track animal species (common_name, scientific_name)",
            "- experimental conditions: tracks an experiment data on a Study"
            "- compounds: Chemical compounds (compound_name, molecular_formula)",
            "- studies: Research studies (study_code, title, status)",
            "- subjects: Research subjects (lab_id, species_id, status)",
            "- subject_conditions: Treatment conditions for subjects",
            "- audit_log: History of all database changes"
        ]

        if args:
            # Help for a specific command
            cmd = args.split()[0].lower()
            if cmd in command_docs:
                return command_docs[cmd]
            return f"Unknown command: {cmd}\nAvailable commands: {', '.join(command_docs.keys())}"

        # General help
        help_text = [
            "Research Database Command Help",
            "=============================",
            "",
            *[f"{cmd:8} - {command_docs[cmd].splitlines()[0]}" for cmd in command_docs],
            *schema_info,
            "",
            "Type 'help <command>' for detailed usage of a specific command",
            "Note: Some commands require admin privileges"
        ]
        return "\n".join(help_text)

    def isUserAdmin(self, user: User):
        return user.role == "admin"
