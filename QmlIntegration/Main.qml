
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Window
import QtQuick.Controls.Material

import io.qt.textproperties 1.0

import QmlIntegration

import "./forms"
import "./Components/"
import "./Components/Text"
import "./Controls"
import "./Components/Notifications"
import "./Views"
import "./AppComponents"

ApplicationWindow {
    id: page
    width: 1024
    height: 720
    minimumWidth: 800
    minimumHeight: 400
    visible: true
    Material.theme: Globals.materialTheme
    Material.accent: Globals.colors.primary
    title: "Research Database Manager"

    BaseBackgroundItem{
        anchors.fill: parent
    }

    Component{
        id: loginComponent
        Rectangle{
            color: Material.background
            LoginForm{
                width: parent.width * 0.4
                anchors.centerIn: parent
                onRegisterRequested: {
                    mainStack.push(registerComponent)
                }
            }
        }
    }

    Component{
        id: registerComponent
        Rectangle{
            color: Material.background
            RowLayout{
                anchors{
                    top: parent.top
                    left: parent.left
                    margins: 20
                }
                CustomMaterialToolButton{
                    icon.source: Globals.icons.leftArrow
                    onClicked: {
                         mainStack.pop()
                    }
                }

                InfoBlock{
                    Layout.fillWidth: true
                    title: "Register"
                    titlePixelSize: Globals.typography.textTitle
                    description: qsTr("Fill the form to create a new User for the app")
                }
            }

            RegisterForm{
                width: parent.width * 0.4
                anchors.centerIn: parent
                onReturnBackRequested: {
                    mainStack.pop()
                }
            }
        }
    }

    Component{
        id: mainViewComponent
        MainView{
        }
    }

    StackView{
        id: mainStack
        anchors.fill: parent
        initialItem: loginComponent
    }

    NotificationCenter {
        id: notificationCenter
        Material.background: Globals.colors.surface
        animated: Globals.animated
        Material.roundedScale: Globals.roundedScale
        closeAllButtonColor: Globals.colors.primary
        width: 350 * Globals.typography.scaleFactor
        maximunHeight: 400 *  Globals.typography.scaleFactor
        timeoutProgressBarColor: Globals.colors.tertiary
        closeAllButton.visible: closeAllButton.scale > 0
        notificationColors: ({
                                 0: Globals.colors.primary, // Info
                                 1: Globals.colors.success,      // Success
                                 2: Globals.colors.error,     // Error
                                 3: Material.Yellow      // Warning
                             })

        notificationIcons: ({
                                0: Globals.icons.info,       // Enums.NotificationTypes.Info
                                1:  Globals.icons.success,    // Enums.NotificationTypes.Success
                                2:  Globals.icons.error,      // Enums.NotificationTypes.Error
                                3:  Globals.icons.warning     // Enums.NotificationTypes.Warning
                            })

        delegateCloseButtonIconSource: Globals.icons.close
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
    }

    Connections{
        target: Globals

        function onAddNotificationRequested(notificationType, titleText, informationalText) {
            notificationCenter.addNotification(notificationType, titleText, informationalText)
        }

        function onUserLoggedInChanged() {
            console.log("User log changed", Globals.userLoggedIn)
            if (Globals.userLoggedIn) {
                mainStack.push(mainViewComponent);
            } else {
                mainStack.pop(null);
            }
        }
    }

    Connections {
        target: notificationHandler

        function onNotificationSignal(notificationType, title, content, subtype) {
            notificationCenter.addNotification(notificationType, title, content)
        }
    }

    Connections{
        target: mainController

        function onLogoutCompleted() {
            mainStack.pop()
        }
    }

    Component.onCompleted: {
    }
}
