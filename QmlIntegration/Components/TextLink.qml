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

import "../Controls/"

CustomLabel{
    property bool animated: true
    property alias mArea: linkMArea
    textColor: !enabled ? Material.hintTextColor : Material.foreground
    color: Material.theme === Material.Dark ? Qt.lighter(textColor,linkMArea.containsMouse ? 1.2 :0) : Qt.darker(textColor,linkMArea.containsMouse ? 1.2 :0)
    scale: linkMArea.pressed ? 0.95 : 1.0
    signal clicked
    MouseArea {
        id: linkMArea
        hoverEnabled: true
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            parent.clicked()
        }
    }
    Behavior on scale{
        NumberAnimation{duration: animated ? 100 : 0}
    }
}
