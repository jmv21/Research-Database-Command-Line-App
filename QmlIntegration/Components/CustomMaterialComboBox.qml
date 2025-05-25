import QtQuick
import QtQuick.Controls.Material

import "../Components/Menu"

CustomBaseComboBox {
    id: control
    property bool clearable: false
    property string clearActionIconSource: ""
    property bool busy: false
    property bool hasChanged: currentText != originalSelectionText
    property color addButtonSeparatorColor: Material.frameColor
    property string originalSelectionText: ""
    property string noneLabel: "None"


    delegate: CustomBaseMaterialMenuItem{
        required property var model
        required property int index
        hoverHandlerItem.enabled: false

        width: ListView.view.width
        text: model[control.textRole]
        Material.foreground: control.currentIndex === index ? ListView.view.contentItem.Material.accent : ListView.view.contentItem.Material.foreground
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    additionalIndicatorSidedComponent: Item{
        id: sideItem
        implicitHeight: parent.height
        implicitWidth: closeButton.width
        state: control.displayText ? "visible" : "nonVisible"
        anchors.right: parent.right
        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: closeButton
                    scale: 1
                    rotation: 180
                }
            },
            State {
                name: "nonVisible"
                PropertyChanges {
                    target: closeButton
                    scale: 0
                    rotation: 0
                }
            }
        ]

        transitions: [
            Transition {
                from: "nonVisible"
                to: "visible"
                ScaleAnimator {
                    target: closeButton
                    duration: 250
                    easing.type: Easing.OutBack
                }
                RotationAnimation{
                    target: closeButton
                    duration: 350
                    easing.type: Easing.OutBack
                }
            },
            Transition {
                from: "visible"
                to: "nonVisible"
                ScaleAnimator {
                    target: closeButton
                    duration: 250
                    easing.type: Easing.InBack
                }
                RotationAnimation{
                    target: closeButton
                    duration: 250
                    easing.type: Easing.InBack
                }
            }
        ]

        CustomMaterialToolButton{
            id: closeButton
            focusPolicy: Qt.NoFocus
            anchors.centerIn: parent
            activeFocusOnTab: false
            icon.source: control.clearActionIconSource
            Material.accent: Material.foreground
            icon.color: !enabled ? Material.hintTextColor : Material.accent
            onClicked: {
                control.currentIndex = -1
                control.focus = false
            }

            transformOrigin: Item.Center
        }
    }
    additionalIndicatorSidedComponentActive: clearActionIconSource && clearable
    enabled: !busy
    currentIndex: -1
    onCurrentTextChanged: {
        if(currentText === control.noneLabel){
            control.currentIndex = -1
            control.focus = false
        }
    }
}
