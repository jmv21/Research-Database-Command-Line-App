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
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Window

import "../../Controls"
import "../../Components/"

CustomMaterialDialog{
    id: control
    property alias bodyLabel: bodyLabel
    property alias titleLabel: titleLabel
    property alias doNotShowAgainChecked: suppressFutureDialogCheckBox.checked
    property bool doNotShowAgainCheckBoxVisible: false
    property string text: ""
    property string informativeText: ""
    property string iconSource: ""
    property color iconColor: Material.foreground
    titlePixelSize: 24
    titleWeight: 500
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: Math.max(header.implicitWidth, 200) + padding * 2
    bottomPadding: 0

    onRejected:{
        close()
    }

    header: Item{
        implicitWidth: headerLayout.implicitWidth
        width: Math.min(headerLayout.implicitWidth, control.width)
        implicitHeight: headerLayout.implicitHeight

        ColumnLayout{
            id: headerLayout
            width: parent.width

            IconLabel{
                id: headerIcon
                Layout.fillWidth: true
                visible: control.iconSource
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: control.padding
                icon.source: control.iconSource
                icon.color: control.iconColor
            }

            CustomLabel {
                id: titleLabel
                text: control.title
                Layout.preferredWidth: Math.min(parent.width, implicitWidth)
                padding: control.padding
                Layout.alignment: control.iconSource ? Qt.AlignHCenter : Qt.AlignLeading
                maximumLineCount: 1
                backgroundColor: control.backgroundColor
                visible: control.title
                bottomPadding: 0
                font.pixelSize: control.titlePixelSize
                font.weight: control.titleWeight
                color: control.titleColor ? control.titleColor : textColor
            }
        }
    }

    ColumnLayout{
        id: bodyLayout
        width: parent.width

        CustomLabel{
            id: bodyLabel
            backgroundColor: control.Material.background
            Layout.preferredWidth: parent.width
            text: control.text
        }

        CheckBox {
            id: suppressFutureDialogCheckBox
            visible: control.doNotShowAgainCheckBoxVisible
            text: qsTr("Do not display this message in the future")
            onVisibleChanged: {
                suppressFutureDialogCheckBox.checked = false
            }
        }
    }
}
