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
import QtQuick.Layouts

import "../js/utils.js" as Utils


Label{
    property color backgroundColor: "transparent"
    property var getTextColor: Utils.getTextColor
    property color textColor: backgroundColor.toString() !== "#00000000" ? getTextColor(backgroundColor) : Material.foreground

    Layout.alignment: Qt.AlignVCenter
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    elide: Label.ElideRight
    color: textColor
}




