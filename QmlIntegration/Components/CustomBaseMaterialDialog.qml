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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls"

T.Dialog {
    id: control
    property real titlePixelSize: Material.dialogTitleFontPixelSize
    property int titleWeight: 400
    property color titleColor: Material.foreground
    property color backgroundColor: Material.dialogColor
    property var standardButtonRoundness: Material.ExtraSmallScale

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            implicitHeaderWidth,
                            implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding
                             + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                             + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    padding: 24
    topPadding: 16
    modal: true

    Material.elevation: 6
    Material.roundedScale: Material.dialogRoundedScale

    enter: Transition {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    exit: Transition {
        // shrink_fade_out
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    background: Rectangle {
        id: backgrndRect
        radius: control.Material.roundedScale
        color: control.backgroundColor

        layer.enabled: control.Material.elevation > 0
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }
    }

    header: CustomLabel {
        text: control.title
        maximumLineCount: 1
        backgroundColor: control.backgroundColor
        visible: control.title
        padding: control.padding
        bottomPadding: 0
        font.pixelSize: control.titlePixelSize
        font.weight: control.titleWeight
        color: control.titleColor ? control.titleColor : textColor
        background: PaddedRectangle {
            radius: control.background.radius
            color: control.backgroundColor
            bottomPadding: -radius
            clip: true
        }
    }

    footer: CustomMaterialDialogButtonBox {
        visible: count > 0
        Material.roundedScale: control.Material.roundedScale
        buttonRoundness: control.standardButtonRoundness
    }

    T.Overlay.modal: Rectangle {
        color: control.Material.backgroundDimColor
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    T.Overlay.modeless: Rectangle {
        color: control.Material.backgroundDimColor
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}

