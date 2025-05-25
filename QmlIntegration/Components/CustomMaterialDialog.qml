import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Controls"

CustomBaseMaterialDialog {
    id: control
    property var dialogButtonBoxItem: null
    property var dragAllowedItem: parent
    property string subtitle: ""
    property color subtitleColor: Material.hintTextColor
    property int subtitlePixelSize: 16
    property int subtitleWeight: 400
    property Component topRightComponent: null
    property bool topRightComponentActive: false

    property bool draggable: false
    property bool isDragging: false
    property var getStandardButton: dialogButtonBoxItem ? function(mStandardButton) {return dialogButtonBoxItem.standardButton(mStandardButton);}
    : function(mStandardButton){return control.standardButton(mStandardButton)}
    width: implicitWidth
    height: implicitHeight
    bottomPadding: footer.height

    header: Item{
        implicitHeight:contentLayout.implicitHeight
        implicitWidth: contentLayout.implicitWidth

        PaddedRectangle {
            anchors.fill: parent
            radius: control.background.radius
            color: control.backgroundColor
            bottomPadding: -radius
            clip: true
        }

        ColumnLayout{
            id: contentLayout
            width: parent.width

            CustomLabel {
                text: control.title
                Layout.fillWidth: true
                maximumLineCount: 1
                backgroundColor: control.backgroundColor
                visible: control.title
                padding: control.padding
                bottomPadding: 0
                font.pixelSize: control.titlePixelSize
                font.weight: control.titleWeight
            }

            CustomLabel {
                text: control.subtitle
                Layout.fillWidth: true
                color: control.subtitleColor ? control.subtitleColor : textColor
                maximumLineCount: 1
                backgroundColor: control.backgroundColor
                visible: control.subtitle
                bottomPadding: 0
                leftPadding: control.padding
                rightPadding: control.padding
                font.pixelSize: control.subtitlePixelSize
                font.weight: control.subtitleWeight
            }
        }

        Loader{
            anchors.right: parent.right
            anchors.top: parent.top
            active: control.topRightComponentActive
            sourceComponent: control.topRightComponent
        }
    }

    background: Rectangle {
        radius: control.Material.roundedScale
        color: control.backgroundColor

        layer.enabled: control.Material.elevation > 0
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }

        MouseArea {
            id: dragArea
            enabled: control.draggable
            anchors.fill: parent
            property real startX
            property real startY

            onPressed: (mouse) => {
                           startX = mouse.x
                           startY = mouse.y
                           control.isDragging = true
                       }

            onReleased: () => {
                            control.isDragging = false
                        }

            onPositionChanged: (mouse) => {
                                   if (!control.isDragging) return

                                   let newX = control.x + mouse.x - startX
                                   let newY = control.y + mouse.y - startY

                                   // Ensure the dialog stays within the screen boundaries
                                   newX = Math.max(0, Math.min(newX, control.dragAllowedItem.width - control.width))
                                   newY = Math.max(0, Math.min(newY, control.dragAllowedItem.height - control.height))

                                   control.x = newX
                                   control.y = newY
                               }
        }
    }

    footer: Item {
        implicitHeight: dialogButtonBox.implicitHeight
        implicitWidth: dialogButtonBox.implicitWidth
        CustomMaterialDialogButtonBox {
            id: dialogButtonBox
            Material.roundedScale: control.Material.roundedScale

            anchors.fill: parent
            standardButtons: control.standardButtons

            onStandardButtonsChanged: {
                if(control.dialogButtonBoxItem !== this)
                    control.dialogButtonBoxItem = this
            }

            onAccepted: {
                control.accepted()
            }

            onRejected: {
                control.rejected()
            }

            Component.onCompleted: {
                if(control.dialogButtonBoxItem !== this)
                    control.dialogButtonBoxItem = this
            }
        }
    }

    Connections {
        target: control.dragAllowedItem
        enabled: control.draggable

        function onWidthChanged() {
            forceBounds();
        }

        function onHeightChanged() {
            forceBounds();
        }
    }

    function forceBounds() {
        if (control.x + control.width > control.dragAllowedItem.width) {
            control.x = control.dragAllowedItem.width - control.width
        }
        if (control.y + control.height > control.dragAllowedItem.height) {
            control.y = control.dragAllowedItem.height - control.height
        }

        if (control.x < 0) {
            control.x = 0
        }
        if (control.y < 0) {
            control.y = 0
        }
    }
}
