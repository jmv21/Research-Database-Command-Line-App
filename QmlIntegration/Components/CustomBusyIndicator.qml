import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

Item {
    id: control
    width: height
    height: 50
    property bool running: visible
    property alias contentImage: busyIndicatorImage
    property alias sourceImage: busyIndicatorImage.icon.source
    property alias sourceImageColor: busyIndicatorImage.icon.color

    IconLabel {
        id: busyIndicatorImage
        anchors.fill: parent
        icon.color: Globals.colors.primary
        icon.width: parent.width
        icon.height: parent.height

        RotationAnimator {
            target: busyIndicatorImage
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: control.running
        }
    }
}

