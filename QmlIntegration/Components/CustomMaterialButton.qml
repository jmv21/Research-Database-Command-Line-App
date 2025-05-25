import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "../js/utils.js" as Utils

CustomBaseMaterialButton {
    opacity: primary ? 1 : (hovered ?  0.8 : 1)
    property bool primary: true
    property bool busy: false
    property bool extraEnableHint: true
    enabled: !busy && extraEnableHint
    backgroundBorder.width: primary ? 0 : 1
    backgroundBorder.color: enabled ? (primary ? backgroundColor : Material.foreground) : Material.hintTextColor
    Material.background:  primary ? backgroundColor : "#00000000"
    referenceBackgroundColor: primary ? Material.background : (parent ? parent.Material.background : Material.System)
    Material.roundedScale: Material.ExtraSmallScale
    Material.foreground: primary ? Utils.getTextColor(Material.background.toString() !== "#00000000" ? Material.background : backgroundColor) : backgroundColor
    // Material.theme: !enabled ? (parent ? parent.Material.theme : Material.System) : (Utils.isLightColor(referenceBackgroundColor)
    //                                                                                  ? Material.Light : Material.Dark)

    onCheckedChanged: {
        primary = !primary
    }
}
