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

T.MenuItem {
    id: control
    property alias hoverHandlerItem: hoverHandler
    Material.roundedScale: Material.ExtraSmallScale

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 16
    verticalPadding: Material.menuItemVerticalPadding
    spacing: 16

    icon.width: 24
    icon.height: 24
    icon.color: enabled ? Material.foreground : Material.hintTextColor

    highlighted: hoverHandler.hovered

    indicator: CheckIndicator {
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        visible: control.checkable
        control: control
        checkState: control.checked ? Qt.Checked : Qt.Unchecked
    }

    arrow: ColorImage {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2

        visible: control.subMenu
        mirror: control.mirrored
        color: control.enabled ? control.Material.foreground : control.Material.hintTextColor
        source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/arrow-indicator.png"
    }

    contentItem: IconLabel {
        readonly property real arrowPadding: control.subMenu && control.arrow ? control.arrow.width + control.spacing : 0
        readonly property real indicatorPadding: control.checkable && control.indicator ? control.indicator.width + control.spacing : 0
        leftPadding: !control.mirrored ? indicatorPadding : arrowPadding
        rightPadding: control.mirrored ? indicatorPadding : arrowPadding

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft

        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? control.Material.foreground : control.Material.hintTextColor
    }

    background:Item{
        implicitWidth: 200
        implicitHeight: control.Material.menuItemHeight
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - control.padding
            height: parent.height
            radius: control.Material.roundedScale

            color: control.highlighted ? control.Material.listHighlightColor : "transparent"

            Ripple {
                width: parent.width
                height: parent.height
                clip: true
                clipRadius: parent.radius

                pressed: control.pressed
                anchor: control
                active: control.down || control.highlighted
                color: control.Material.rippleColor
            }
        }
    }

    HoverHandler{
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
}
