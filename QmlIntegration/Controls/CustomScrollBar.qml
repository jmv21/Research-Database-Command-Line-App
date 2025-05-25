import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Templates as T

import "../Components/"

T.ScrollBar {
    id: control
    property bool enableToolTip: false
    property string tooltipText: ""

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    property alias indicatorToolTip: indicatorToolTip
    property real scrollBarM: 10
    height: scrollBarM
    width: scrollBarM
    padding: control.interactive ? 1 : 2
    visible: policy !== T.ScrollBar.AlwaysOff && ((policy===ScrollBar.AlwaysOn && size < 1) || size < 1)
    minimumSize: orientation === Qt.Horizontal ? height / width : width / height
    policy: ScrollBar.AsNeeded

    contentItem: Rectangle {
        implicitWidth: control.interactive ? 13 : 4
        implicitHeight: control.interactive ? 13 : 4
        radius: Material.SmallScale
        color: control.pressed ? control.Material.scrollBarPressedColor :
                                 control.interactive && control.hovered ? control.Material.scrollBarHoveredColor : control.Material.scrollBarColor
        opacity: 0.0
        CustomMaterialToolTip {
            id: indicatorToolTip
            visible:  control.enabled && control.tooltipText && control.enableToolTip ? (control.hovered || control.pressed ? true : false) : false
            text: control.tooltipText

            exit: Transition {
                ParallelAnimation{
                    NumberAnimation { property: "opacity"; to: 0; easing.type: Easing.OutQuad; duration: 500 }
                    NumberAnimation { property: "scale"; to: 0; easing.type: Easing.OutQuad; duration: 300 }
                }
            }
        }
    }

    background: Rectangle {
        implicitWidth: control.interactive ? 16 : 4
        implicitHeight: control.interactive ? 16 : 4
        radius: Material.SmallScale
        color: "#0e000000"
        opacity: 0.0
        visible: control.interactive
    }

    states: State {
        name: "active"
        when: control.policy === T.ScrollBar.AlwaysOn || (control.active && control.size < 1.0)
    }

    transitions: [
        Transition {
            to: "active"
            NumberAnimation { targets: [control.contentItem, control.background]; property: "opacity"; to: 1.0 }
        },
        Transition {
            from: "active"
            SequentialAnimation {
                PropertyAction{ targets: [control.contentItem, control.background]; property: "opacity"; value: 1.0 }
                PauseAnimation { duration: 2450 }
                NumberAnimation { targets: [control.contentItem, control.background]; property: "opacity"; to: 0.0 }
            }
        }
    ]

    function scrollToTop() {
        if (control.position !== 0)
            scrollToTopAnimation.start()
    }

    function scrollToBottom() {
        if (position !== 1.0 - size)
            scrollToBottomAnimation()
    }

    SequentialAnimation {
        id: scrollToTopAnimation
        PropertyAction { target: control; property: "active"; value: true }
        NumberAnimation { target: control; property: "position"; to: 0; duration: 300}
        PauseAnimation {duration: 200}
        PropertyAction { target: control; property: "active"; value: false }
    }

    SequentialAnimation {
        id: scrollToBottomAnimation
        PropertyAction { target: control; property: "active"; value: true }
        NumberAnimation { target: control; property: "position"; to: 1.0 - size; duration: 200; easing.type: Easing.InOutQuad }
        PropertyAction { target: control; property: "active"; value: false }
    }
}


//ScrollBar{
//    id: control
//    orientation: Qt.Vertical
//    width:  10
//    policy: ScrollBar.AsNeeded
//    height: parent.availableHeight
//    property alias scrollIndicator: scrollIndicator
//    property bool scrolling: false
//    property bool backgroundVisible: false
//    property color backgroundColor: Material.color(Material.Grey,Material.Shade800)
//    property color backgroundBorderColor: "black"
//    property color accentColor: Material.accentColor
//    minimumSize: orientation === Qt.Horizontal ? height / width : width / height
//    property bool isVisible: (scrollIndicator.opacity || backgroundRect.visible)
//    visible: policy !== ScrollBar.AlwaysOff && (policy===ScrollBar.AlwaysOn || size < 1)



//    background: Rectangle {
//        id: backgroundRect
//        visible: backgroundVisible
//        anchors.fill: parent
//        color: control.backgroundColor
//        border.color: control.backgroundBorderColor
//        border.width: 1
//        radius: 20
//        opacity: 0.8
//    }

//    contentItem: Rectangle {
//        id: scrollIndicator
//        implicitWidth: control.interactive ? 10 : 4
//        implicitHeight: control.interactive ? 10 : 4

//        radius: 20
//        border.color: control.backgroundBorderColor
//        border.width: backgroundVisible ? 1 : 0
//        color: control.pressed ? control.Material.scrollBarPressedColor :
//                                 control.interactive && control.hovered ? control.Material.scrollBarHoveredColor : control.Material.scrollBarColor
//        opacity: 0

//        Behavior on opacity {
//            NumberAnimation {
//                duration: 200
//            }
//        }
//    }

//    function scrollToTop() {
//        if (control.position !== 0)
//            scrollToTopAnimation.start()
//    }

//    function scrollToBottom() {
//        if (position !== 1.0 - size)
//            scrollToBottomAnimation()
//    }

//    SequentialAnimation {
//        id: scrollToTopAnimation
//        PropertyAction { target: control; property: "active"; value: true }
//        NumberAnimation { target: control; property: "position"; to: 0; duration: 300}
//        PauseAnimation {duration: 200}
//        PropertyAction { target: control; property: "active"; value: false }
//    }

//    SequentialAnimation {
//        id: scrollToBottomAnimation
//        PropertyAction { target: control; property: "active"; value: true }
//        NumberAnimation { target: control; property: "position"; to: 1.0 - size; duration: 200; easing.type: Easing.InOutQuad }
//        PropertyAction { target: control; property: "active"; value: false }
//    }

//}
