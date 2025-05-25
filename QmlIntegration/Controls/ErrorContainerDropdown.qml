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
import QtQuick.Controls
import QtQuick.Controls.Material

/*Use example
ApplicationWindow {
    id: mainWindow
    minimumWidth: 640
    minimumHeight: 480
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ErrorContainerDropdown{
        id: errorDropdown
        text: "Connection lost. Reconecting..."
        width: parent.width
        height: 30
        Material.background: "#636F81"
    }
    Button{
        anchor.fill: parent
        onClicked:{
            errorDropdown.opened ? errorDropdown.close() : errorDropdown.open()
        }
    }
}*/

Pane {
    id: control
    property int openDelay: 500
    property bool animated: true
    property alias errorDropdownContent: errorDropdownContent
    property alias defaultErrorDropdownContent: defaultErrorDropdownContent
    property string text: ""
    property string backgroundColor: Material.background
    property bool opened: false
    y: -height

    Component {
        id: defaultErrorDropdownContent
        Item{
            anchors.fill:parent
            CustomLabel{
                id: label
                backgroundColor: control.backgroundColor
                text: control.text
                font.pixelSize: 18
                anchors.centerIn: parent
            }
        }
    }

    Loader {
        id: errorDropdownContent
        anchors.fill: parent
        sourceComponent: control.defaultErrorDropdownContent
    }

    onOpenedChanged: {
        y = opened ? 0 : -height
    }

    function open(){
        closeAnimation.stop()
        openAnimation.restart()
    }

    function close(){
        openAnimation.stop()
        closeAnimation.restart()
    }


    SequentialAnimation{
        id: openAnimation
        onStarted: {
            visible = true
        }

        PauseAnimation {
            duration: control.animated && y===0 ? control.openDelay : 0
        }

        SmoothedAnimation{
            target: control
            property: "y"
            to: 0
            duration: 500
            easing.type: Easing.OutBack
            onFinished: {
                opened = true
            }
            alwaysRunToEnd: true
        }
    }

    SmoothedAnimation{
        id: closeAnimation
        target: control
        property: "y"
        to: -height
        duration: 500
        easing.type: Easing.OutBack
        onFinished: {
            opened =  false
            visible = false
        }
        alwaysRunToEnd: true
    }
}
