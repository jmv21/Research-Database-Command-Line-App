import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls/"

T.SpinBox {
    id: control

    // Note: the width of the indicators are calculated into the padding
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    spacing: 6
    topPadding: Material.textFieldVerticalPadding
    bottomPadding: Material.textFieldVerticalPadding
    leftPadding: control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0)
    rightPadding: control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0)
    property int margins: 5
    property int leftMargin: margins
    property int rightMargin: margins

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    contentItem: TextInput {
        text: control.displayText
        font: control.font
        color: enabled ? control.Material.foreground : control.Material.hintTextColor
        selectionColor: control.Material.textSelectionColor
        selectedTextColor: control.Material.foreground
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        cursorDelegate: CursorDelegate { }

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
        clip: width < implicitWidth
    }

    up.indicator: CustomMaterialButton {
        x: control.mirrored ? 0 : control.width - width - control.rightMargin
        y: (control.height -height)/2
        backgroundColor: "transparent"
        width: height * 0.8
        height: control.height

        CustomLabel{
            anchors.centerIn: parent
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            font.pixelSize: parent.height * 0.6
            font.weight: 500
            text: "+"
            Material.foreground: enabled ? control.Material.foreground : Material.hintTextColor
        }
        onPressedChanged: {
            control.up.pressed = pressed
        }
    }

    down.indicator: CustomMaterialButton {
        x: control.mirrored ? control.width - width : control.leftMargin
        y: (control.height -height)/2
        backgroundColor: "transparent"
        width: height * 0.8
        height: control.height

        CustomLabel{
            anchors.centerIn: parent
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: parent.height * 0.6
            font.weight: 500
            text: "-"
            Material.foreground: enabled ? control.Material.foreground : Material.hintTextColor
        }

        onPressedChanged: {
            control.down.pressed = pressed
        }
    }

    background: MaterialTextContainer {
        implicitWidth: 140
        implicitHeight: control.Material.textFieldHeight

        outlineColor: (enabled && control.hovered) ? control.Material.primaryTextColor : control.Material.hintTextColor
        focusedOutlineColor: control.Material.accentColor
        controlHasActiveFocus: control.activeFocus
        controlHasText: true
        horizontalPadding: control.Material.textFieldHorizontalPadding
    }
}
