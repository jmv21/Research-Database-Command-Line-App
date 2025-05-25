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


// Use example:
//CustomMaterialButton{
//    icon.source: "file:///C:/Users/jmv21/OneDrive/Documents/QT test playground/SplitViewsMenuPlayground/gear.svg"
//    text: "Settings"
//    tooltipText: "Settings"
//}


T.Button{
    id: control
    property color backgroundColor: Material.color(Material.Grey, Material.Shade100)
    property color referenceBackgroundColor: Material.background
    property alias backgroundOpacity: background.opacity
    property alias backgroundBorder: background.border
    property alias iconLabelScale: iconLabel.scale
    property alias hoverHandler: hoverHandler
    property string tooltipText: ""
    property bool tooltipVisible: hoverHandler.hovered && tooltipText
    property int tooltipDelay: 0
    property int tooltipTimeout: 0
    property bool iconLabelVisible: true
    property color currentBackgroundColor: control.Material.buttonColor(control.Material.theme, control.Material.background,
                                                                        control.Material.accent, control.enabled, control.flat, control.highlighted, control.checked)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topInset: 6
    bottomInset: 6
    verticalPadding: Material.buttonVerticalPadding
    leftPadding: Material.buttonLeftPadding(flat, hasIcon)
    rightPadding: Material.buttonRightPadding(flat, hasIcon, text !== "")
    spacing: 8

    icon.width: 24
    icon.height: 24
    icon.color: !enabled ? Material.hintTextColor :
                           (control.flat && control.highlighted) || (control.checked && !control.highlighted) ? Material.accentColor :
                                                                                                                highlighted ? Material.primaryHighlightedTextColor : Material.foreground

    readonly property bool hasIcon: icon.name.length > 0 || icon.source.toString().length > 0

    Material.elevation: control.down ? 8 : 2
    Material.roundedScale: Material.FullScale

    contentItem: IconLabel {
        id: iconLabel
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        visible: control.iconLabelVisible

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? control.Material.hintTextColor :
                                  (control.flat && control.highlighted) || (control.checked && !control.highlighted) ?
                                      control.Material.foreground : (control.highlighted ?
                                          control.Material.primaryHighlightedTextColor : control.Material.foreground)
    }

    background: Rectangle {
        id: background
        implicitWidth: 64
        implicitHeight: control.Material.buttonHeight

        radius: control.Material.roundedScale === Material.FullScale ? height / 2 : control.Material.roundedScale
        color: control.currentBackgroundColor

        layer.enabled: control.enabled && color.a > 0 && !control.flat
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }

        Ripple {
            enabled: control.enabled
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

    CustomMaterialToolTip{
        visible: tooltipVisible
        text: control.tooltipText
        delay: control.tooltipDelay
        timeout: control.tooltipTimeout
    }

    HoverHandler{
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
}

