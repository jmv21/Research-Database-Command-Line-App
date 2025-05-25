/* Copyright (C) 2024 The Lucerum LLC
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum LLC under the QT Commercial License as agreed with The Qt Company.
 * For more details, see <https://www.qt.io/licensing/>.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts

import "../../Controls/"
import "../../Components/"

// Use example:
// NotificationCenter{
//     id: notificationCenter
//     Material.roundedScale: Globals.roundedScale
//     closeAllButtonColor: Globals.colors.primary
//     width: 300 * Globals.scaleFactor
//     height: 400 * Globals.scaleFactor + closeAllButton.height
//     timeoutProgressBarColor: Globals.colors.tertiary

//     delegateCloseButtonIconSource: "qrc:/assets/icons/close.svg"
//     anchors{
//         bottom: parent.bottom
//         left: parent.left
//     }
// }

Item {
    id: root
    property bool animated: true
    property int timeout: 8000
    property color timeoutProgressBarColor: Material.primary

    property var notificationColors: ({
                                          0: root.Material.primary,  // Enums.NotificationTypes.Info
                                          1: Material.Green,   // Enums.NotificationTypes.Success
                                          2: Material.Red,     // Enums.NotificationTypes.Error
                                          3: Material.Yellow   // Enums.NotificationTypes.Warning
                                      })

    property var notificationIcons: ({
                                         0: "qrc:/assets/icons/info.svg",       // Enums.NotificationTypes.Info
                                         1: "qrc:/assets/icons/success.svg",    // Enums.NotificationTypes.Success
                                         2: "qrc:/assets/icons/error.svg",      // Enums.NotificationTypes.Error
                                         3: "qrc:/assets/icons/warning.svg"     // Enums.NotificationTypes.Warning
                                     })

    property bool hovered: listViewHoverhandler.hovered
    onHoveredChanged: {
        if(hovered){
            timingProgressBarAnimation.stop()
            progressBar.value = progressBar.top
        }
        else if(notificationsListView.count > 0){
            timingProgressBarAnimation.restart()
        }
    }
    property int margins: 20
    property int maximunHeight: 1
    implicitHeight: maximunHeight + closeAllButton.height
    height: Math.max(1, Math.min(notificationsListView.contentHeight + ((closeAllButton.visible || notificationsListView.count > 0)
                                                                        ? closeAllButton.height : 0), implicitHeight))
    property alias closeAllButton: closeAllButton
    property color closeAllButtonColor: Material.accent
    property string delegateCloseButtonIconSource: ""

    property ListModel notificationsListModel: ListModel {}

    property DelegateModel notificationsDelegateModel: DelegateModel {
        model: notificationsListModel
        delegate: Item {
            width: implicitWidth
            implicitWidth: parent ? parent.width - 10 : 0
            height: implicitHeight
            implicitHeight: toastNotificationDelegate.implicitHeight
            ToastMaterialNotification {
                id: toastNotificationDelegate
                onRequestCopyToClipboard:(text)=>{
                                             root.requestCopyToClipboard(text)
                                         }
                width: parent ? parent.width : 0
                Material.accent: root.getNotificationColor(model.type)
                Material.background: root.Material.background
                titleText: model.titleText
                informationalText: model.informationalText
                notificationIconSource: root.getNotificationIcon(model.type)
                closeButtonIconSource: root.delegateCloseButtonIconSource
                onCloseButtonClicked: {
                    root.removeNotification(index)
                }
            }
        }
    }

    property ListView notificationsListView: ListView {
        parent: contentItem
        spacing: 10
        verticalLayoutDirection: ListView.ListView.BottomToTop
        model: notificationsDelegateModel
        anchors{
            fill: parent
            rightMargin: vrtScrllBar.width
            topMargin: root.margins
            leftMargin: root.margins
            bottomMargin: root.margins
        }

        cacheBuffer: 5000
        interactive: contentHeight > height

        snapMode: ListView.SnapToItem

        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: CustomScrollBar {
            id: vrtScrllBar
            policy: ScrollBar.AlwaysOn
            topInset: -root.margins + progressBar.height + 8
            topPadding: topInset
            bottomInset: -8
            bottomPadding: -8
        }

        add: Transition {
            ParallelAnimation{
                onFinished: notificationsListView.forceLayout()
                NumberAnimation { properties: "scale"; from:0; to: 1; duration: root.animated ? 400 : 0}
                NumberAnimation{properties: "opacity"; from: 0; to: 1;  duration: root.animated ? 400 : 0}
            }
        }

        remove: Transition {
            ParallelAnimation{
                NumberAnimation{properties: "opacity"; to: 0;  duration: root.animated ? 350 : 0}
                NumberAnimation { properties: "y"; to: 100; duration: root.animated ? 350 : 0}
            }
        }

        addDisplaced: Transition{
            NumberAnimation { properties: "x,y"; duration: root.animated ? 400 : 0}
        }

        removeDisplaced: Transition{
            NumberAnimation { properties: "x,y"; duration: root.animated ? 400 : 0}
        }
    }

    signal requestCopyToClipboard(string text)
    signal timeoutTriggered
    onTimeoutTriggered: {
        root.clearNotifications()
    }

    Item{
        id: contentItemPlaceholder
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.implicitHeight

        Item{
            id: contentItem
            clip: true
            anchors.bottom: parent.bottom
            width: parent.width
            height: root.implicitHeight - closeAllButton.height - root.margins - 10
        }

        CustomMaterialButton{
            id: closeAllButton
            visible: scale > 0
            x: root.margins
            y: Math.max(root.margins*2, (contentItem.height - notificationsListView.contentHeight))
            Behavior on y{
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: root.animated ? 400 : 0
                }
            }
            scale: notificationsListView.count > 1 ? 1 : 0
            Behavior on scale{
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: root.animated ? 280 : 0
                }
            }

            width: notificationsListView.width - (vrtScrllBar.visible ? 0 : vrtScrllBar.width)
            Behavior on width {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: root.animated ? 280 : 0
                }
            }
            text: qsTr("Close All") + (notificationsListView.count > 0 ? " (" + notificationsListView.count  + ")" : "")
            backgroundColor: root.closeAllButtonColor
            onClicked: {
                root.clearNotifications()
            }
        }

        ProgressBar {
            id: progressBar
            x: closeAllButton.x
            from: 0
            to: 100
            value: 100
            opacity: ((notificationsListView && notificationsListView.count > 0) || timingProgressBarAnimation.running) && !root.hovered  ? 1 : 0
            Material.accent: root.timeoutProgressBarColor
            Behavior on opacity {
                OpacityAnimator{
                    duration: root.animated ? 280 : 0
                }
            }
            anchors.bottom: closeAllButton.bottom
            Material.roundedScale: root.Material.roundedScale
            width: closeAllButton.width

            NumberAnimation {
                id: timingProgressBarAnimation
                target: progressBar
                property: "value"
                from: 100
                to: 0
                duration: root.timeout
                onFinished: {
                    root.timeoutTriggered()
                }
            }
        }
    }

    Connections{
        target: notificationsListView

        function onCountChanged(){
            if(notificationsListView.count === 0){
                timingProgressBarAnimation.complete()
            }
            else {
                timingProgressBarAnimation.restart()
            }
        }
    }

    // Item {
    //     id: someItem
    //     width: parent.width
    //     height: Math.min(notificationsListView.contentHeight, contentItem.height) + (closeAllButton.visible ? root.margins: 0)
    //     anchors.bottom: parent.bottom
    // }

    HoverHandler{
        // target: someItem
        // parent: someItem
        id: listViewHoverhandler
    }

    function getNotificationColor(type) {
        return notificationColors[type] || "black";
    }

    function getNotificationIcon(type) {
        return notificationIcons[type] || "";
    }

    function addNotification(notificationType, titleText, informationalText) {
        notificationsListModel.append({
                                          type: notificationType,
                                          titleText: titleText,
                                          informationalText: informationalText
                                      });
        notificationsListView.positionViewAtEnd()
    }

    function removeNotification(index) {
        if (notificationsListModel.hasIndex(index,0)) {
            notificationsListModel.remove(index);
        } else {
            console.warn("Attempted to remove notification at index", index,
                         "- Invalid index. Please ensure the index is within the range of 0 to",
                         Math.min(notificationsListModel.count - 1, 0),
                         "to avoid errors.");
        }
    }

    function clearNotifications(){
        notificationsListModel.clear()
    }
}
