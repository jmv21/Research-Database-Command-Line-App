from PySide6 import QtCore
from enum import IntEnum
from user import User
from notificationHandler import NotificationHandler, NotificationIconType, NotificationSubType
from studyModel import StudyListModel
from databaseInterpreter import DatabaseInterpreter
from PySide6.QtCore import QUrl
from study import Study
from quick_commands import QuickCommandModel

class AuthState(IntEnum):
    NOT_LOGGED_IN = 0
    LOGGING_IN = 1
    LOGGED_IN = 2

class MainController(QtCore.QObject):
    # Signals
    loginStarted = QtCore.Signal()
    loginSucceeded = QtCore.Signal()
    logoutCompleted = QtCore.Signal()
    loginFailed = QtCore.Signal(str)  # error message
    commandExecuted = QtCore.Signal(str, str)  # command, result
    interpreterBusyChanged = QtCore.Signal()

    def __init__(self, db_handler, notification_handler, auth_service):
        super().__init__()
        self._auth = auth_service
        self._db_handler = db_handler
        self._notification = notification_handler
        self._auth_state = AuthState.NOT_LOGGED_IN
        self._current_user = User()
        self._study_model = StudyListModel()
        self._database_interpreter = DatabaseInterpreter(db_handler,notification_handler)
        self._can_export = False
        self._quick_commands = QuickCommandModel(self)

        print("Connecting db_handler signals")
        self._auth.login_success.connect(self._handle_login_success)
        self._auth.login_failed.connect(self._handle_login_failed)
        self._database_interpreter.commandExecuted.connect(self._handle_command_result)


    @QtCore.Property(bool, notify=interpreterBusyChanged)
    def interpreterBusy(self):
        return getattr(self, '_interpreter_busy', False)

    @QtCore.Property(QtCore.QObject, constant=True)
    def quickCommands(self):
        return self._quick_commands

    canExportChanged = QtCore.Signal()
    @QtCore.Property(bool, notify=canExportChanged)
    def canExport(self):
        return self._can_export

    @interpreterBusy.setter
    def interpreterBusy(self, value):
        if getattr(self, '_interpreter_busy', False) != value:
            self._interpreter_busy = value
            self.interpreterBusyChanged.emit()

    # Properties
    authStateChanged = QtCore.Signal()
    @QtCore.Property(int, notify=authStateChanged)
    def authState(self):
        return int(self._auth_state)

    @QtCore.Property(QtCore.QObject, constant=True)
    def studyModel(self):
        return self._study_model

    currentUserChanged = QtCore.Signal()
    @QtCore.Property(QtCore.QObject, notify=currentUserChanged)
    def currentUser(self):
        return self._current_user

    isLoggedInChanged = QtCore.Signal()
    @QtCore.Property(bool, notify=isLoggedInChanged)
    def isLoggedIn(self):
        return self._auth_state == AuthState.LOGGED_IN

    # Public slots
    @QtCore.Slot(str, str)
    def login(self, username: str, password: str):
        self._auth.login(username, password)

    @QtCore.Slot()
    def logout(self):
        self._auth.logout()
        self.logoutCompleted.emit()

    @QtCore.Slot(str)
    def executeCommand(self, command_text: str):
        """Execute a database command through the interpreter"""
        if not command_text.strip():
            self._notification.showError(
                "Empty Command",
                "Please enter a command to execute",
                NotificationSubType.VALIDATION.value
                )
            return

        self.interpreterBusy = True
        self._database_interpreter.execute_command(command_text)

    @QtCore.Slot()
    def loadStudies(self):
        """Load studies from database and update the study model"""
        if not self.isLoggedIn or self._current_user.userId == -1:
            self._notification.showWarning(
                "Not Logged In",
                "Please log in to view studies",
                NotificationSubType.AUTHENTICATION.value
            )
            return

        try:
            # Get studies from database
            studies_data = self._db_handler.get_studies_by_user(self._current_user.userId)

            # Clear existing model data
            self._study_model.beginResetModel()
            self._study_model.clear()

            # Add new studies to model
            for study_data in studies_data:
                self._study_model.addStudy(study_data)

            self._study_model.endResetModel()

            # Notify user
            if len(studies_data) > 0:
                self._notification.showSuccess(
                    "Studies Loaded",
                    f"Successfully loaded {len(studies_data)} studies",
                    NotificationSubType.DATABASE.value
                )
            else:
                self._notification.showInfo(
                    "No Studies Found",
                    "You don't have any studies yet",
                    NotificationSubType.DATABASE.value
                )

        except Exception as e:
            self._notification.showError(
                "Load Error",
                f"Failed to load studies: {str(e)}",
                NotificationSubType.DATABASE.value
            )


    @QtCore.Property(list , constant=True)
    def commandHistory(self):
        return getattr(self, '_command_history', [])

    @QtCore.Property(str)
    def _handle_help(self, args: str) -> str:
        """Handle help command"""
        help_text = """Available commands:
        - create table_name column1:type1 column2:type2...
        - display table_name [where condition]
        - update table_name set column=value where condition
        - delete table_name where condition
        - sql YOUR_SQL_STATEMENT"""
        return help_text

    def _add_to_history(self, command, result):
        if not hasattr(self, '_command_history'):
            self._command_history = []
        self._command_history.append({'command': command, 'result': result})
        if len(self._command_history) > 50:
            self._command_history.pop(0)


    # Private handlers
    def _handle_login_success(self, user_data):
        if self._current_user.update(user_data):
            self.currentUserChanged.emit()
            self._database_interpreter.set_current_user(self._current_user.userId)
            self._database_interpreter._current_user = self._current_user
            self._db_handler.currentUserId = self._current_user.userId
        self.loginSucceeded.emit()


    def _handle_login_failed(self):
        self._auth_state = AuthState.NOT_LOGGED_IN



    @QtCore.Slot(str, result=bool)
    def exportToCsv(self, file_url: QUrl) -> bool:
        """
        Export the last command result to CSV file
        Returns True if successful, False otherwise
        """
        if file_url.startswith('file://'):
            file_path = QUrl(file_url).toLocalFile()
        else:
            file_path = file_url

        if not file_path.lower().endswith('.csv'):
            file_path += '.csv'


        try:
            success = self._database_interpreter.export_last_result_to_csv(file_path)
            if success:
                self._notification.showSuccess(
                    "Export Successful",
                    f"Data exported to {file_path}",
                    NotificationSubType.SYSTEM.value
                )
            return success
        except Exception as e:
            self._notification.showError(
                "Export Error",
                f"Failed to export data: {str(e)}",
                NotificationSubType.SYSTEM.value
            )
            return False

    @QtCore.Slot(str, str)
    def _handle_command_result(self, command: str, result: str):
        """Handle results from the interpreter"""
        self.interpreterBusy = False
        last_result, _ = self._database_interpreter.get_last_result()
        new_can_export = last_result is not None
        if self._can_export != new_can_export:
            self._can_export = new_can_export
            self.canExportChanged.emit()

        self.commandExecuted.emit(command, result)

        if result.startswith("Error:"):
            self._notification.showError(
                "Command Error",
                result,
                NotificationSubType.DATABASE.value
            )
        elif command.lower().startswith(('create', 'update', 'delete')):
            self._notification.showSuccess(
                "Command Executed",
                result,
                NotificationSubType.DATABASE.value
            )






