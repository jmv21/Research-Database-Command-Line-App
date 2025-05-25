import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QmlIntegration

import "../Components"
import "../Controls"

BusyOverlay {
    id: control
    iconSource: Globals.icons.busy
    backgroundOpacity: 0.6
    property color iconColor: Globals.colors.primary

    Behavior on progress {
        NumberAnimation{
            easing.type: Easing.InOutCubic
            duration: 200
        }
    }

    Material.accent: Globals.colors.primary
}
