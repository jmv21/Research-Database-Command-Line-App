import sqlite3
from PySide6.QtCore import QObject, Signal, Slot
from datetime import datetime
from user import User
import hashlib
import time
import json

class DatabaseHandler(QObject):
    login_success = Signal(dict)
    login_failed = Signal()
    register_success = Signal()
    register_failed = Signal()

    def __init__(self, notification_handler):
        super().__init__()
        self.notification = notification_handler
        self.currentUserId = 0
        self.conn = sqlite3.connect("research_db.db", check_same_thread=False)
        self.conn.execute("PRAGMA foreign_keys = ON")
        self._initialize_database()


    def execute(self, query: str, params: tuple = None, *,
                table_name: str = None, action_type: str = None, user_id = -1) -> sqlite3.Cursor:
        """
        Executes SQL and auto-logs writes. For reads, just pass query + params.

         Args:
             query: SQL to execute
             params: Query parameters (optional)
             table_name: Only needed for INSERT/UPDATE/DELETE
             action_type: Only needed for writes ('INSERT'/'UPDATE'/'DELETE')
         """
        cursor = None
        start_time = time.time() * 1000

        try:
            cursor = self.conn.cursor()
            cursor.execute(query, params if params else ())

            # print("Query to execute:", query)

            # Auto-log writes (if action_type provided)
            print("SomePrint", action_type, self.currentUserId)
            if action_type and self.currentUserId > 0:
                self._auto_log(
                    query=query,
                    table_name=table_name,
                    action_type=action_type,
                    cursor=cursor,
                    exec_time=time.time() * 1000 - start_time,
                    user_id = self.currentUserId
                )

            self.conn.commit()
            return cursor

        except Exception as e:
            # Don't fail the main operation if logging fails
            self.notification.showWarning(
                "Operation Error",
                f"Failed to execute last operation due to: {str(e)}",
                "database"
            )

    def _auto_log(self, query: str, table_name: str, action_type: str,
                  cursor: sqlite3.Cursor, user_id: int, exec_time: float,
                  error: str = None):
        """
        Helper method to automatically log database actions.

        Args:
            query: The SQL query that was executed
            table_name: Name of the table affected
            action_type: Type of action ('INSERT'/'UPDATE'/'DELETE')
            cursor: Cursor used for the operation
            user_id: ID of the user performing the action
            exec_time: Execution time in milliseconds
            error: Error message if operation failed (optional)
        """
        try:
            # Get the last row ID for INSERT operations
            _cursor = self.conn.cursor()
            record_id = _cursor.lastrowid if action_type == 'INSERT' else None

            # For UPDATE/DELETE, get affected rows count
            affected_rows = _cursor.rowcount if action_type in ('UPDATE', 'DELETE') else None

            log_data = {
                'user_id': user_id,
                'table_name': table_name,
                'record_id': record_id,
                'action_type': action_type,
                'sql_query': query,
                'execution_time_ms': round(exec_time, 2),
                'affected_rows': affected_rows
            }

            if error:
                log_data['error'] = error

            self.log_action(log_data)

        except Exception as e:
            print("here")
            self.notification.showWarning(
                "Logging Warning",
                f"Failed to log database action: {str(e)}",
                "database"
            )

    def _initialize_database(self):
        """Initialize all database tables if they don't exist"""
        try:
            cursor = self.conn.cursor()

            # Create all tables
            cursor.executescript("""
                -- 1. User System with Authentication
                CREATE TABLE IF NOT EXISTS users (
                    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT UNIQUE NOT NULL CHECK(length(username) >= 4),
                    password_hash TEXT NOT NULL CHECK(length(password_hash) = 64),
                    full_name TEXT NOT NULL CHECK(length(full_name) >= 2),
                    role TEXT NOT NULL CHECK(role IN ('admin', 'researcher', 'reviewer', 'technician')) DEFAULT 'researcher',
                    email TEXT UNIQUE NOT NULL CHECK(email LIKE '%@%.%'),
                    last_login TIMESTAMP,
                    is_active BOOLEAN DEFAULT TRUE,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id)
                );

                -- 2. Species Reference Table
                CREATE TABLE IF NOT EXISTS species (
                    species_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    common_name TEXT NOT NULL CHECK(length(common_name) >= 2),
                    scientific_name TEXT NOT NULL CHECK(length(scientific_name) >= 2),
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id),
                    UNIQUE (common_name, scientific_name)
                );

                -- 3. Units Table
                CREATE TABLE IF NOT EXISTS units (
                    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    unit_name TEXT NOT NULL CHECK(length(unit_name) >= 1) UNIQUE,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id)
                );

                -- 4. Compounds Catalog
                CREATE TABLE IF NOT EXISTS compounds (
                    compound_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    compound_name TEXT NOT NULL CHECK(length(compound_name) >= 2) UNIQUE,
                    iupac_name TEXT,
                    cas_number TEXT CHECK(cas_number IS NULL OR cas_number GLOB '[0-9]*-[0-9]*-[0-9]*'),
                    molecular_formula TEXT,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id)
                );

                -- 5. Dosage Definitions
                CREATE TABLE IF NOT EXISTS dosage_definitions (
                    dosage_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    compound_id INTEGER NOT NULL REFERENCES compounds(compound_id) ON DELETE CASCADE,
                    unit_id INTEGER NOT NULL REFERENCES units(unit_id) ,
                    dosage_value REAL NOT NULL CHECK(dosage_value > 0),
                    description TEXT,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id),
                    UNIQUE (compound_id, unit_id, dosage_value)
                );

                -- 6. Studies
                CREATE TABLE IF NOT EXISTS studies (
                    study_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    study_code TEXT UNIQUE NOT NULL CHECK(
                        study_code GLOB 'ST[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]'
                    ),
                    title TEXT NOT NULL CHECK(length(title) >= 5),
                    description TEXT,
                    start_date DATE CHECK(start_date IS NULL OR date(start_date) = start_date),
                    end_date DATE CHECK(
                        end_date IS NULL OR
                        (date(end_date) = end_date AND
                         (start_date IS NULL OR end_date >= start_date))
                    ),
                    status TEXT NOT NULL DEFAULT 'draft'
                        CHECK(status IN ('draft', 'planned', 'active', 'completed', 'cancelled')),
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id)
                );

                -- 8. Experimental Conditions
                CREATE TABLE IF NOT EXISTS experimental_conditions (
                    condition_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    study_id INTEGER NOT NULL REFERENCES studies(study_id) ON DELETE CASCADE,
                    condition_name TEXT NOT NULL CHECK(length(condition_name) >= 2),
                    description TEXT NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id),
                    UNIQUE (study_id, condition_name)
                );

                -- 9. Subjects
                CREATE TABLE IF NOT EXISTS subjects (
                    subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    lab_id TEXT UNIQUE NOT NULL CHECK(
                        lab_id GLOB '[A-Z][A-Z][0-9][0-9][0-9][0-9]'
                    ),
                    species_id INTEGER NOT NULL REFERENCES species(species_id),
                    sex TEXT CHECK(sex IN ('M', 'F', 'U')),
                    birth_date DATE CHECK(birth_date IS NULL OR date(birth_date) = birth_date),
                    status TEXT DEFAULT 'active'
                        CHECK(status IN ('active', 'inactive', 'deceased', 'withdrawn')),
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id),
                    notes TEXT NULL
                );

                -- 10. Subject Conditions
                CREATE TABLE IF NOT EXISTS subject_conditions (
                    subject_condition_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    subject_id INTEGER NOT NULL REFERENCES subjects(subject_id) ON DELETE CASCADE,
                    condition_id INTEGER NOT NULL REFERENCES experimental_conditions(condition_id) ON DELETE CASCADE,
                    dosage_id INTEGER NOT NULL REFERENCES dosage_definitions(dosage_id) ON DELETE RESTRICT,
                    administration_time TIMESTAMP NOT NULL,
                    administered_by INTEGER NOT NULL REFERENCES users(user_id),
                    outcome TEXT CHECK(outcome IN ('success', 'failure', 'improved', 'no effect', 'pending')) DEFAULT 'pending',
                    notes TEXT NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER NOT NULL REFERENCES users(user_id),
                    updated_at TIMESTAMP,
                    updated_by INTEGER REFERENCES users(user_id)
                );

                -- 11. Audit Log
                CREATE TABLE IF NOT EXISTS audit_log (
                    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER REFERENCES users(user_id),
                    action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    table_name TEXT,
                    record_id INTEGER,
                    action_type TEXT NOT NULL CHECK(action_type IN ('INSERT', 'UPDATE', 'DELETE')),
                    sql_query TEXT NOT NULL,
                    old_values TEXT NULL,
                    new_values TEXT NULL,
                    ip_address TEXT NULL,
                    execution_time_ms INTEGER NULL,
                    affected_rows INTEGER NULL
                );
            """)

            # -- 11. EEG Recordings
            # CREATE TABLE IF NOT EXISTS eeg_recordings (
            #     recording_id INTEGER PRIMARY KEY AUTOINCREMENT,
            #     subject_condition_id INTEGER NOT NULL REFERENCES subject_conditions(subject_condition_id) ON DELETE CASCADE,
            #     file_path TEXT UNIQUE NOT NULL CHECK(
            #         file_path LIKE '%.edf' OR
            #         file_path LIKE '%.bdf' OR
            #         file_path LIKE '%.vhdr'
            #     ),
            #     file_size INTEGER NULL,
            #     file_extension TEXT NOT NULL GENERATED ALWAYS AS (
            #         CASE
            #             WHEN file_path LIKE '%.edf' THEN 'edf'
            #             WHEN file_path LIKE '%.bdf' THEN 'bdf'
            #             WHEN file_path LIKE '%.vhdr' THEN 'vhdr'
            #         END
            #     ) STORED,
            #     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            #     created_by INTEGER NOT NULL REFERENCES users(user_id)
            # );

            self.add_triggers(cursor)

            cursor.execute("SELECT COUNT(*) FROM users")
            if cursor.fetchone()[0] == 0:
                self._create_admin_user()

            if self.should_populate(cursor):
                self.populate_database()

            self.conn.commit()

        except sqlite3.Error as e:
            self.notification.showError(
                "Database Initialization Error",
                f"Failed to initialize database: {str(e)}",
                "database"
            )
            raise


    def add_triggers(self, cursor):
          cursor.executescript("""
              -- Users table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_users_timestamps
              BEFORE UPDATE ON users
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'users.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'users.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'users.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE user_id = OLD.user_id;
              END;
              -- Species table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_species_timestamps
              BEFORE UPDATE ON species
              FOR EACH ROW
              BEGIN
                  -- Prevent invalid updated_at
                  SELECT CASE
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'species.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'species.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE species SET updated_at = CURRENT_TIMESTAMP WHERE species_id = OLD.species_id;
              END;
              -- Units table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_units_timestamps
              BEFORE UPDATE ON units
              FOR EACH ROW
              BEGIN
                  -- Prevent invalid updated_at
                  SELECT CASE
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'units.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'units.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE units SET updated_at = CURRENT_TIMESTAMP WHERE unit_id = OLD.unit_id;
              END;
              -- Compounds table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_compounds_timestamps
              BEFORE UPDATE ON compounds
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'compounds.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'compounds.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'compounds.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE compounds SET updated_at = CURRENT_TIMESTAMP WHERE compound_id = OLD.compound_id;
              END;
              -- Dosage definitions table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_dosage_definitions_timestamps
              BEFORE UPDATE ON dosage_definitions
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'dosage_definitions.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'dosage_definitions.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'dosage_definitions.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE dosage_definitions SET updated_at = CURRENT_TIMESTAMP WHERE dosage_id = OLD.dosage_id;
              END;
              -- Studies table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_studies_timestamps
              BEFORE UPDATE ON studies
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'studies.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'studies.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'studies.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE studies SET updated_at = CURRENT_TIMESTAMP WHERE study_id = OLD.study_id;
              END;
              -- Experimental conditions table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_experimental_conditions_timestamps
              BEFORE UPDATE ON experimental_conditions
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'experimental_conditions.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'experimental_conditions.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'experimental_conditions.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE experimental_conditions SET updated_at = CURRENT_TIMESTAMP WHERE condition_id = OLD.condition_id;
              END;
              -- Subjects table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_subjects_timestamps
              BEFORE UPDATE ON subjects
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'subjects.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'subjects.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'subjects.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE subjects SET updated_at = CURRENT_TIMESTAMP WHERE subject_id = OLD.subject_id;
              END;
              -- Subject conditions table: Combined timestamp protection and update
              CREATE TRIGGER IF NOT EXISTS manage_subject_conditions_timestamps
              BEFORE UPDATE ON subject_conditions
              FOR EACH ROW
              BEGIN
                  -- Prevent manual modification of created_at or invalid updated_at
                  SELECT CASE
                      WHEN NEW.created_at != OLD.created_at THEN
                          RAISE(ABORT, 'subject_conditions.created_at cannot be modified')
                      WHEN NEW.updated_at < OLD.updated_at THEN
                          RAISE(ABORT, 'subject_conditions.updated_at cannot be set to earlier timestamp')
                      WHEN OLD.created_by IS NOT NULL AND NEW.created_by != OLD.created_by THEN
                          RAISE(ABORT, 'subject_conditions.created_by cannot be modified after creation')
                  END;
                  -- Auto-update updated_at
                  UPDATE subject_conditions SET updated_at = CURRENT_TIMESTAMP WHERE subject_condition_id = OLD.subject_condition_id;
              END;
              -- Audit log table: Prevent any updates
              CREATE TRIGGER IF NOT EXISTS prevent_audit_log_updates
              BEFORE UPDATE ON audit_log
              FOR EACH ROW
              BEGIN
                  SELECT RAISE(ABORT, 'audit_log table cannot be updated');
              END;
          """)


    def should_populate(self, cursor) -> bool:
        cursor.execute("SELECT COUNT(*) FROM species")
        return cursor.fetchone()[0] == 0

    def populate_database(self):
        """Populate database with sample data for testing/demo purposes"""
        try:
            cursor = self.conn.cursor()

            cursor.execute("SELECT user_id FROM users WHERE username = 'admin'")
            admin_id = cursor.fetchone()[0]

            # 1. Add Species
            species = [
                ('Mouse', 'Mus musculus'),
                ('Rat', 'Rattus norvegicus'),
                ('Zebrafish', 'Danio rerio'),
                ('Guinea Pig', 'Cavia porcellus'),
                ('Rabbit', 'Oryctolagus cuniculus')
            ]
            cursor.executemany(
                "INSERT INTO species (common_name, scientific_name, created_by) VALUES (?, ?, ?)",
                [(name, sci_name, admin_id) for name, sci_name in species]
            )

            # 2. Add Units
            units = ['mg', 'ml', 'g', 'kg', 'µl', 'µg', 'L', 'mM']
            cursor.executemany(
                "INSERT INTO units (unit_name, created_by) VALUES (?, ?)",
                [(unit, admin_id) for unit in units]
            )

            # 3. Add Compounds
            compounds = [
                ('Diazepam', '7-chloro-1,3-dihydro-1-methyl-5-phenyl-2H-1,4-benzodiazepin-2-one', '439-14-5', 'C16H13ClN2O'),
                ('Morphine', '(5α,6α)-7,8-didehydro-4,5-epoxy-17-methylmorphinan-3,6-diol', '57-27-2', 'C17H19NO3'),
                ('Saline', None, None, 'NaCl+H2O'),
                ('Caffeine', '1,3,7-trimethylxanthine', '58-08-2', 'C8H10N4O2'),
                ('Ibuprofen', '2-(4-isobutylphenyl)propanoic acid', '15687-27-1', 'C13H18O2')
            ]
            cursor.executemany(
                """INSERT INTO compounds
                (compound_name, iupac_name, cas_number, molecular_formula, created_by)
                VALUES (?, ?, ?, ?, ?)""",
                [(name, iupac, cas, formula, admin_id) for name, iupac, cas, formula in compounds]
            )

            # 4. Add Dosages
            cursor.execute("SELECT compound_id FROM compounds WHERE compound_name = 'Diazepam'")
            diazepam_id = cursor.fetchone()[0]
            cursor.execute("SELECT compound_id FROM compounds WHERE compound_name = 'Caffeine'")
            caffeine_id = cursor.fetchone()[0]
            cursor.execute("SELECT compound_id FROM compounds WHERE compound_name = 'Ibuprofen'")
            ibuprofen_id = cursor.fetchone()[0]
            cursor.execute("SELECT unit_id FROM units WHERE unit_name = 'mg'")
            mg_id = cursor.fetchone()[0]
            cursor.execute("SELECT unit_id FROM units WHERE unit_name = 'µg'")
            ug_id = cursor.fetchone()[0]

            dosages = [
                (diazepam_id, mg_id, 5.0, "Standard dose"),
                (diazepam_id, mg_id, 10.0, "High dose"),
                (caffeine_id, mg_id, 50.0, "Low dose for stimulation"),
                (caffeine_id, mg_id, 100.0, "Moderate dose"),
                (ibuprofen_id, mg_id, 200.0, "Standard pain relief"),
                (ibuprofen_id, ug_id, 500.0, "Low dose for inflammation")
            ]
            cursor.executemany(
                """INSERT INTO dosage_definitions
                (compound_id, unit_id, dosage_value, description, created_by)
                VALUES (?, ?, ?, ?, ?)""",
                [(c_id, u_id, val, desc, admin_id) for c_id, u_id, val, desc in dosages]
            )

            # 5. Add Studies
            studies = [
                ('ST2023-001', 'Diazepam Efficacy Study', 'Testing diazepam effects on anxiety', '2023-01-15', '2023-06-30', 'completed'),
                ('ST2023-002', 'Morphine Pain Relief', 'Comparative study of pain relief', '2023-03-01', None, 'active'),
                ('ST2024-001', 'Caffeine Cognitive Effects', 'Study on caffeine and cognitive performance', '2024-02-01', '2024-12-31', 'active'),
                ('ST2024-002', 'Ibuprofen Inflammation Study', 'Evaluating ibuprofen effects on inflammation', '2024-04-15', None, 'planned')
            ]
            cursor.executemany(
                """INSERT INTO studies
                (study_code, title, description, start_date, end_date, status, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?)""",
                [(code, title, desc, start, end, status, admin_id) for code, title, desc, start, end, status in studies]
            )

            # 6. Add Experimental Conditions
            cursor.execute("SELECT study_id FROM studies WHERE study_code = 'ST2023-001'")
            study1_id = cursor.fetchone()[0]
            cursor.execute("SELECT study_id FROM studies WHERE study_code = 'ST2024-001'")
            study2_id = cursor.fetchone()[0]
            cursor.execute("SELECT compound_id FROM compounds WHERE compound_name = 'Saline'")
            saline_id = cursor.fetchone()[0]

            conditions = [
                (study1_id, 'Control Group', 'Saline solution control'),
                (study1_id, 'Low Dose', '5mg/kg diazepam'),
                (study1_id, 'High Dose', '10mg/kg diazepam'),
                (study2_id, 'Control Group', 'Saline solution control'),
                (study2_id, 'Caffeine Low', '50mg caffeine'),
                (study2_id, 'Caffeine Moderate', '100mg caffeine')
            ]
            cursor.executemany(
                """INSERT INTO experimental_conditions
                (study_id, condition_name, description, created_by)
                VALUES (?, ?, ?, ?)""",
                [(s_id, name, desc, admin_id) for s_id, name, desc in conditions]
            )

            # 7. Add Subjects
            cursor.execute("SELECT species_id FROM species WHERE common_name = 'Mouse'")
            mouse_id = cursor.fetchone()[0]
            cursor.execute("SELECT species_id FROM species WHERE common_name = 'Rat'")
            rat_id = cursor.fetchone()[0]
            cursor.execute("SELECT species_id FROM species WHERE common_name = 'Guinea Pig'")
            guinea_pig_id = cursor.fetchone()[0]

            subjects = [
                ('AA0001', mouse_id, 'M', '2022-10-15', 'active', None),
                ('AA0002', mouse_id, 'F', '2022-10-20', 'active', 'Special diet'),
                ('AA0003', mouse_id, 'M', '2022-11-05', 'active', None),
                ('BB0001', rat_id, 'F', '2022-12-01', 'active', 'High activity'),
                ('BB0002', rat_id, 'M', '2022-12-15', 'inactive', None),
                ('CC0001', guinea_pig_id, 'U', '2023-01-10', 'active', 'Baseline testing')
            ]
            cursor.executemany(
                """INSERT INTO subjects
                (lab_id, species_id, sex, birth_date, status, notes, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?)""",
                [(lab_id, s_id, sex, bdate, status, notes, admin_id) for lab_id, s_id, sex, bdate, status, notes in subjects]
            )

            # 8. Add Subject Conditions
            cursor.execute("SELECT condition_id FROM experimental_conditions WHERE study_id = ? AND condition_name = 'Control Group'", (study1_id,))
            control_cond_id = cursor.fetchone()[0]
            cursor.execute("SELECT condition_id FROM experimental_conditions WHERE study_id = ? AND condition_name = 'Low Dose'", (study1_id,))
            low_dose_cond_id = cursor.fetchone()[0]
            cursor.execute("SELECT condition_id FROM experimental_conditions WHERE study_id = ? AND condition_name = 'Caffeine Low'", (study2_id,))
            caffeine_low_cond_id = cursor.fetchone()[0]
            cursor.execute("SELECT dosage_id FROM dosage_definitions WHERE compound_id = ? AND dosage_value = 5.0", (diazepam_id,))
            diazepam_dosage_id = cursor.fetchone()[0]
            cursor.execute("SELECT dosage_id FROM dosage_definitions WHERE compound_id = ? AND dosage_value = 50.0", (caffeine_id,))
            caffeine_dosage_id = cursor.fetchone()[0]

            subject_conditions = [
                (1, control_cond_id, diazepam_dosage_id, '2023-01-20 09:00:00', admin_id, 'success', 'Initial treatment'),
                (2, low_dose_cond_id, diazepam_dosage_id, '2023-01-20 09:15:00', admin_id, 'pending', None),
                (3, low_dose_cond_id, diazepam_dosage_id, '2023-01-21 10:00:00', admin_id, 'improved', 'Follow-up dose'),
                (4, caffeine_low_cond_id, caffeine_dosage_id, '2024-02-02 08:30:00', admin_id, 'no effect', 'Caffeine trial start'),
                (5, caffeine_low_cond_id, caffeine_dosage_id, '2024-02-02 08:45:00', admin_id, 'pending', None)
            ]

            cursor.executemany(
                """INSERT INTO subject_conditions
                   (subject_id, condition_id, dosage_id, administration_time, administered_by, outcome, notes, created_by, created_at)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                [(s_id, c_id, d_id, time, adm_by, outcome, notes, admin_id, '2025-05-24 18:37:00')
                 for s_id, c_id, d_id, time, adm_by, outcome, notes in subject_conditions]
            )

            self.conn.commit()
            self.notification.showSuccess(
                "Database Populated",
                "Sample data successfully added to database",
                "database"
            )

        except sqlite3.Error as e:
            self.conn.rollback()
            self.notification.showError(
                "Population Error",
                f"Failed to populate database: {str(e)}",
                "database"
            )
            raise


    def _create_admin_user(self):
        """Create initial admin user if no users exist"""
        admin_data = {
            'username': 'admin',
            'password_hash': self._hash_password('admin123'),
            'full_name': 'System Administrator',
            'email': 'admin@research.org',
            'role': 'admin'
        }

        try:
            cursor = self.conn.cursor()
            cursor.execute("""
                INSERT INTO users
                (username, password_hash, full_name, email, role, created_by)
                VALUES
                (:username, :password_hash, :full_name, :email, :role, 1)
            """, admin_data)
            self.conn.commit()
        except sqlite3.Error as e:
            self.notification.showError(
                "Admin Creation Error",
                f"Failed to create admin user: {str(e)}",
                "database"
            )
            raise

    def _hash_password(self, password: str) -> str:
        """Hash password using SHA-256"""
        return hashlib.sha256(password.encode('utf-8')).hexdigest()

    @Slot(str, str)
    def login(self, username: str, password: str):
        try:
            password_hash = self._hash_password(password)

            cursor = self.execute(
                """
                SELECT user_id, username, full_name, role, email
                FROM users
                WHERE username = ? AND password_hash = ? AND is_active = TRUE
                """,
                (username, password_hash)
            )

            user = cursor.fetchone()

            if user:
                self.execute(
                    """
                    UPDATE users
                    SET last_login = ?
                    WHERE user_id = ?
                    """,
                    (datetime.now(), user[0]),
                    table_name='users',
                    action_type='UPDATE',
                )

                user_data = {
                    'user_id': user[0],
                    'username': user[1],
                    'full_name': user[2],
                    'role': user[3],
                    'email': user[4]
                }
                self.login_success.emit(user_data)
            else:
                self.login_failed.emit()

        except sqlite3.Error as e:
            self.login_failed.emit()

    @Slot(str, str, str, str)
    def register(self, username: str, password: str, full_name: str, email: str):
        """Register a new user (default role: researcher)"""
        try:
            password_hash = self._hash_password(password)

            cursor = self.execute(
                """
                INSERT INTO users
                (username, password_hash, full_name, email, created_by)
                VALUES
                (?, ?, ?, ?, 1)  -- created_by 1 is the admin user
                """,
                (username, password_hash, full_name, email),
                table_name='users',
                action_type='INSERT',
            )

            self.register_success.emit()

        except sqlite3.IntegrityError as e:
            error_msg = "Username or email already exists" if "UNIQUE" in str(e) else "Registration failed"
            self.notification.showError(
                "Registration Failed",
                error_msg,
                "authentication"
            )
            self.register_failed.emit()

        except sqlite3.Error as e:
            self.notification.showError(
                "Registration Error",
                f"Database error during registration: {str(e)}",
                "database"
            )
            self.register_failed.emit()

    @Slot(int, result=list)
    def get_studies_by_user(self, user_id: int):
        """Retrieve all studies associated with a user
           Args:
               user_id: The ID of the user
           Returns:
               List of study dictionaries with all study fields
           """
        try:
               cursor = self.conn.cursor()

               # Query to get studies where the user is the creator or involved
               cursor.execute("""
                   SELECT s.study_id, s.study_code, s.title, s.description,
                          s.start_date, s.end_date, s.status
                   FROM studies s
                   WHERE s.created_by = ?
               """, (user_id,))

               studies = []
               columns = [column[0] for column in cursor.description]

               for row in cursor.fetchall():
                   study = dict(zip(columns, row))
                   # Convert dates to strings if they're not None
                   for date_field in ['start_date', 'end_date']:
                       if study[date_field] is not None:
                           study[date_field] = str(study[date_field])
                   studies.append(study)

               return studies

        except sqlite3.Error as e:
               self.notification.showError(
                   "Database Error",
                   f"Failed to fetch studies: {str(e)}",
                   "database"
               )
               return []

    def log_action(self, log_data: dict):
        """
        Log an action to the audit_log table

        Args:
            log_data: Dictionary containing audit log information with these possible keys:
                - user_id: ID of the user performing the action (required)
                - table_name: Name of the table being modified (required)
                - record_id: ID of the record being modified (optional)
                - action_type: Type of action ('INSERT', 'UPDATE', 'DELETE') (required)
                - sql_query: The complete SQL query that was executed (required)
                - old_values: Dictionary of old values (for UPDATE/DELETE) (optional)
                - new_values: Dictionary of new values (for INSERT/UPDATE) (optional)
                - ip_address: IP address of the client (optional)
                - execution_time_ms: Query execution time in milliseconds (optional)
                - affected_rows: Number of rows affected (optional)
        """
        try:
            # Validate required fields
            if(log_data['action_type'] not in ['INSERT', 'UPDATE', 'DELETE']):
                return
            required_fields = ['user_id', 'table_name', 'action_type', 'sql_query']
            for field in required_fields:
                if field not in log_data:
                    raise ValueError(f"Missing required field: {field}")
            print("log_data")
            cursor = self.conn.cursor()

            # Convert dictionaries to JSON strings if they exist
            old_json = json.dumps(log_data.get('old_values')) if 'old_values' in log_data else None
            new_json = json.dumps(log_data.get('new_values')) if 'new_values' in log_data else None

            cursor.execute("""
                INSERT INTO audit_log (
                    user_id, table_name, record_id, action_type,
                    sql_query, old_values, new_values, ip_address,
                    execution_time_ms, affected_rows
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                log_data['user_id'],
                log_data['table_name'],
                log_data.get('record_id'),
                log_data['action_type'],
                log_data['sql_query'],
                old_json,
                new_json,
                log_data.get('ip_address'),
                log_data.get('execution_time_ms'),
                log_data.get('affected_rows')
            ))

            self.conn.commit()

        except sqlite3.Error as e:
            self.conn.rollback()
            self.notification.showError(
                "Audit Log Error",
                f"Failed to log action: {str(e)}",
                "database"
            )
        except ValueError as e:
            self.notification.showError(
                "Audit Log Error",
                str(e),
                "database"
            )


    def close(self):
        """Close database connection"""
        self.conn.close()
