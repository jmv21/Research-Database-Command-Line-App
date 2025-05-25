/* Copyright (C) 2024 The Lucerum Inc.
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum Inc. under the QT Commercial License as agreed with The Qt Company.
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

import "../../Controls"
import "../../Components/"
import "../../js/utils.js" as Utils

Pane {
    id: control
    width: 300
    height: 60
    opacity: 0.9
    Material.background: parent.Material.tooltipColor
    Material.roundedScale: Material.SmallScale
    anchors.horizontalCenter: parent.horizontalCenter

    property alias notificationLabel: notificationLabel

    // Initial position (below screen)
    y: mainWindow.height
    visible: false

    // Notification text
    CustomLabel {
        id: notificationLabel
        anchors.centerIn: parent
        backgroundColor: control.Material.background
        font.pixelSize: 16
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    // Queue for pending messages
    property var messageQueue: []
    property int timeoutDuration: 2000  // 2 seconds timeout
    property bool isVisible: false

    // States
    states: [
        State {
            name: "hidden"
            when: !control.isVisible
            PropertyChanges {
                target: control
                y: control.parent.height
                visible: false
            }
        },
        State {
            name: "visible"
            when: control.isVisible
            PropertyChanges {
                target: control
                y: control.parent.height - control.height - 20
                visible: true
            }
        }
    ]

    // Transitions
    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            NumberAnimation {
                target: control
                property: "y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        },
        Transition {
            from: "visible"
            to: "hidden"
            SequentialAnimation {
                NumberAnimation {
                    target: control
                    property: "y"
                    duration: 300
                    easing.type: Easing.InQuad
                }
                PropertyAction {
                    target: control
                    property: "visible"
                    value: false
                }
                ScriptAction {
                    script: control.processNextMessage()
                }
            }
        }
    ]

    MouseArea{
        anchors.fill: parent
        anchors.margins: -control.padding
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            hideTimer.restart()
            hideTimer.triggered()
        }
        onContainsMouseChanged: {
            if(containsMouse){
                hideTimer.stop()
            }
            else {
                hideTimer.restart()
            }
        }
    }

    // Timer for auto-hiding
    Timer {
        id: hideTimer
        interval: control.timeoutDuration
        running: false
        onTriggered: {
            if (control.messageQueue.length === 0) {
                control.isVisible = false
            } else {
                control.processNextMessage()
            }
        }
    }

    // Function to show notification
    function show(message) {
        if (control.isVisible) {
            // If currently showing, add to queue and hide
            messageQueue.push(message)
            control.isVisible = false
        } else {
            // Show immediately
            notificationLabel.text = message
            control.isVisible = true
            hideTimer.restart()
        }
    }

    // Process next message in queue
    function processNextMessage() {
        if (messageQueue.length > 0) {
            let nextMessage = messageQueue.shift()
            notificationLabel.text = nextMessage
            control.isVisible = true
            hideTimer.restart()
        }
    }
}
