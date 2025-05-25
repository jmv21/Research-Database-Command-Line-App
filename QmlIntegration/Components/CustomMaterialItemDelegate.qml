import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../js/utils.js" as Utils

T.ItemDelegate {
    id: control
    property color highlightedColor: Material.listHighlightColor
    property alias defaultToolTip: defaultToolTip
    property color backgroundColor: "transparent"
    property color implicitBackgroundColor: backgroundColor
    property color textColor: backgroundColor.toString() !== "#00000000" ? Utils.getTextColor(implicitBackgroundColor) : Material.foreground
    property string tooltipText: ""
    property bool tooltipVisible: control.hovered && tooltipText
    property int backgrndBorderWidth: 0
    property color backgrondBorderColor: Material.foreground
    // property string overlappingIconSource: ""
    // property color overlappingIconColor: icon.color
    // property color overlapingIconBackgroundColor: "transparent"

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 16
    verticalPadding: 8
    spacing: 16

    icon.width: 1.2 * font.pixelSize|0
    icon.height: 1.2 * font.pixelSize|0
    icon.color: enabled ? textColor : Material.hintTextColor

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: control.display === IconLabel.IconOnly || control.display === IconLabel.TextUnderIcon ? Qt.AlignCenter : Qt.AlignLeft
        // overlappingIconSource: control.overlappingIconSource
        // overlappingIconColor: control.overlappingIconColor
        // overlapingIconBackgroundColor: control.overlapingIconBackgroundColor
        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? control.textColor : control.Material.hintTextColor
    }

    background: Rectangle {
        //implicitHeight: control.Material.delegateHeight
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
        color: control.hovered ? control.Material.rippleColor : (control.highlighted ? control.Material.listHighlightColor : control.backgroundColor)
        radius: control.Material.roundedScale
        border.width: control.backgrndBorderWidth
        border.color: control.backgrondBorderColor

        Ripple {
            width: parent.width
            height: parent.height
            clipRadius: parent.radius

            clip: visible
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus)
            color: control.Material.rippleColor
        }
    }

    CustomMaterialToolTip{
        id: defaultToolTip
        visible: tooltipVisible
        text: control.tooltipText
    }
}
