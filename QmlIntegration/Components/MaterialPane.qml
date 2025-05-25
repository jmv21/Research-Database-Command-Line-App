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
import QtQuick.Controls.impl
import QtQuick.Templates as T
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../js/utils.js" as Utils

T.Pane {
    id: control
    property color referenceBackgroundColor: Material.background
    property real contrast: 0.03
    property color backgroundColor: Utils.adjustColorForContrast(referenceBackgroundColor, Material.background, contrast)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12
    Material.roundedScale: control.Material.elevation > 0 ? Material.ExtraSmallScale : Material.NotRounded

    background: Rectangle {
        color: control.backgroundColor
        radius: control.Material.roundedScale

        layer.enabled: control.enabled && control.Material.elevation > 0
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }
    }
}
