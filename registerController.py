from PySide6.QtCore import QObject, Signal, Slot

class RegisterController(QObject):
    registrationStarted = Signal()
    registrationSucceeded = Signal()
    registrationFailed = Signal(str, dict)

    def __init__(self, auth_service):
        super().__init__()
        self._auth = auth_service

        # Connect auth service signals
        self._auth.registration_started.connect(self.registrationStarted)
        self._auth.registration_success.connect(self.registrationSucceeded)
        self._auth.registration_failed.connect(self.registrationFailed)

    @Slot(dict)
    def register(self, form_data: dict):
        self._auth.register(form_data)
