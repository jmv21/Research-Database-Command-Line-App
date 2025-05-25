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
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../../Controls"
import "../../Components/"
import "../../js/utils.js" as Utils

Item {
    id: root
    property var settings: null

    property alias text: label.text
    property alias textColor: label.color
    property alias textFont: label.font
    property alias textPixelSize: label.font.pixelSize
    property alias spacing: column.spacing
    property color referenceColor: Material.background
    property Component contentComponent: null

    width: parent ? parent.width : 300
    height: parent ? parent.height : 200

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: 20

        // Dynamic content loader
        Loader {
            id: contentLoader
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: contentComponent
            active: contentComponent !== undefined
        }

        CustomLabel {
            id: label
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width * 0.8
            text: "No items to display"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize:  settings?.typography?.textBody ?? 14
        }
    }
}
