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
import QtQuick.Controls.Material

import "../../Controls"
import "../../Components/"
import "../../Components/Menu"


Item {
    id: control
    property bool animated: true
    property var initialSelection: []
    property alias text: comboBox.displayText
    property alias placeholderText: comboBox.placeholderText
    property alias baseComboBox: comboBox
    property alias model: comboBox.model
    property alias textRole: comboBox.textRole
    property alias textFieldHeight: comboBox.height
    property alias errorLabel: errorLabel
    property string errorText: ""
    property bool hasError: errorText !== ""
    property string tooltipText: ""
    property bool tooltipVisible: comboBox.hovered && tooltipText
    property string errorIconSource: ""
    signal textFieldComponentCompleted
    property bool hasChanged: baseComboBox.hasChanged
    property bool busy: control.baseComboBox.busy
    Material.roundedScale: Material.SmallScale

    width: 120
    height: implicitHeight
    implicitHeight: comboBox.height + errorTextWrapper.height

    Item {
        id: errorTextWrapper
        x: comboBox.leftPadding
        property bool animated: parent.animated

        width: parent.width - x
        height: hasError && errorLabel.visible  ? errorLabel.height : 0

        anchors.top: comboBox.bottom
        anchors.topMargin: -(comboBox.bottomInset)
        clip: true

        CustomLabel {
            id: errorLabel
            visible: text
            width: parent.width
            anchors.bottom: parent.bottom
            color: "red"
            text: qsTr(control.errorText)
            font.pixelSize: comboBox.font.pixelSize - 2
            minimumPixelSize: 8
        }

        Behavior on height {
            NumberAnimation{
                duration: control.animated ? 150 : 0
            }
        }
    }



    CustomMaterialComboBox {
        id: comboBox
        busy: control.busy
        width: parent.width
        Material.accent: hasError ? "red" : control.Material.accent
    }


    CustomMaterialToolTip{
        tooltipVisibleHint: tooltipVisible
        text: tooltipText
        extraSeparation: 3
    }
}

