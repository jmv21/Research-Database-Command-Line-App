import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Window
import QtQuick.Controls.Material

import QmlIntegration

import "../forms"
import "../Components/"
import "../Controls"
import "../AppComponents"

Item {
    ListView {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        id: studyListView
        width: parent.width
        height: parent.height
        model: mainController.studyModel
        spacing: 8
        clip: true

        delegate: Rectangle {
            width: ListView.view.width - 20
            height: studyColumn.height + 20
            x: 10
            color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"
            radius: 5
            border.color: "#dee2e6"
            border.width: 1

            Column {
                id: studyColumn
                width: parent.width - 20
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: model.studyCode
                    font.bold: true
                    font.pixelSize: 14
                    color: "#2c3e50"
                }

                Text {
                    text: model.title
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                Row {
                    spacing: 15
                    Text {
                        text: "Start: " + (model.startDate || "N/A")
                        font.pixelSize: 12
                        color: "#7f8c8d"
                    }
                    Text {
                        text: "End: " + (model.endDate || "N/A")
                        font.pixelSize: 12
                        color: "#7f8c8d"
                    }
                }

                Text {
                    text: "Status: " + model.status
                    font.pixelSize: 12
                    color: {
                        switch(model.status) {
                        case "active": return "#27ae60";
                        case "completed": return "#3498db";
                        case "planned": return "#f39c12";
                        default: return "#7f8c8d";
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Selected study:", model.studyId)
                    // You can add navigation to study details here
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 8
        }

        Label {
            anchors.centerIn: parent
            text: "No studies found"
            visible: studyListView.count === 0
            font.pixelSize: 16
            color: "#7f8c8d"
        }
    }
}
