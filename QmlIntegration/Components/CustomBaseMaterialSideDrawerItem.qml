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
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl


Item {
    id: control
    property bool animated: true
    property real xZero: 0
    property real yZero: 0
    property real leftInset: 0
    property real rightInset: 0
    property real topInset: 0
    property real bottomInset: 0
    property real leftPadding: 0
    property real rightPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0
    property bool opened: position === 1
    property real position: 0
    property int edge: Qt.LeftEdge
    property alias background: background
    property real backgroundOpacity: 1
    property color backgroundColor: control.Material.dialogColor
    z: 5

    property Transition enter: Transition {
        from: "closed"
        to: "open"
        enabled: control.animated
        SmoothedAnimation {
            target: control
            property: "position"
            velocity: 5
        }
    }

    property Transition exit: Transition {
        from: "open"
        to: "closed"
        enabled: control.animated
        SmoothedAnimation {
            target: control
            property: "position"
            velocity: 5
        }
    }

    state: "closed"
    width: edge === Qt.TopEdge || edge === Qt.BottomEdge ? parent.width : 300
    height: edge === Qt.LeftEdge || edge === Qt.RightEdge ? parent.height : 300
    x: edge === Qt.LeftEdge ? Math.max((1 - position) * (-width) - leftInset, -width + rightInset) :
                              edge === Qt.RightEdge ? parent.width - (position * width) - rightInset : xZero
    y: edge === Qt.TopEdge ? (1 - position) * (-height) - topInset :
                             edge === Qt.BottomEdge ? parent.height - (position * height) - bottomInset : yZero

    onEnterChanged: {
        openTransition.from = "closed"
        openTransition.to = "open"
    }

    onExitChanged: {
        closeTransition.from = "open"
        closeTransition.to = "closed"
    }

    Pane {
        anchors.fill: parent
        Material.background: "transparent"
        Material.roundedScale: control.Material.roundedScale
    }

    PaddedRectangle {
        id: background
        anchors.fill: parent
        color: control.backgroundColor
        radius: control.Material.roundedScale
        leftPadding: edge === Qt.LeftEdge ? -radius : 0
        rightPadding: edge === Qt.RightEdge ? -radius : 0
        topPadding: edge === Qt.TopEdge ? -radius : 0
        bottomPadding: edge === Qt.BottomEdge ? -radius : 0
        opacity: control.backgroundOpacity

        layer.enabled: opacity >= 1 && control.x > -width && control.Material.elevation > 0
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }
    }

    states: [
        State {
            name: "open"
            PropertyChanges {
                target: control
                position: 1
            }
        },
        State {
            name: "closed"
            PropertyChanges {
                target: control
                position: 0
            }
        }
    ]

    transitions: [
        control.enter,
        control.exit
    ]

    function open() {
        control.state = "open"
    }

    function close() {
        control.state = "closed"
    }
}
