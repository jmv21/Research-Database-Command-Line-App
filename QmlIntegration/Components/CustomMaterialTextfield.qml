import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls/"

Item {
    id: control
    property bool animated: true
    property color errorColor: "red"
    property string originalText: ""
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias baseTextfield: textField
    property alias textFieldHeight: textField.height
    property string errorText: ""
    property bool hasError: false
    property string tooltipText: ""
    property bool tooltipVisible: textField.hovered && tooltipText
    property string errorIconSource: ""
    signal textFieldComponentCompleted
    property alias sideLoader: sideLoader
    property alias sideComponent: sideLoader.sourceComponent
    property bool hasChanged: originalText != text

    width: 120
    height: implicitHeight
    implicitHeight: textField.height + errorTextWrapper.height

    Item {
        id: errorTextWrapper
        x: textField.leftPadding
        property bool animated: parent.animated

        width: parent.width - x
        height: hasError && errorLabel.visible  ? errorLabel.height : 0

        anchors.top: textField.bottom
        anchors.topMargin: 5
        clip: true

        CustomLabel {
            id: errorLabel
            visible: text
            width: parent.width
            anchors.bottom: parent.bottom
            color: control.errorColor
            text: qsTr(control.errorText)
            font.pixelSize: textField.font.pixelSize - 2
            minimumPixelSize: 8
        }

        Behavior on height {
            SmoothedAnimation{
            }
        }
    }


    CustomBaseMaterialTextField {
        id: textField
        Material.elevation: 10
        anchors.top: parent.top
        width: parent.width
        Material.roundedScale: control.Material.roundedScale

        property bool thereIsSideLoaderComponent: sideLoader.item && sideLoader.item.visible
        property bool thereIsExtraSideComponent: errorIconLabel.visible
        property bool thereIsSideComponent: thereIsSideLoaderComponent || thereIsExtraSideComponent
        property bool hasError: parent.hasError

        Material.accent: hasError ? control.errorColor : parent.Material.accent


        property real visibleSideComponentWidth: errorIconLabel.visible ? errorIconItem.width -
                                                                          (errorIconItem.width - errorIconLabel.width - 3):
                                                                          (thereIsSideComponent ? sideLoader.width : 0)

        rightPadding: Material.textFieldHorizontalPadding  + visibleSideComponentWidth

        Item{
            id: errorIconItem
            visible: hasError
            anchors{
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            height: sideLoader.height
            width: height
            IconLabel{
                id: errorIconLabel
                anchors.centerIn: parent
                icon.source: errorIconSource
                icon.color: control.errorColor
            }
        }
    }

    Loader{
        id: sideLoader
        visible:  !errorIconLabel.visible
        height: textField.implicitHeight
        width: item ? item.implicitWidth : 24
        anchors{
            right: textField.right
            top: textField.top
            bottom: textField.bottom
        }
    }

    CustomMaterialToolTip{
        tooltipVisibleHint: tooltipVisible
        text: tooltipText
        extraSeparation: 3
    }
}

