import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QmlIntegration

import "../Components"
import "../Controls"
import "../Components/Text"

Rectangle {
    id: control
    property string title: ""
    property string description: ""
    property string command: ""
    property string id: ""
    property bool selected: false
    signal clicked
    radius: Material.SmallScale

    color: Material.background

    implicitHeight: contentItem_.implicitHeight + 20

    border.color: mA.containsMouse ? Material.foreground : ( selected ? Material.accent : Material.hintTextColor)

    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }

    Item{
        id: contentItem_
        anchors.fill: parent
        anchors.margins: 10
        implicitWidth: infoBlock.implicitWidth
        implicitHeight: infoBlock.implicitHeight

        InfoBlock{
            id: infoBlock
            width: parent.width
            referenceBackgroundColor: control.Material.background
            title:control.title
            description: control.description
        }
    }

    MouseArea{
        id: mA
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.clicked()
        }
    }
}
