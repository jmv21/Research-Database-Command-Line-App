import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.ToolButton {
    id: control
    property bool isTransparent: Material.background.toString() === "#00000000"
    property bool noBackground: false
    property bool staticBackground: false
    property bool backgroundApplyClipRadius: false
    property alias defaultToolTip: defaultToolTip
    property string tooltipText: ""
    property bool tooltipVisible: hoverHandler.hovered && tooltipText
    property alias hoverHandler: hoverHandler
    property color backgroundColor: control.Material.rippleColor
    property bool iconLabelVisible: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    icon.width: 24
    icon.height: 24
    icon.color: !enabled ? Material.hintTextColor : checked || highlighted ? Material.accent : Material.foreground

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        visible: control.iconLabelVisible

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? control.Material.hintTextColor :
                                  control.checked || control.highlighted ? control.Material.accent : control.Material.foreground
    }


    background: Ripple {
        visible: !control.noBackground
        implicitWidth: control.Material.touchTarget
        implicitHeight: control.Material.touchTarget

        readonly property bool square: control.contentItem.width <= control.contentItem.height

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        clip: !square
        clipRadius: control.backgroundApplyClipRadius ? control.Material.roundedScale : null
        width: square ? parent.height / 2 : parent.width
        height: square ? parent.height / 2 : parent.height
        pressed: control.pressed
        anchor: control
        active: control.enabled && (control.down || control.visualFocus || control.hovered) || control.staticBackground
        color: control.backgroundColor
    }

    HoverHandler{
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    CustomMaterialToolTip{
        id: defaultToolTip
        visible: tooltipVisible
        text: control.tooltipText
    }
}

