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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../../Controls"
import "../../Components/"

T.RoundButton {
    id: control
    property color backgroundColor: Material.background
    property color referenceBackgroundColor: Material.background
    property alias backgroundOpacity: background.opacity
    property alias backgroundBorder: background.border
    property alias hoverHandler: hoverHandler
    property string tooltipText: ""
    Material.background: backgroundColor
    property bool tooltipVisible: hoverHandler.hovered && tooltipText
    property bool iconLabelVisible: true
    property color currentBackgroundColor: control.Material.buttonColor(control.Material.theme, control.Material.background,
                                                                        control.Material.accent, control.enabled, control.flat, control.highlighted, control.checked)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topInset: 6
    leftInset: 6
    rightInset: 6
    bottomInset: 6
    padding: 12
    spacing: 6

    icon.width: 24
    icon.height: 24
    icon.color: !enabled ? Material.hintTextColor :
                           flat && highlighted ? Material.accentColor :
                                                 highlighted ? Material.primaryHighlightedTextColor : Material.foreground

    Material.elevation: control.down ? 8 : 2

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? control.Material.hintTextColor :
                                  control.flat && control.highlighted ? control.Material.accentColor :
                                                                        control.highlighted ? control.Material.primaryHighlightedTextColor : control.Material.foreground
    }

    // TODO: Add a proper ripple/ink effect for mouse/touch input and focus state
    background: Rectangle {
        id: background
        implicitWidth: control.Material.buttonHeight
        implicitHeight: control.Material.buttonHeight

        radius: control.radius
        color: control.currentBackgroundColor

        // Rectangle {
        //     width: parent.width
        //     height: parent.height
        //     radius: control.radius
        //     visible: enabled && (control.hovered || control.visualFocus)
        //     color: control.Material.rippleColor
        // }

        // Rectangle {
        //     width: parent.width
        //     height: parent.height
        //     radius: control.radius
        //     visible: control.down
        //     color: control.Material.rippleColor
        // }

        // The layer is disabled when the button color is transparent so that you can do
        // Material.background: "transparent" and get a proper flat button without needing
        // to set Material.elevation as well
        layer.enabled: control.enabled && color.a > 0 && !control.flat || background.opacity >= 1
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        Ripple {
            clip: true
            clipRadius: parent.radius
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus || control.hovered)
            color: control.flat && control.highlighted ? control.Material.highlightedRippleColor : control.Material.rippleColor
        }
    }

    HoverHandler{
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    CustomMaterialToolTip{
        id: defaultToolTip
        visible: tooltipVisible
        text: control.tooltipText
    }
}
