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
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls/"

MaterialTag {
    id: control
    padding: 5
    verticalPadding: 0
    rightPadding: 0
    spacing: 5
    property string iconSource: ""
    property color iconColor: control.labelTextColor
    signal rigthButtonClicked
    rightSideComponent: CustomMaterialToolButton{
        anchors.top: parent.top
        anchors.topMargin: 1
        icon.source: control.iconSource
        icon.color: control.iconColor
        focusPolicy: Qt.NoFocus
        onClicked: {
            control.rigthButtonClicked()
        }
    }
}
