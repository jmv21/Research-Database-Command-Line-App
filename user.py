# user.py
from PySide6.QtCore import QObject, Property, Signal

class User(QObject):
    def __init__(self, user_data=None, parent=None):
        super().__init__(parent)
        self._user_id = user_data.get('user_id', -1) if user_data else -1
        self._username = user_data.get('username', '') if user_data else ''
        self._full_name = user_data.get('full_name', '') if user_data else ''
        self._role = user_data.get('role', '') if user_data else ''
        self._email = user_data.get('email', '') if user_data else ''

    userIdChanged = Signal()
    @Property(int, notify=userIdChanged)
    def userId(self):
        return self._user_id

    usernameChanged = Signal()
    @Property(str, notify=usernameChanged)
    def username(self):
        return self._username

    fullNameChanged = Signal()
    @Property(str, notify=fullNameChanged)
    def fullName(self):
        return self._full_name

    roleChanged = Signal()
    @Property(str, notify=roleChanged)
    def role(self):
        return self._role

    emailChanged = Signal()
    @Property(str, notify=emailChanged)
    def email(self):
        return self._email

    def update(self, user_data):
        changed = False

        if user_data.get('user_id') != self._user_id:
            self._user_id = user_data.get('user_id', self._user_id)
            self.userIdChanged.emit()
            changed = True

        if user_data.get('username') != self._username:
            self._username = user_data.get('username', self._username)
            self.usernameChanged.emit()
            changed = True

        if user_data.get('full_name') != self._full_name:
            self._full_name = user_data.get('full_name', self._full_name)
            self.fullNameChanged.emit()
            changed = True

        if user_data.get('role') != self._role:
            self._role = user_data.get('role', self._role)
            self.roleChanged.emit()
            changed = True

        if user_data.get('email') != self._email:
            self._email = user_data.get('email', self._email)
            self.emailChanged.emit()
            changed = True

        return changed
