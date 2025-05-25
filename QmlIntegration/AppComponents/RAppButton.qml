import QtQuick 2.15
import QtQuick.Controls.Material
import QmlIntegration

import "../Components"
import "../js/utils.js" as Utils

CustomMaterialButton {
    id: control
    property real busyIndicatorMaximunHeight: 100
    property bool isLightColor: Utils.isLightColor(backgroundColor)

    Material.theme: {
        if (!enabled) {
            return Globals.materialTheme
        }
        if (primary) {
            return control.isLightColor ? Material.Light : Material.Dark
        }
        return Globals.materialTheme
    }

    backgroundColor: Globals.colors.primary
    iconLabelVisible: !busy
    enabled: !busy && extraEnableHint
    RAppBusyIndicator{
        anchors.centerIn: parent
        height: Math.min(control.height * 0.6, control.busyIndicatorMaximunHeight)
        sourceImageColor: {
            if (control.backgroundColor.toString() !== "#00000000") {
                return Utils.getTextColor(control.background.color)
            }
            return Material.foreground
        }
        width: height
        visible: parent.busy
        Material.roundedScale: parent.Material.roundedScale
    }
}
