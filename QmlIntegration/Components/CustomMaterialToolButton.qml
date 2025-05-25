import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

// Use example:
//CustomMaterialToolButton{
//    icon.source: "file:///C:/Users/jmv21/OneDrive/Documents/QT test playground/SplitViewsMenuPlayground/gear.svg"
//    tooltipText: "Settings"
//}

CustomMaterialBaseToolButton{
    property bool busy: false
    property bool extraEnabledHints: true
    enabled: !busy && extraEnabledHints
    Material.roundedScale: Material.FullScale
    width: height
    height: 28
}

//Item{
//    id: control
//    height: rectButton.height
//    width: rectButton.width
//    property alias icon: rectButton.icon
//    property alias text: rectButton.text
//    property alias backgroundOpacity: background.opacity
//    property alias baseToolButton: rectButton
//    property string tooltipText: ""
//    property alias tooltipVisible: rectButton.tooltipVisible

//    signal clicked

//    Material.roundedScale: Material.FullScale

//    Rectangle{
//        id: background
//        anchors.centerIn: parent
//        height: rectButton.icon.height + 8
//        width: rectButton.icon.width + 8
//        radius: control.Material.roundedScale === Material.FullScale ? height / 2 : control.Material.roundedScale
//        color: control.Material.buttonColor(control.Material.theme, control.Material.background,
//                                            control.Material.accent, rectButton.enabled, rectButton.flat, rectButton.highlighted, rectButton.checked)
//        opacity: 0.2
//    }

//    CustomMaterialBaseToolButton{
//        id: rectButton
//        Material.foreground: control.Material.foreground
//        Material.roundedScale: control.Material.roundedScale
//        onClicked: {
//            control.clicked()
//        }
//        tooltipText: control.tooltipText
//    }
//}
