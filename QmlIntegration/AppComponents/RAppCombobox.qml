import QtQuick
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Layouts
import QmlIntegration

import "./"
import "../Components"

CustomMaterialComboBox {
    id: root
    property bool extraEnabledHint: true
    property string textfieldPlaceholder: "New item"
    property string addButtonText: "Add New Item"
    property bool addButtonActiveFocusOnClick: false
    property bool closeOnAddButtonClick: false
    property bool canAddItems: false
    property bool newItemTextFieldVisible: canAddItems


    signal addButtonClicked
    signal addItem(string name)

    popupColor: Globals.colors.surface
    clearActionIconSource: Globals.icons.close
    Material.accent: Globals.colors.primary
    selectedTextColor: Globals.colors.primary10
    addButtonSeparatorColor: Globals.colors.secondary30
    enabled: !busy && extraEnabledHint  && (model || canAddItems ? true : false)
    currentIndex: -1
    onCurrentIndexChanged: {
        var index = root.find(root.noneLabel)
        if(currentIndex === index){
            currentIndex = -1
            root.focus = false
        }
    }

    Component{
        id: nonBusyIndicator
        ColorImage {
            color: root.enabled ? root.Material.foreground : root.Material.hintTextColor
            source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"
        }
    }

    Component{
        id: busyIndicator
        RAppBusyIndicator {
            enabled: root.enabled
            visible: root.busy
            Material.roundedScale: root.Material.roundedScale
            height: root.implicitBackgroundHeight * 0.5
        }
    }

    indicator: Loader {
        id: indicatorLoader
        x: root.mirrored ? root.padding : root.width - width - root.padding - (root.busy ? 5 : 0)
        y: root.topPadding + (root.availableHeight - height) / 2
        sourceComponent: busy ? busyIndicator : nonBusyIndicator
    }

    bottomSourceComponent: RAppBaseBackground{
        id: theBottomItem
        visible: canAddItems
        height: addButtonSeparator.height + clmnLayout.height + clmnLayout.anchors.topMargin + 5

        onBackgroundClicked: {
            root.forceActiveFocus()
        }

        Rectangle {
            id: addButtonSeparator
            height: root.delegateModel && root.delegateModel.count > 0 ? 2 : 0
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            radius: Material.FullScale
            width: parent.width * 0.9
            color: addButtonSeparatorColor
        }

        ColumnLayout{
            id: clmnLayout
            anchors.top: addButtonSeparator.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: addButtonSeparator.width

            RAppTextfield{
                id: newItemTextfield
                visible: root.newItemTextFieldVisible
                onVisibleChanged: {
                    if(!root.busy){
                        text = ""
                    }
                }
                enabled: !root.busy
                placeholderText: qsTr(root.textfieldPlaceholder)
                Layout.fillWidth: true
            }

            RAppButton {
                id: addButton
                busy: root.busy
                extraEnableHint: newItemTextfield.text || !root.newItemTextFieldVisible
                Layout.fillWidth: true
                focusPolicy: Qt.NoFocus
                text: root.addButtonText
                onClicked: {
                    addButtonClicked()
                    addItem(newItemTextfield.text)
                    if(root.addButtonActiveFocusOnClick){
                        forceActiveFocus()
                        root.focus = false
                    }
                    if(closeOnAddButtonClick){
                        root.popup.close()
                    }
                }
            }
        }
    }
    bottomSourceComponentActive: canAddItems
}
