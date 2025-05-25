from PySide6.QtCore import QObject, Signal, Slot, Property
from enum import IntEnum

class AuthState(IntEnum):
    NOT_LOGGED_IN = 0
    LOGGING_IN = 1
    LOGGED_IN = 2
    REGISTERING = 3

class AuthService(QObject):
    login_started = Signal()
    login_success = Signal(dict)
    login_failed = Signal(str)    # emits error message

    registration_started = Signal()
    registration_success = Signal()
    registration_failed = Signal(str, dict)  # error message, field errors

    stateChanged = Signal(AuthState)
    current_user_changed = Signal(dict)  # emits user data when changed

    def __init__(self, db_handler, notification_handler):
        super().__init__()
        self._db_handler = db_handler
        self._notification = notification_handler
        self._state = AuthState.NOT_LOGGED_IN
        self._current_user = None

        self._db_handler.login_success.connect(self._handle_db_login_success)
        self._db_handler.login_failed.connect(self._handle_db_login_failed)
        self._db_handler.register_success.connect(self._handle_db_register_success)
        self._db_handler.register_failed.connect(self._handle_db_register_failed)

    # Properties
    @Property(int, notify=stateChanged)
    def state(self):
        return int(self._state)


    @state.setter
    def state(self, value):
        if self._state != value:
            self._state = AuthState(value)  # Convert to enum
            self.stateChanged.emit(int(self._state))  # Emit as int

    @property
    def current_user(self):
        return self._current_user

    @current_user.setter
    def current_user(self, value):
        self._current_user = value
        self.current_user_changed.emit(value)

    # Public methods
    @Slot(str, str)
    def login(self, username: str, password: str):
        """Initiate login process"""
        if self.state == AuthState.LOGGING_IN:
            return

        if not username or not password:
            self._notification.show_error(
                "Login Error",
                "Username and password are required",
                "authentication"
            )
            return

        self.state = AuthState.LOGGING_IN
        self.login_started.emit()
        self._db_handler.login(username, password)

    @Slot()
    def logout(self):
        """Clear authentication state"""
        self.state = AuthState.NOT_LOGGED_IN
        self.current_user = None
        self._notification.showInfo(
            "Logged Out",
            "You have been successfully logged out",
            "authentication"
        )

    @Slot(dict)
    def register(self, form_data: dict):
        """Handle user registration"""
        if self.state == AuthState.REGISTERING:
            return

        # Validate form data
        field_errors = self._validate_registration_form(form_data)
        if field_errors:
            error_msg = "Please correct the form errors"
            self.registration_failed.emit(error_msg, field_errors)
            self._notification.showError(
                "Registration Failed",
                error_msg,
                "authentication"
            )
            return

        self.state = AuthState.REGISTERING
        self._pending_credentials = {
            'username': form_data['username'].strip(),
            'password': form_data['password']
        }
        self.registration_started.emit()

        try:
            self._db_handler.register(
                form_data['username'].strip(),
                form_data['password'],
                form_data['full_name'].strip(),
                form_data['email'].strip()
            )
        except Exception as e:
            self.state = AuthState.NOT_LOGGED_IN
            self.registration_failed.emit(str(e), {})
            self._notification.show_error(
                "Registration Error",
                str(e),
                "authentication"
            )

    # Private methods
    def _validate_registration_form(self, form_data: dict) -> dict:
        """Validate registration form data"""
        errors = {}

        if not form_data.get('username', '').strip():
            errors['username'] = "Username is required"
        elif len(form_data['username'].strip()) < 4:
            errors['username'] = "Username must be at least 4 characters"

        if not form_data.get('password'):
            errors['password'] = "Password is required"
        elif len(form_data['password']) < 8:
            errors['password'] = "Password must be at least 8 characters"
        elif form_data['password'] != form_data.get('confirm_password', ''):
            errors['confirm_password'] = "Passwords do not match"

        if not form_data.get('full_name', '').strip():
            errors['full_name'] = "Full name is required"
        elif len(form_data['full_name'].strip()) < 2:
            errors['full_name'] = "Full name must be at least 2 characters"

        email = form_data.get('email', '').strip()
        if not email:
            errors['email'] = "Email is required"
        elif '@' not in email or '.' not in email:
            errors['email'] = "Invalid email format"

        return errors

    # Database signal handlers
    def _handle_db_login_success(self, user_data):
        """Handle successful login from database"""
        self.state = AuthState.LOGGED_IN
        self.current_user = user_data
        self.login_success.emit(user_data)
        self._notification.showSuccess(
            "Login Successful",
            f"Welcome back, {user_data['full_name']}",
            "authentication"
        )

    def _handle_db_login_failed(self):
        """Handle failed login from database"""
        self.state = AuthState.NOT_LOGGED_IN
        error_msg = "Invalid username or password"
        self.login_failed.emit(error_msg)
        self._notification.showError(
            "Login Failed",
            error_msg,
            "authentication"
        )

    def _handle_db_register_success(self):
        """Handle successful registration from database"""
        self.state = AuthState.NOT_LOGGED_IN
        self.registration_success.emit()
        self._notification.showSuccess(
            "Registration Successful",
            "Your account has been created successfully",
            "authentication"
        )

        # Auto-login after registration
        if hasattr(self, '_pending_credentials'):
            self.login(
                self._pending_credentials['username'],
                self._pending_credentials['password']
            )
            del self._pending_credentials

    def _handle_db_register_failed(self):
        """Handle failed registration from database"""
        self.state = AuthState.NOT_LOGGED_IN
        error_msg = "Registration failed (username or email may already exist)"
        field_errors = {
            'username': "Username may already exist",
            'email': "Email may already exist"
        }
        self.registration_failed.emit(error_msg, field_errors)
        self._notification.show_error(
            "Registration Failed",
            error_msg,
            "authentication"
        )
