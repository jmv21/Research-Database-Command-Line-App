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
import QtQuick.Controls.Material

import "../js/utils.js" as Utils

Item{
    id: control
    z:2
    states: [
        State {
            name: "collapsed"
            PropertyChanges {
                target: iconL
                rotation: 90
            }
        }
    ]
    property alias background: background
    property alias iconLabel: iconL
    property color accentColor: "purple"
    property color backgroundColor: Material.background
    property string icon:  ""

    signal collapsed
    signal expanded

    Material.roundedScale: Material.FullScale

    height: 30
    width: 35

    Pane{
        id: background
        height: parent.height
        width: parent.width + 10
        Material.background: control.backgroundColor
        Material.roundedScale: control.Material.roundedScale
    }

    //    Rectangle{
    //        anchors{
    //            left: background.left
    //            top: background.top
    //            bottom: background.bottom
    //        }
    //        implicitWidth: 12
    //        color: background.color
    //    }

    IconLabel{
        id: iconL
        property int moveToValue: control.state === "" ? -2 : 4
        icon.height: 30
        x: m_mouseArea.containsMouse ? ((parent.width - width)/2 + 8 + moveToValue) : (parent.width - width)/2 + 8
        y: (parent.height - height)/2
        icon.color: m_mouseArea.containsMouse ?  control.accentColor : Utils.getTextColor(background.background.color)
        icon.source: control.icon
        opacity: m_mouseArea.containsMouse ? 0.6 : 1
        transform: Rotation {
            origin.x: iconL.width / 2
            origin.y: iconL.height / 2
            angle: iconL.rotation
        }
        Behavior on x{
            NumberAnimation{
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: m_mouseArea
        anchors.fill: control
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            control.state = control.state === "collapsed" ? "" : "collapsed"
        }
    }

    transitions: [
        Transition {
            from: "*"
            to: "collapsed"
            SequentialAnimation{
                ParallelAnimation{
                    ScriptAction {
                        script: {
                            control.collapsed()
                        }
                    }

                    RotationAnimation {
                        target: iconL
                        property: "rotation"
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                ParallelAnimation{
                }
            }
        },
        Transition {
            from: "collapsed"
            to: ""
            SequentialAnimation{
                ParallelAnimation{

                }

                ParallelAnimation{
                    ScriptAction {
                        script: {
                            control.expanded()
                        }
                    }

                    RotationAnimation {
                        target: iconL
                        property: "rotation"
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    ]
}

