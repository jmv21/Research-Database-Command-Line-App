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
import Qt5Compat.GraphicalEffects

Item {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
    implicitHeight:implicitBackgroundHeight + topInset + bottomInset

    property int rightInset: 0
    property int leftInset: 0
    property int topInset: 0
    property int bottomInset: 0

    property int implicitBackgroundWidth: background.implicitWidth
    property int implicitBackgroundHeight: background.implicitHeight

    property alias source: sourceImage.source
    property alias fillmode:  control.image.fillMode
    property real radius: Math.min(width, height) / 2

    property Item background: Rectangle {
        id: backgroundRect
        implicitWidth: 200
        implicitHeight: 200
        anchors.fill: parent
        radius: control.radius
    }

    property Image image: Image {
        id: sourceImage
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        visible: false
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: control.radius
    }

    OpacityMask {
        anchors.fill: parent
        source: sourceImage
        maskSource: mask
        z: 2
    }
}

