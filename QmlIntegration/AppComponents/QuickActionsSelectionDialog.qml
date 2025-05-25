import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QmlIntegration

import "./"
import "../Components"
import "../Controls"
import "../Components/Text"

CustomMaterialDialog {
    id: root
    standardButtons: Dialog.Close| Dialog.Save
    title: "Select a quick action from the list"
    property string commandSelected: ""
    property var model: null
    property alias listView: quickCommandListView

    ListView{
        id: quickCommandListView
        implicitHeight: 300
        width: parent.width
        model: root.model
        spacing: 10
        clip: true

        header: Item {
            width: parent.width
            height: 20
        }
        footer: Item {
            width: parent.width
            height: 20
        }

        ScrollBar.vertical: CustomScrollBar {
            id: vScroll
            topInset: 10
            topPadding: 10
            policy: ScrollBar.AlwaysOn
        }

        delegate: QuickCommandDelegate{
            title: modelData.title
            width: parent?.width - vScroll.width - 10 ?? 100 - vScroll.width - 10
            x: 10
            height: implicitHeight
            description: modelData.description
            command: modelData.sql
            selected: quickCommandListView.currentIndex === index
            onClicked: {
                quickCommandListView.currentIndex = index
            }

            onSelectedChanged: {
                if(selected){
                    root.commandSelected = command
                }
            }
        }
    }
}
