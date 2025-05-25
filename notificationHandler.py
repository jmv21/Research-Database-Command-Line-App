from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QQmlEngine
from enum import Enum, IntEnum

class NotificationIconType(IntEnum):
    INFO = 0
    SUCCESS = 1
    ERROR = 2
    WARNING = 3

class NotificationSubType(Enum):
    DATABASE = "database"
    AUTHENTICATION = "auth"
    VALIDATION = "validation"
    SYSTEM = "system"
    GENERAL = "general"

class NotificationHandler(QObject):
    notificationSignal = Signal(int, str, str, str)  # icon_type, title, content, subtype

    def __init__(self, parent=None):
        super().__init__(parent)

    # QML-callable methods
    @Slot(str, str)
    @Slot(str, str, str)
    def showInfo(self, title: str, content: str, subtype: str = "general"):
        self.notificationSignal.emit(
            int(NotificationIconType.INFO),
            title,
            content,
            subtype
        )
    @Slot(str, str)
    @Slot(str, str, str)
    def showSuccess(self, title: str, content: str, subtype: str = "general"):
        self.notificationSignal.emit(
            int(NotificationIconType.SUCCESS),
            title,
            content,
            subtype
        )
    @Slot(str, str)
    @Slot(str, str, str)
    def showError(self, title: str, content: str, subtype: str = "general"):
        self.notificationSignal.emit(
            int(NotificationIconType.ERROR),
            title,
            content,
            subtype
        )

    @Slot(str, str)
    @Slot(str, str, str)
    def showWarning(self, title: str, content: str, subtype: str = "general"):
        self.notificationSignal.emit(
            int(NotificationIconType.WARNING),
            title,
            content,
            subtype
        )

    # Expose enum values as properties
    @Property(int, constant=True)
    def INFO(self):
        return int(NotificationIconType.INFO)

    @Property(int, constant=True)
    def SUCCESS(self):
        return int(NotificationIconType.SUCCESS)

    @Property(int, constant=True)
    def ERROR(self):
        return int(NotificationIconType.ERROR)

    @Property(int, constant=True)
    def WARNING(self):
        return int(NotificationIconType.WARNING)
