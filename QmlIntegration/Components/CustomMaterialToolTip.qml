import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Material

import "../Controls/"

T.ToolTip {
    id: control
    property bool hoverEnabled: false
    property bool hovered: hA.hovered
    property bool triangleVisible: true
    property bool tooltipVisibleHint: hoverEnabled ? hovered : false
    property color backgroundColor: Material.tooltipColor
    property real extraSeparation: triangleVisible ? 5 : 0
    readonly property alias defaultTextContentItem: contentLabel
    readonly property alias hoverHandlerItem: hA

    visible: tooltipVisibleHint && text

    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: parent ? parent.height + extraSeparation : 0

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 12
    padding: 8
    horizontalPadding: padding + 8

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    Material.roundedScale: Material.ExtraSmallScale

    contentItem: CustomLabel{
        id: contentLabel
        text: control.text
        font: control.font
        wrapMode: Text.Wrap
        backgroundColor: control.backgroundColor
    }

    background: Item {
        implicitHeight: Material.tooltipHeight

        Rectangle {
            id: tooltipBody
            anchors.fill: parent
            color: control.backgroundColor
            opacity: 0.9
            radius: control.Material.roundedScale
        }

        Component {
            id: trianglePointerComponent
            Canvas {
                id: trianglePointer
                width: parent.width
                height: parent.height
                property int margin: width/2
                property bool pointingDown: parent.pointingDown

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.beginPath()

                    if (pointingDown) {
                        // Triangle pointing down
                        ctx.moveTo(width/2, height)     // Bottom center point
                        ctx.lineTo(0, 0)               // Top left point
                        ctx.lineTo(width, 0)           // Top right point
                    } else {
                        // Triangle pointing up
                        ctx.moveTo(width/2, 0)         // Top center point
                        ctx.lineTo(0, height)          // Bottom left point
                        ctx.lineTo(width, height)      // Bottom right point
                    }

                    ctx.closePath()
                    ctx.fillStyle = control.backgroundColor
                    ctx.fill()
                }

                // Force repaint when needed
                Component.onCompleted: requestPaint()
                onVisibleChanged: requestPaint()
            }
        }

        Loader {
            id: loader_trianglePointer
            property int margin: width/2
            property bool pointingDown: control.y < 0
            anchors.bottom: !pointingDown ? tooltipBody.top : undefined
            anchors.top: pointingDown ? tooltipBody.bottom : undefined

            x: control.parent ? determineX(control.x, control.parent.width, control.width, width, loader_trianglePointer.margin) : 0

            function determineX(parentX, controlParentWidth, controlWidth, width, margin){
                var tooltipXOffset = parentX
                var parentCenterX = (controlParentWidth / 2) - tooltipXOffset
                return Math.max(margin, Math.min(parentCenterX - (width / 2), controlWidth - margin))
            }

            width: 12
            height: 8
            active: control.triangleVisible /* !(control.x < -control.width + margin || control.x > control.width - margin)
                     && !((control.y > 0 && control.y < control.height - control.extraSeparation) || (control.y < 0 && control.y > control.height + control.extraSeparation))
                     && control.tringleVisible*/
            sourceComponent: trianglePointerComponent
        }

        HoverHandler {
            id: hA
            enabled: control.hoverEnabled
        }
    }

    enter: Transition {
        ParallelAnimation{
            //            NumberAnimation { property: "y"; from: 0; to: control.objectiveY; easing.type: Easing.OutQuad; duration: 200 }
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; easing.type: Easing.InQuad; duration: 500 }
            NumberAnimation { property: "scale"; from: 0; to: 1.0; easing.type: Easing.InQuad; duration: 200 }
        }
    }

    exit: Transition {
    }
}
