/* Copyright (C) 2025 The Lucerum Inc
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum Inc under the QT Commercial License as agreed with The Qt Company.
 * For more details, see <https://www.qt.io/licensing/>.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

import "../Controls/"
import "./Text"

Item {
    id: control
    property bool animated: true
    property bool animatedText: animated
    property alias background: background
    property real backgroundOpacity: 0.5
    property color backgroundColor: Material.background
    property string iconSource: ""
    property color iconColor: Material.accent
    property string text: ""
    property bool running: visible
    property bool displayText: text
    property alias label: overlayText

    property int maximunHeight: 100
    property int maximunWidth: 300

    property bool showProgressBar: false
    property alias progressBarItem: progressBar
    property real progress: 0.0

    Material.roundedScale: parent.Material.roundedScale

    Component {
        id: defaultBusyIndicatorComponent
        CustomBusyIndicator {
            id: busyIndicator
            height: Math.min(control.height * 0.6, control.maximunHeight)
            width: height
            sourceImage: control.iconSource
            sourceImageColor: control.Material.accent
            running: control.running && visible
        }
    }

    Pane{
        anchors.fill: parent
        Material.roundedScale: control.Material.roundedScale
        background: Rectangle {
            id: background
            anchors.fill: parent
            radius: control.Material.roundedScale
            color: control.backgroundColor
            opacity: control.backgroundOpacity
        }
    }

    ColumnLayout{
        anchors.centerIn: parent
        spacing: 5

        Loader {
            id: busyIndicatorLoader
            sourceComponent: defaultBusyIndicatorComponent
            Layout.alignment: Qt.AlignHCenter
        }

        ProgressBar{
            id: progressBar
            visible: control.showProgressBar
            from: 0
            to: 100
            value: control.progress
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
        }

        AnimatedLabel {
            id: overlayText
            animated: control.animatedText
            currentLabel.horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: control.maximunWidth > 0 ? maximunWidth : implicitWidth
            text: control.displayText ? control.text : ""
            referenceBackgroundColor: background.color
            visible: displayText
            Layout.alignment: Qt.AlignHCenter
        }
    }



    function showOverlay(withText) {
        control.visible = true
        control.displayText = withText
    }

    function showText(text){

    }

    function hideOverlay() {
        control.visible = false
    }
}
