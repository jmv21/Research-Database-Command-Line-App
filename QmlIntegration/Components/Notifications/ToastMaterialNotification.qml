/* Copyright (C) 2025 The Lucerum Inc.
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum Inc. under the QT Commercial License as agreed with The Qt Company.
 * For more details, see <https://www.qt.io/licensing/>.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts

import "../../Controls"
import "../../Components/"
import "../../js/utils.js" as Utils

Pane {
    id: control
    property string titleText: ""
    property int titlePixelSize: 16
    property color titleTextColor: Material.foreground
    property alias titleLabelItem: titleLabel
    property string informationalText: ""
    property int informationalTextPixelSize: Math.max(2, titlePixelSize-2)
    property color informationalTextColor: Material.hintTextColor
    property string notificationIconSource: ""
    property bool isIconOutlinedType: false
    property string closeButtonIconSource: ""
    signal closeButtonClicked
    signal requestCopyToClipboard(string text)

    Material.elevation: 10

    contentItem:Item{
        height: implicitHeight
        implicitHeight: contentLayout.implicitHeight
        width: implicitWidth
        implicitWidth: contentLayout.implicitWidth

        CustomMaterialToolButton{
            id: closeButton
            anchors{
                top: parent.top
                topMargin: -control.padding/2
                right: parent.right
                rightMargin: -control.padding/2
            }
            visible: control.closeButtonIconSource.length > 0
            icon.source: control.closeButtonIconSource
            onClicked: {
                control.closeButtonClicked()
            }
        }

        // Rectangle{
        //     width:textLayout.width
        //     height: textLayout.height
        //     x: textLayout.x
        //     y: textLayout.y
        //     border.width: 1
        //     color: "transparent"
        // }

        RowLayout{
            id: contentLayout
            width: parent.width
            spacing: 10

            Item{
                Layout.leftMargin: -control.leftPadding
                implicitHeight: notificationIcon.height + notificationIconBackground.padding * 2
                Layout.preferredWidth: notificationIconBackground.width

                Rectangle{
                    id: notificationIconBackground
                    property int padding: 8
                    topLeftRadius: control.Material.roundedScale
                    bottomLeftRadius: control.Material.roundedScale
                    anchors.centerIn: parent
                    color: control.Material.accent
                    width: notificationIcon.width + padding
                    height: control.height
                }

                IconLabel{
                    id: notificationIcon
                    anchors.centerIn: parent
                    icon.source: control.notificationIconSource
                    icon.color: notificationIconBackground.color.toString() !== "#00000000" ? Utils.getTextColor(notificationIconBackground.color)
                                                                                            : Material.foreground
                    font.pixelSize: 5
                }
            }

            Item{
                implicitHeight: textLayout.implicitHeight
                implicitWidth: parent.width - parent.spacing - control.padding

                ColumnLayout{
                    id: textLayout
                    width: parent.width
                    spacing: 5

                    CustomLabel{
                        id: titleLabel
                        Layout.preferredWidth: Math.min(implicitWidth, parent.width - closeButton.width)
                        font.weight: 600
                        font.pixelSize: control.titlePixelSize
                        backgroundColor: control.Material.background
                        color: control.titleTextColor
                        maximumLineCount: 2
                        text: control.titleText
                    }

                    CustomLabel{
                        Layout.preferredWidth:  Math.min(implicitWidth, parent.width)
                        font.pixelSize: control.informationalTextPixelSize
                        backgroundColor: control.Material.background
                        color: control.informationalTextColor
                        maximumLineCount: 2
                        text: control.informationalText

                        MouseArea{
                            id: hoverMA
                            anchors.fill: parent
                            enabled: true
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: parent.implicitWidth > parent.width
                            onClicked: {
                                control.requestCopyToClipboard(parent.text)
                            }
                        }

                        CustomMaterialToolTip{
                            delay: 1000
                            visible: hoverMA.containsMouse
                            text: parent.text
                            width: Overlay.overlay ? Overlay.overlay.width / 2 : 0
                            x: parent ? (parent.width - width) / 2 : 0
                            exit: Transition {
                                ParallelAnimation{
                                    NumberAnimation { property: "opacity"; to: 0; easing.type: Easing.OutQuad; duration: 500 }
                                    NumberAnimation { property: "scale"; to: 0; easing.type: Easing.OutQuad; duration: 300 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
