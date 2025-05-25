// TumblerDelegate.qml

/* Copyright (C) 2025 The Lucerum Inc.
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

import "../../Controls"
import "../../Components/"
import "../../js/utils.js" as Utils

Item{
    id: control
    required property real displacement
    required property bool current

    property int visibleItems: 5
    property alias internalLabel: internalLabel
    property color highlightColor: Qt.lighter(internalLabel.textColor, 1.3)

    implicitHeight: internalLabel.implicitHeight
    implicitWidth: internalLabel.implicitWidth

    CustomLabel {
        id: internalLabel
        anchors.centerIn: parent

        // Size properties
        height: implicitHeight
        width: parent ? parent.width : 100

        // Visual properties
        color: control.current ? control.highlightColor : internalLabel.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        maximumLineCount: 2

        readonly property real minOpacity: 0.3
        readonly property real maxOpacity: 1.0
        opacity: {
            const absDisp = Math.abs(control.displacement);
            if (absDisp > 2) return minOpacity;
            return maxOpacity - (absDisp * ((maxOpacity - minOpacity) / 2));
        }

        readonly property real maxRotation: 13 // Maximum rotation angle (degrees)
        readonly property real maxScaleReduction: 0.3 // Maximum scaling reduction
        readonly property real perspectiveStrength: 180 // Perspective effect strength

        // Dynamic calculations
        readonly property real rotationAngle: {
            const easedDisplacement = control.displacement * Math.abs(control.displacement);
            return easedDisplacement * maxRotation;
        }

        readonly property real scaleFactor: {
            1.0 - Math.min(Math.pow(Math.abs(control.displacement), 1.5) * 0.3, maxScaleReduction)
        }

        // Transformations
        transform: [
            Matrix4x4 {
                property real p: internalLabel.perspectiveStrength
                matrix: Qt.matrix4x4(
                            1, 0, 0, 0,
                            0, 1, 0, -0.001 * p,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                            )
            },

            Rotation {
                origin.x: internalLabel.width / 2
                origin.y: internalLabel.height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: internalLabel.rotationAngle
            },

            Scale {
                origin.x: internalLabel.width / 2
                origin.y: internalLabel.height / 2
                xScale: internalLabel.scaleFactor * (1 + Math.abs(control.displacement) * 0.1)
                yScale: internalLabel.scaleFactor
            }
        ]

        //-----------------------------
        // Debug Visualization (optional)
        //-----------------------------
        /*
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "red"
            border.width: 1
            visible: debugMode
        }
        */
    }
}
