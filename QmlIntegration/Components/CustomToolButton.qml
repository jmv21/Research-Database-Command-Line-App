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
import QtQuick.Controls
import QtQuick.Controls.Material


ToolButton {
    id: control
    property string buttonText: ""
    property string buttonIconSource: ""

    property bool forceFocusOnClick: true
    property bool onhoveredAnimationEnabled: true

    property color hoveredBackgroundColor: "#404258"
    property color buttonMainColor: "white"
    property color buttonSecondaryColor: "#2FA4FF"
    property color backgroundColor: "#e9ecef"

    property double textPointSize: 20
    property int radius: height/2

    property bool enableTooltip: true
    property string tooltipText: ""

    property bool iconVisible: true
    property bool textVisible: false

    property real iconScale: 1

    display: AbstractButton.TextOnly
    background: Rectangle{color:"transparent"}

    signal buttonClicked



    //    contentItem:Text {
    //        visible: textVisible
    //        text: buttonText
    //        opacity: enabled ? 1.0 : 0.3
    //        color: (enabled & hovered) ? buttonSecondaryColor : buttonMainColor
    //        horizontalAlignment: Text.AlignHCenter
    //        verticalAlignment: Text.AlignVCenter
    //        elide: Text.ElideRight
    //        minimumPixelSize: 8
    //        font.pointSize: textPointSize
    //        scale: (enabled & hovered) ? (onhoveredAnimationEnabled ? (mouseArea.pressed ? 1.10 : 1.20): (mouseArea.pressed ? 0.9 : 1.00)): 1.00
    //        Behavior on scale {
    //            NumberAnimation {
    //                duration: 100
    //            }
    //        }
    //        Behavior on color {
    //            ColorAnimation{
    //                duration: 200
    //            }
    //        }
    //    }

    IconImage{
        visible: iconVisible
        anchors.fill: parent


        mipmap: true
        opacity: enabled ? 1.0 : 0.3
        source: buttonIconSource

        color: (enabled & hovered) ? buttonSecondaryColor : buttonMainColor
        scale: (enabled & hovered) ? (onhoveredAnimationEnabled ? (mouseArea.pressed ? iconScale*1.10 : iconScale*1.20): (mouseArea.pressed ? iconScale*0.9 : iconScale*1.00)): iconScale*1.00

        Behavior on scale {
            NumberAnimation {
                duration: 100
            }
        }
        Behavior on color {
            ColorAnimation{
                duration: 200
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            buttonClicked()
            if(forceFocusOnClick){
                forceActiveFocus()
            }
        }
    }

    CustomToolTip {
        visible:  (!control.enabled || tooltipText === "" || !control.enableTooltip) ? false: (control.hovered ? true : false)
        text: tooltipText
    }
}
