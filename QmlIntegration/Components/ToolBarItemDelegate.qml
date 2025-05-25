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
import QtQuick.Controls.impl
import QtQuick.Controls.Material

import "../Controls/"

// Use Case


CustomMaterialItemDelegate {
    id: control
    property bool selected: false
    property bool deployable: true
    property bool rightDeploy: true
    property string iconSource: ""

    property var indicatorComponent: defaultIndicatorComponent
    property real indicatorRightPadding: -3
    property real indicatorLeftPadding: -3
    property real indicatorIconWidth: 18
    property real indicatorIconHeight: 18
    property color indicatorColor:  enabled ? Material.foreground : Material.hintTextColor
    property string indicatorIconSource: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"

    property alias toolButton: toolButton
    property alias indicatorLoader: indicatorLoader

    Component{
        id: defaultIndicatorComponent
        Item{
            height: control.height
            width: (control.width - toolButtonIconLabel.width) / 2
            IconLabel {
                icon.width:  control.indicatorIconWidth
                icon.height: control.indicatorIconHeight
                anchors.centerIn: parent
                color: control.indicatorColor
                icon.source: control.indicatorIconSource
            }
        }
    }

    CustomMaterialBaseToolButton{
        id: toolButton
        checkable: true
        anchors.centerIn: parent
        noBackground: true
        implicitWidth: parent.width / 2
        implicitHeight: parent.height / 2
        IconLabel{
            id: toolButtonIconLabel
            scale: toolButton.hooverHandler.hovered ? 1.1 : 1
            x: (toolButton.width - width) / 2 - toolButton.rightInset + toolButton.leftInset
            y: (toolButton.height - height) / 2 + toolButton.topInset - toolButton.bottomInset
            spacing: toolButton.spacing
            mirrored: toolButton.mirrored
            display: toolButton.display

            icon.source: control.iconSource
            icon.width: parent.icon.width
            icon.height: parent.icon.height
            icon.color: !toolButton.enabled ? toolButton.Material.hintTextColor :
                                              toolButton.checked || toolButton.highlighted ? toolButton.Material.accent : toolButton.Material.foreground
            text: toolButton.text
            font: toolButton.font
            color: !toolButton.enabled ? toolButton.Material.hintTextColor :
                                         toolButton.checked || toolButton.highlighted ? toolButton.Material.accent : toolButton.Material.foreground
            Behavior on icon.color {
                ColorAnimation {
                    duration: 100
                }
            }

            Behavior on scale{
                NumberAnimation{
                    easing.type: Easing.OutBack
                }
            }
        }

        Loader{
            id: indicatorLoader
            active: control.deployable
            anchors{
                verticalCenter: toolButtonIconLabel.verticalCenter
                left: rightDeploy ? toolButtonIconLabel.right : undefined
                leftMargin: control.indicatorLeftPadding
                right: rightDeploy ? undefined : toolButtonIconLabel.left
                rightMargin: control.indicatorRightPadding
            }
            sourceComponent: control.indicatorComponent
            rotation: rightDeploy ? 270 : 90
        }
    }
}
