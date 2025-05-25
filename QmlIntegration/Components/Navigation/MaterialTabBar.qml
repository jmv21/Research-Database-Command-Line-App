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
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.TabBar {
    id: control
    property alias contentListView: contentListView
    property bool animated: true
    property real highlightAnimationDuration: 250
    property bool indicatorPos: control.position === T.TabBar.Footer

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    spacing: 1

    contentItem: ListView {
        id: contentListView
        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem

        highlightMoveDuration: control.animated ? control.highlightAnimationDuration : 0
        highlightResizeDuration: control.animated ? control.highlightAnimationDuration : 0
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 48
        preferredHighlightEnd: width - 48

        highlight: Item {
            z: 2
            Rectangle {
                height: 3
                width: parent.width
                y: control.indicatorPos ? 0 : parent.height - height
                color: control.Material.accentColor
                radius: control.Material.roundedScale
            }
        }
    }

    background: Rectangle {
        color: control.Material.backgroundColor
        radius: control.Material.roundedScale

        layer.enabled: control.Material.elevation > 0
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
            fullWidth: true
        }
    }
}
