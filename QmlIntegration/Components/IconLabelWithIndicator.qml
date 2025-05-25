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

IconLabel{
    id: control
    property string overlappingIconSource: ""
    property color overlappingIconColor: Material.foreground
    property color overlapingIconBackgroundColor: "transparent"
    property alias overlapingIconLabel: overlappingIcon
    property alias overlappingIconRightMargin: overlappingIconBackground.anchors.rightMargin
    property alias overlappingIconTopMargin: overlappingIconBackground.anchors.topMargin
    property int overlappingIconPadding: 2
    property double overlapingScaleReference: 0.6
    onWidthChanged:{
        let referenceValue = !control.text ? control.width : control.icon.width
        overlappingIcon.width = referenceValue * control.overlapingScaleReference
    }
    onHeightChanged:{
        let referenceValue = !control.text ? control.height : control.icon.height
        overlappingIcon.height = referenceValue * control.overlapingScaleReference
    }

    Rectangle{
        id: overlappingIconBackground
        property int maxDimension: Math.max(overlappingIcon.width, overlappingIcon.height)
        visible: overlappingIconSource
        anchors.top: parent.top
        anchors.topMargin: overlapingIconLabel.height * 0.2
        anchors.right: parent.right
        anchors.rightMargin: -overlapingIconLabel.width * 0.1
        width:  maxDimension + control.overlappingIconPadding
        height: maxDimension + control.overlappingIconPadding
        radius: height
        z: parent.z + 1
        color: control.overlapingIconBackgroundColor
        IconLabel{
            id: overlappingIcon
            anchors.centerIn: parent
            icon.source: control.overlappingIconSource
            icon.color: enabled ? control.overlappingIconColor : control.Material.hintTextColor
            color: enabled ? control.overlappingIconColor : control.Material.hintTextColor
        }
    }

    // Component.onCompleted: {
    //     overlappingIcon.width = control.icon.width/2
    //     overlappingIconBackground.x = control.icon.width - overlappingIcon.width * 0.65
    //     overlappingIcon.height = control.icon.height/2
    //     overlappingIconBackground.y = control.icon.height * 0.05
    // }
}
