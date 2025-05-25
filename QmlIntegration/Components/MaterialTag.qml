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
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls/"

Pane{
    id: control
    property color fontColor: "transparent"
    property color backgroundColor: Material.hintTextColor
    property  int maximunLabelWidth: -1
    property string text: ""
    property int backgroundBorderWidth: 0
    property color backgroundBorderColor: backgroundColor
    property alias label: statusLabel
    property alias labelTextColor: statusLabel.color
    property alias rightSideComponent: rightSideComponentLoader.sourceComponent

    Material.background: backgroundColor
    Material.roundedScale: Material.SmallScale

    background: Rectangle {
        color: control.Material.backgroundColor
        radius: control.Material.roundedScale
        border.width: control.backgroundBorderWidth
        border.color: control.backgroundBorderColor

        layer.enabled: control.enabled && control.Material.elevation > 0
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }
    }

    contentItem: RowLayout
    {
        id: contentLayout
        width: parent.width
        spacing: control.spacing

        CustomLabel {
            id: statusLabel
            Layout.preferredWidth: maximunLabelWidth > 0 ? Math.min(control.maximunLabelWidth, implicitWidth) : implicitWidth
            width: Layout.preferredWidth
            backgroundColor: control.Material.background
            color: control.fontColor && control.fontColor.toString() !== "#00000000" ? control.fontColor : textColor
            text: control.text
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 1
        }

        Loader{
            id: rightSideComponentLoader
            Layout.alignment: Qt.AlignRight
            sourceComponent: null
        }
    }
}
