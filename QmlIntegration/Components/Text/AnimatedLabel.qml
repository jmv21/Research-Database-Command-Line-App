import QtQuick
import QtQuick.Controls.Material
import "../../Controls"

Item {
    id: control
    implicitWidth: Math.max(txt1.implicitWidth, txt2.implicitWidth)
    implicitHeight: Math.max(txt1.height, txt2.height)
    property bool animated: true
    property string text: ""
    property int maximumLineCount: 2
    property int currentActiveTxt: 1
    property int pixelSize: 16
    property int weight: 400
    property color referenceBackgroundColor: Material.background
    property color textColor: txt1.textColor
    property CustomLabel currentLabel: txt1
    property alias horizontalAlignment: txt1.horizontalAlignment
    property alias txt1: txt1
    property alias txt2: txt2

    property StateGroup stateGroup: StateGroup{
        states: [
            State {
                name: "txt1Active"
                PropertyChanges {
                    target: txt1
                    x: 0 // Position txt1 in view
                    opacity: 1.0 // Ensure txt1 is fully visible
                }
                PropertyChanges {
                    target: txt2
                    x: width/2
                    opacity: 0.0 // Fade out txt2 as it moves out
                }
            },
            State {
                name: "txt2Active"
                PropertyChanges {
                    target: txt2
                    x: 0 // Position txt2 in view
                    opacity: 1.0 // Ensure txt2 is fully visible
                }
                PropertyChanges {
                    target: txt1
                    x: width/2 // Move txt1 offscreen to the left
                    opacity: 0.0 // Fade out txt1 as it moves out
                }
            }
        ]

        transitions: [
            Transition {
                from: "txt1Active"
                to: "txt2Active"
                ParallelAnimation {
                    NumberAnimation {
                        target: txt1
                        property: "x"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt2
                        properties: "x" // Animate position (slide effect)
                        from: -width/2
                        duration: control.animated ? 350 : 0
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt1
                        property: "opacity" // Animate fade effect
                        duration: control.animated ? 250 : 0
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt2
                        property: "opacity" // Animate fade effect
                        duration: control.animated ? 500 : 0
                        easing.type: Easing.InOutQuad
                    }
                }
            },

            Transition {
                from: "txt2Active"
                to: "txt1Active"
                ParallelAnimation {

                    NumberAnimation {
                        target: txt2
                        property: "x"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt1
                        properties: "x" // Animate position (slide effect)
                        from: -width/2
                        duration: control.animated ? 350 : 0
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt2
                        property: "opacity" // Animate fade effect
                        duration: control.animated ? 250 : 0
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: txt1
                        property: "opacity" // Animate fade effect
                        duration: control.animated ? 500 : 0
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]
    }

    CustomLabel {
        id: txt1
        width: parent.width
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: control.maximumLineCount
        backgroundColor: control.referenceBackgroundColor
        font {
            pixelSize: control.pixelSize
            weight: control.weight
        }
        x: 0 // Initial position for txt1
        opacity: 1.0 // Initial opacity for txt1
    }

    CustomLabel {
        id: txt2
        width: parent.width
        color: control.textColor
        horizontalAlignment: control.horizontalAlignment
        maximumLineCount: control.maximumLineCount
        backgroundColor: control.referenceBackgroundColor
        font {
            pixelSize: control.pixelSize
            weight: control.weight
        }
        x: width // Initial position for txt2 (offscreen to the right)
        opacity: 0.0 // Initial opacity for txt2
    }

    onTextChanged: {
        if (currentActiveTxt === 1) {
            txt2.text = control.text;
            currentActiveTxt = 2;
            stateGroup.state = "txt2Active"; // Change state to activate txt2
        } else {
            txt1.text = control.text;
            currentActiveTxt = 1;
            stateGroup.state = "txt1Active"; // Change state to activate txt1
        }
    }
}
