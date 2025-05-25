from __future__ import annotations

import sys

from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement
from PySide6.QtQuickControls2 import QQuickStyle
from notificationHandler import NotificationHandler
from databaseHandler import DatabaseHandler
from mainController import MainController
from authService import AuthService
from registerController import RegisterController

import resources_rc

# import rc_style  # noqa F401

# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "io.qt.textproperties"
QML_IMPORT_MAJOR_VERSION = 1

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()

    notification_handler = NotificationHandler()
    db_handler = DatabaseHandler(notification_handler)

    auth_service = AuthService(db_handler, notification_handler)

    main_controller = MainController(db_handler, notification_handler, auth_service)
    register_controller = RegisterController(auth_service)

    engine.addImportPath(sys.path[0])

    engine.rootContext().setContextProperty("notificationHandler", notification_handler)
    engine.rootContext().setContextProperty("mainController", main_controller)
    engine.rootContext().setContextProperty("registerController", register_controller)
    engine.rootContext().setContextProperty("authService", auth_service)
    engine.loadFromModule("QmlIntegration", "Main")


    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)
