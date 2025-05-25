/* Copyright (C) 2024 The Lucerum Inc.
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
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../../Controls"
import "../../Components/"

Item {
    id: control
    property bool animated: true
    property var initialSelection: []
    property alias text: multiChoiceField.text
    property alias placeholderText: multiChoiceField.placeholderText
    property alias baseMultiChoiceField: multiChoiceField
    property alias textFieldHeight: multiChoiceField.height
    property alias errorLabel: errorLabel
    property int modelCount: -1
    property string errorText: ""
    property bool hasError: false
    property string tooltipText: ""
    property bool tooltipVisible: multiChoiceField.hovered && tooltipText
    property string errorIconSource: ""
    signal textFieldComponentCompleted
    property bool hasChanged: baseMultiChoiceField.hasChanged
    property bool busy: control.baseMultiChoiceField.busy
    Material.roundedScale: Material.SmallScale

    width: 120
    height: implicitHeight
    implicitHeight: multiChoiceField.height + errorTextWrapper.height

    Item {
        id: errorTextWrapper
        x: multiChoiceField.leftPadding
        property bool animated: parent.animated

        width: parent.width - x
        height: hasError && errorLabel.visible  ? errorLabel.height : 0

        anchors.top: multiChoiceField.bottom
        anchors.topMargin: 5
        clip: true

        CustomLabel {
            id: errorLabel
            visible: text
            width: parent.width
            anchors.bottom: parent.bottom
            color: "red"
            text: qsTr(control.errorText)
            font.pixelSize: multiChoiceField.font.pixelSize - 2
            minimumPixelSize: 8
        }

        Behavior on height {
            NumberAnimation{
                duration: control.animated ? 150 : 0
            }
        }
    }

    MultiChoiceField {
        id: multiChoiceField
        anchors.top: parent.top
        width: parent.width
        property bool hasError: control.hasError
        initialSelection: control.initialSelection

        Material.roundedScale: control.Material.roundedScale
        Material.accent: hasError ? "red" : control.Material.accent
    }

    CustomMaterialToolTip{
        tooltipVisibleHint: tooltipVisible
        text: tooltipText
        extraSeparation: 3
    }
}
