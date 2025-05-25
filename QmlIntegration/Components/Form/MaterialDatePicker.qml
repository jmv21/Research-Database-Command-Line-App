/* Copyright (C) 2025 The Lucerum Inc.
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum Inc. under the QT Commercial License as agreed with The Qt Company.
 * For more details, see <https://www.qt.io/licensing/>.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import QtQuick
import QtQuick.Controls.Material

import "../../Controls"
import "../../Components/"
import "../../Components/Menu"

Item {
    id: root
    width: 320
    height: 420

    // Public properties
    property date selectedDate: new Date()
    property bool opened: false
    property color primaryColor: Material.primaryColor
    property color accentColor: Material.accent

    // Private properties
    QtObject {
        id: internal
        property date viewDate: new Date()
    }

    // Signals
    signal dateSelected(date selectedDate)

    function toggle() {
        opened = !opened
    }

    function navigateMonths(offset) {
        internal.viewDate = new Date(internal.viewDate.getFullYear(),
                                    internal.viewDate.getMonth() + offset,
                                    1)
    }

    // Popup implementation
    Popup {
        id: datePickerPopup
        width: parent.width
        height: parent.height
        anchors.centerIn: Overlay.overlay
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        visible: root.opened
        padding: 0

        onClosed: root.opened = false
        Material.elevation: 8

        contentItem: Column {
            spacing: 0

            // Header
            Rectangle {
                width: parent.width
                height: 80
                color: root.primaryColor

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.bottomMargin: 16
                    spacing: 4

                    Text {
                        text: "SELECT DATE"
                        color: Qt.rgba(1, 1, 1, 0.7)
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    Text {
                        text: Qt.formatDate(internal.viewDate, "MMMM yyyy")
                        color: "white"
                        font.pixelSize: 24
                    }
                }

                // Month navigation
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Button {
                        text: "<"
                        flat: true
                        Material.foreground: "white"
                        onClicked: navigateMonths(-1)
                    }

                    Button {
                        text: ">"
                        flat: true
                        Material.foreground: "white"
                        onClicked: navigateMonths(1)
                    }
                }
            }

            // Day names header
            Row {
                width: parent.width
                height: 40
                spacing: 0

                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    Label {
                        width: parent.width / 7
                        height: parent.height
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }
                }
            }

            // Month grid
            MonthGrid {
                id: monthGrid
                width: parent.width
                height: width
                month: internal.viewDate.getMonth()
                year: internal.viewDate.getFullYear()
                spacing: 0

                delegate: Rectangle {
                    width: monthGrid.width / 7
                    height: width
                    color: {
                        if (model.day === root.selectedDate.getDate() &&
                            model.month === root.selectedDate.getMonth() &&
                            model.year === root.selectedDate.getFullYear()) {
                            return root.accentColor
                        }
                        return "transparent"
                    }
                    radius: width / 2

                    Label {
                        anchors.centerIn: parent
                        text: model.day
                        color: {
                            if (model.month !== monthGrid.month) return "#999"
                            if (parent.color === root.accentColor) return "white"
                            return model.today ? root.accentColor : "black"
                        }
                        font.bold: model.today
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (model.month === monthGrid.month) {
                                root.selectedDate = new Date(model.year, model.month, model.day)
                                root.dateSelected(root.selectedDate)
                            }
                        }
                    }
                }
            }

            // Action buttons
            Row {
                width: parent.width
                height: 40
                layoutDirection: Qt.RightToLeft
                spacing: 8
                rightPadding: 8

                Button {
                    text: "OK"
                    flat: true
                    Material.foreground: root.accentColor
                    onClicked: {
                        root.opened = false
                    }
                }

                Button {
                    text: "CANCEL"
                    flat: true
                    onClicked: root.opened = false
                }
            }
        }
    }
}
