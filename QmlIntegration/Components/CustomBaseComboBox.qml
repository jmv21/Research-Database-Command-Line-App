pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl
import QtQuick.Templates as T
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls/"

T.ComboBox {
    id: control
    property string placeholderText: ""
    property color selectionColor: control.Material.accentColor
    property color selectedTextColor: control.Material.primaryHighlightedTextColor
    property color popupColor: Material.dialogColor
    property Component bottomSourceComponent: null
    property bool bottomSourceComponentActive: bottomSourceComponent ? true : false
    property Component additionalIndicatorSidedComponent: null
    property bool additionalIndicatorSidedComponentActive: additionalIndicatorSidedComponent
    property alias placeholder: placeholder

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)


    onEditTextChanged: {
        var index = control.find(editText, Qt.MatchRegularExpression)
        if(index > -1){
            listView.positionViewAtIndex(index,ListView.Beginning)
        }
    }

    topInset: 6
    bottomInset: 6

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
                  + (additionalSideLoader.width + additionalSideLoader.anchors.rightMargin)

    Material.background: flat ? "transparent" : undefined
    Material.foreground: flat ? undefined : Material.primaryTextColor



    delegate: MenuItem {
        required property var model
        required property int index

        width: ListView.view.width
        text: model[control.textRole]
        Material.foreground: control.currentIndex === index ? ListView.view.contentItem.Material.accent : ListView.view.contentItem.Material.foreground
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    indicator: ColorImage {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        color: control.enabled ? control.Material.foreground : control.Material.hintTextColor
        source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"
    }

    contentItem: T.TextField {
        id: textfield
        leftPadding: Material.textFieldHorizontalPadding
        topPadding: Material.textFieldVerticalPadding
        bottomPadding: Material.textFieldVerticalPadding
        placeholderTextColor: control.activeFocus ? control.Material.accentColor : control.Material.hintTextColor

        FloatingPlaceholderText {
            id: placeholder
            x: parent.leftPadding
            width: parent.width - (parent.leftPadding + parent.rightPadding)
            text: control.placeholderText
            font: control.font
            color: parent.placeholderTextColor
            elide: Text.ElideRight
            renderType: parent.renderType
            verticalPadding: -(parent.topPadding/2|0)

            filled: parent.Material.containerStyle === Material.Filled
            controlHasActiveFocus: control.activeFocus
            controlHasText: parent.length > 0
            controlImplicitBackgroundHeight: parent.implicitBackgroundHeight
            controlHeight: parent.height
        }

        text: control.editable ? control.editText : control.displayText
        placeholderText: control.placeholderText
        enabled: control.editable
        autoScroll: control.editable
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse
        color: (control.enabled && text!== control.placeholderText ) ? control.Material.foreground : control.Material.hintTextColor
        selectionColor: control.selectionColor
        selectedTextColor: control.selectedTextColor
        verticalAlignment: Text.AlignVCenter

        cursorDelegate: CursorDelegate { }
    }

    background: MaterialTextContainer {
        implicitWidth: 120
        implicitHeight: control.Material.textFieldHeight

        outlineColor: (enabled && control.hovered) ? control.Material.primaryTextColor : control.Material.hintTextColor
        placeholderTextWidth: Math.min(placeholder.width, placeholder.implicitWidth) * placeholder.scale
        placeholderHasText: placeholder.text.length > 0
        focusedOutlineColor: control.Material.accent
        controlHasActiveFocus: control.activeFocus
        controlHasText: textfield.text.length > 0
        horizontalPadding: control.Material.textFieldHorizontalPadding
    }



    popup: T.Popup {
        id: mPopup
        y: control.height - 5
        width: control.width
        height: Math.min(listView.implicitHeight + verticalPadding * 2,
                         control.Window.height - topMargin - bottomMargin)
        transformOrigin: Item.Top
        topMargin: 12
        bottomMargin: 12
        verticalPadding: 8
        modal: false

        Material.theme: control.Material.theme
        Material.accent: control.Material.accent
        Material.primary: control.Material.primary
        Material.background: control.popupColor

        enter: Transition {
            // grow_fade_in
            NumberAnimation { property: "scale"; from: 0.9; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; from: 0.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        exit: Transition {
            // shrink_fade_out
            NumberAnimation { property: "scale"; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        contentItem: ListView {
            id:listView
            clip: true
            property real footerHeight: 0
            height: Math.min(contentHeight, 200)
            implicitHeight: Math.min(contentHeight, 300)
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 0

            ScrollBar.vertical: CustomScrollBar {
                bottomPadding:  listView.footerHeight
                bottomInset: listView.footerHeight
            }

            footer: Loader{
                z:3
                active: control.bottomSourceComponentActive
                id: bottomItem
                width: parent.width
                sourceComponent: control.bottomSourceComponent
                Binding{
                    target: listView
                    property: "footerHeight"
                    value: bottomItem.height
                }
                Rectangle{
                    color: mPopup.Material.background
                    layer.enabled: true
                    anchors.fill: parent
                }
            }
            footerPositioning:ListView.OverlayFooter
        }

        background: Rectangle {
            radius: 4
            color: parent.Material.dialogColor

            layer.enabled: control.enabled
            layer.effect: RoundedElevationEffect {
                elevation: 4
                roundedScale: Material.ExtraSmallScale
            }
        }
    }

    Loader{
        id: additionalSideLoader
        active: control.additionalIndicatorSidedComponentActive
        anchors{
            right: indicator.left
            rightMargin: -15
            verticalCenter: parent.verticalCenter
        }
        height: parent.height - control.padding
        sourceComponent: control.additionalIndicatorSidedComponent
    }
}
