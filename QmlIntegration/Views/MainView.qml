import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Dialogs

import QmlIntegration

import "./"
import "../forms"
import "../Components/"
import "../Components/Text"
import "../Controls"
import "../AppComponents"


// Item{
//     ListView {anchors.fill: parent
//         model: mainController.quickCommands.commands
//         delegate: Button {
//             width: 200
//             text: modelData.title
//             onClicked: {
//                 commandDescription.text = modelData.description
//                 commandPreview.text = modelData.sql
//             }
//         }
//     }

//     // To show command details
//     Text {
//         id: commandDescription
//         wrapMode: Text.WordWrap
//     }
//     Text {
//         id: commandPreview
//         font.family: "Courier"
//         wrapMode: Text.WordWrap
//     }

//     // To execute a command
//     Button {
//         anchors.bottom: parent.bottom
//         text: "Execute Selected"
//         onClicked: {
//             if (listView.currentIndex >= 0) {
//                 mainController.executeQuickCommand(
//                             mainController.quickCommands.commands[listView.currentIndex].cmd_id
//                             )
//             }
//         }
//     }
// }

Item{
    QuickActionsSelectionDialog{
        id: quickActionsDialog
        model: mainController.quickCommands.commands
        draggable: true
        x: (parent.width - width)/2
        y: (parent.height - height)/2

        width: Math.min(parent.width/2, 400)
        height: Math.min(implicitHeight, 600)

        onAccepted: {
            commandInput.text = "sql " + quickActionsDialog.commandSelected
            close()
        }

        onRejected: {
            close()
        }

        onOpened: {
            listView.currentIndex = -1
        }
    }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 30
        spacing: 35

        RowLayout{
            CustomMaterialToolButton{
                icon.source: Globals.icons.leftArrow
                onClicked: {
                    mainController.logout()
                }
            }

            InfoBlock{
                Layout.fillWidth: true
                title: "Command Execution"
                titlePixelSize: Globals.typography.textTitle
                description: qsTr("Enter a command in the field below, type 'help' for available commands, or click Quick Action to choose a preset one.")
            }
        }

        RowLayout{
            id: buttonsLayout
            Layout.fillWidth: true
            spacing: 20

            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout{
                    id: contentLayout
                    width: parent.width
                    height: parent.height
                    Flickable {
                        id: commandInputTextAreaFlickable
                        Layout.fillWidth: true
                        Layout.topMargin: -10
                        Layout.fillHeight: true
                        Behavior on height {
                            NumberAnimation{
                                duration: 300
                            }
                        }
                        ScrollBar.vertical: CustomScrollBar {
                            id: commandTextAreaScroll
                            topInset: 10
                            topPadding: 10
                            policy: ScrollBar.AlwaysOn
                        }
                        interactive: commandTextAreaScroll.visible
                        TextArea.flickable: TextArea {
                            id: commandInput
                            width: commandInputTextAreaFlickable.width - rightPadding
                            font.pixelSize: Globals.typography.textBody
                            Material.roundedScale: Material.SmallScale
                            Material.accent: Globals.colors.primary
                            rightPadding: commandTextAreaScroll.width + 5
                            wrapMode: Text.Wrap
                            property string previousText: ""

                            placeholderText: "Enter database command"

                            onTextChanged: {
                                if (text.length > 5000) {
                                    var cursorPos = cursorPosition
                                    text = previousText
                                    cursorPosition = Math.min(cursorPos, 5000)
                                } else {
                                    previousText = text
                                }
                            }
                            Component.onCompleted: previousText = text
                        }
                    }

                    CustomLabel {
                        id: counterLabel
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: commandInput.leftPadding
                        text: commandInput.text.length + "/5000"
                    }
                }
            }

            Item{
                Layout.fillHeight: true
                Layout.fillWidth: true
                RAppButton{
                    id: executeButton
                    anchors{
                        left: parent.left
                        bottom: parent.bottom
                    }
                    text: "Execute"
                    onClicked: {
                        mainController.executeCommand(commandInput.text)
                    }
                }

                RAppButton{
                    id: selectQuickCommandButton
                    anchors{
                        left: parent.left
                        bottom: executeButton.top
                        bottomMargin: 20
                    }
                    backgroundColor: Globals.colors.primary
                    primary: false
                    text: "Quick Action"
                    onClicked: {
                        quickActionsDialog.open()
                    }
                }

                RAppButton{
                    id: exportButton
                    extraEnableHint: mainController.canExport
                    anchors{
                        left: parent.left
                        bottom: selectQuickCommandButton.top
                        bottomMargin: 20
                    }
                    backgroundColor: Globals.colors.tertiary
                    text: "Export to CSV"
                    icon.source: Globals.icons.file
                    onClicked: {
                        fileDialog.open()
                    }
                }
            }


        }

        RowLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 30

            // Results display
            Flickable {
                id: outputTextAreaFlickable
                Layout.fillWidth: true
                anchors.topMargin: -10
                Layout.fillHeight: true
                Behavior on height {
                    NumberAnimation{
                        duration: 300
                    }
                }
                ScrollBar.vertical: CustomScrollBar {
                    id: outputTextAreaScroll
                    topInset: 10
                    topPadding: 10
                    policy: ScrollBar.AlwaysOn
                }
                interactive:outputTextAreaScroll.visible
                TextArea.flickable: TextArea {
                    id: outputTextArea
                    width: outputTextAreaFlickable.width - rightPadding
                    font.pixelSize: Globals.typography.textBody
                    Material.roundedScale: Material.SmallScale
                    Material.accent: Globals.colors.primary
                    rightPadding: outputTextAreaScroll.width + 5
                    wrapMode: Text.Wrap
                    property string previousText: ""

                    placeholderText: "Output(readonly)"
                    readOnly: true

                    // onTextChanged: {
                    //     if (text.length > 5000) {
                    //         var cursorPos = cursorPosition
                    //         text = previousText
                    //         cursorPosition = Math.min(cursorPos, 5000)
                    //         mainWindow.descriptionTextLimitExceed()
                    //     } else {
                    //         previousText = text
                    //     }
                    // }
                    // Component.onCompleted: previousText = text
                }
            }
        }
    }

    // RAppButton{
    //     anchors.horizontalCenter:  parent.horizontalCenter
    // }

    // Busy indicator
    RAppBusyOverlay {
        anchors.fill: parent
        visible: mainController.interpreterBusy
        text: "Running the command please wait.."
    }

    // Connections to handle results
    Connections {
        target: mainController

        function onCommandExecuted(command, result) {
            console.log("Command:", command)
            console.log("Result:", result)
            outputTextArea.text = result
        }
    }

    FileDialog {
        id: fileDialog
        title: "Export to CSV"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            if(mainController.exportToCsv(selectedFile)) {
                console.log("Export successful")
            }
        }
    }
}
