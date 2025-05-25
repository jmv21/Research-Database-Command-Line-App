import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

TreeViewDelegate {
    id: control
    property alias borderColor: background.border.color
    property alias borderWidth: background.border.width

    background: Rectangle {
        id: background
        implicitWidth: 64
        implicitHeight: control.Material.buttonHeight


        radius: control.Material.roundedScale === Material.FullScale ? height / 2 : control.Material.roundedScale
        color: control.Material.buttonColor(control.Material.theme, control.Material.background,
                                            control.Material.accent, control.enabled, control.flat, control.highlighted, control.checked)

        border.color: "transparent"
        border.width: 1

        layer.enabled: control.enabled && color.a > 0 && !control.flat
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }

        Ripple {
            clip: true
            clipRadius: parent.radius
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus || control.hovered)
            color: control.flat && control.highlighted ? control.Material.highlightedRippleColor : control.Material.rippleColor
        }
    }
}
