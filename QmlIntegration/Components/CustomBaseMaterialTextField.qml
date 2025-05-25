import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.TextField {
    id: control
    property bool textFieldBackgroundVisible: true
    property color baseOutlineColor: Material.hintTextColor
    property color outlineColor : control.hasError ? control.Material.accent : ((control.enabled && control.hovered)
                                                                                ? control.Material.primaryTextColor : control.baseOutlineColor)
    property color focusedOutlineColor: Material.accent
    property bool placeholderHasText: placeholder.text.length > 0
    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    // If we're clipped, set topInset to half the height of the placeholder text to avoid it being clipped.
    topInset: clip ? placeholder.largestHeight / 2 : 0

    leftPadding: Material.textFieldHorizontalPadding
    rightPadding: Material.textFieldHorizontalPadding
    // Need to account for the placeholder text when it's sitting on top.
    topPadding: Material.containerStyle === Material.Filled
                ? placeholderText.length > 0 && (activeFocus || length > 0)
                  ? Material.textFieldVerticalPadding + placeholder.largestHeight
                  : Material.textFieldVerticalPadding
    // Account for any topInset (used to avoid floating placeholder text being clipped),
    // otherwise the text will be too close to the background.
    : Material.textFieldVerticalPadding + topInset
    bottomPadding: Material.textFieldVerticalPadding

    color: enabled ? Material.foreground : Material.hintTextColor
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    placeholderTextColor: enabled && activeFocus ? Material.accentColor : Material.hintTextColor
    verticalAlignment: TextInput.AlignVCenter

    Material.containerStyle: Material.Outlined

    cursorDelegate: CursorDelegate { }


    FloatingPlaceholderText {
        id: placeholder
        width: control.width - (control.leftPadding + control.rightPadding)
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        elide: Text.ElideRight
        renderType: control.renderType

        filled: control.Material.containerStyle === Material.Filled
        verticalPadding: control.Material.textFieldVerticalPadding
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.length > 0
        controlImplicitBackgroundHeight: control.implicitBackgroundHeight
        controlHeight: control.height
        leftPadding: control.leftPadding
        floatingLeftPadding: control.Material.textFieldHorizontalPadding
    }

    // Rectangle{
    //     z: background.z - 2
    //     layer.enabled: true
    //     anchors{
    //         top: background.top
    //         topMargin: control.activeFocus ? 2 : 1
    //         left: background.left
    //         right: background.right
    //     }
    //     height: background.height
    //     color: control.activeFocus ? control.Material.accent : control.outlineColor
    //     radius: Material.ExtraSmallScale
    // }

    background: MaterialTextContainer {
        implicitWidth: 200
        implicitHeight: control.Material.textFieldHeight
        layer.enabled: false

        filled: control.Material.containerStyle === Material.Filled
        fillColor: control.Material.textFieldFilledContainerColor
        outlineColor: control.outlineColor
        focusedOutlineColor: control.focusedOutlineColor
        // When the control's size is set larger than its implicit size, use whatever size is smaller
        // so that the gap isn't too big.
        placeholderTextWidth: Math.min(placeholder.width, placeholder.implicitWidth) * placeholder.scale
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.length > 0
        placeholderHasText: control.placeholderHasText
        horizontalPadding: control.Material.textFieldHorizontalPadding
    }
}
