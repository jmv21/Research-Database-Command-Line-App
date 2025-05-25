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
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Controls.impl

import "../../Controls"
import "../../Components/"
import "../../Components/Models"

Item {
    id: root
    width: 300
    height: 200

    // Public properties
    property date selectedDate: new Date()
    property int fontSize: 14
    property color textColor: "#ffffff"
    property color backgroundColor: "#181818"
    property int visibleItems: 5
    property int pixeSize: 16

    // Internal properties
    QtObject {
        id: internal

        // Year range calculations
        readonly property int startYear: 1980
        readonly property int endYear: 2035
        readonly property int yearCount: endYear - startYear + 1

        // Date calculation functions
        function daysInMonth(year, month) {
            return new Date(year, month + 1, 0).getDate()
        }

        function yearFromIndex(index) {
            return startYear + index
        }
    }

    // Main layout
    Rectangle {
        id: contentRectangle
        anchors.fill: parent
        radius: 8
        color: root.Material.backgroundColor

        Rectangle {
            y: (contentRectangle.height - height) /2 + (root.pixeSize)
            color: Material.hintTextColor
            height: 2
            implicitWidth: parent.width
        }

        Rectangle {
            y: (contentRectangle.height - height) /2 - (root.pixeSize)
            color: Material.hintTextColor
            height: 2
            implicitWidth: parent.width
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            // Day selector
            MaterialTumbler {
                id: dayTumbler
                wrap: false
                Layout.fillWidth: true
                Layout.fillHeight: true
                visibleItemCount: root.visibleItems
                model: {
                    const year = internal.yearFromIndex(yearTumbler.currentIndex)
                    const month = monthTumbler.currentIndex
                    return internal.daysInMonth(year, month)
                }

                delegate: MaterialTumblerDelegate {
                    required property int index
                    required property var modelData
                    visibleItems: dayTumbler.visibleItemCount
                    current: index === root.currentIndex
                    displacement: Tumbler.displacement
                    internalLabel.text: modelData + 1
                    height: dayTumbler.height / dayTumbler.visibleItemCount
                    width: dayTumbler.width

                    internalLabel.font.pixelSize: root.fontSize
                    internalLabel.backgroundColor: contentRectangle.color
                }

                onCurrentIndexChanged: Qt.callLater(root.updateSelectedDate)
            }

            // Month selector
            MaterialTumbler {
                id: monthTumbler
                wrap: false
                Layout.fillWidth: true
                Layout.fillHeight: true
                visibleItemCount: root.visibleItems
                model: 12

                delegate: MaterialTumblerDelegate {
                    required property int index
                    required property var modelData
                    visibleItems: monthTumbler.visibleItemCount
                    current: index === root.currentIndex
                    displacement: Tumbler.displacement
                    internalLabel.text: Qt.locale().monthName(modelData, Locale.LongFormat)
                    height: monthTumbler.height / monthTumbler.visibleItemCount
                    width: monthTumbler.width

                    internalLabel.font.pixelSize: root.fontSize
                    internalLabel.backgroundColor: contentRectangle.color
                }

                onCurrentIndexChanged: {
                    Qt.callLater(root.updateSelectedDate)
                    Qt.callLater(root.validateDayIndex)
                }
            }

            // Year selector
            MaterialTumbler {
                id: yearTumbler
                wrap: false
                Layout.fillWidth: true
                Layout.fillHeight: true
                visibleItemCount: root.visibleItems
                model: internal.endYear - internal.startYear + 1

                delegate: MaterialTumblerDelegate {
                    required property int index
                    required property var modelData
                    visibleItems: yearTumbler.visibleItemCount
                    current: index === yearTumbler.currentIndex
                    displacement: Tumbler.displacement
                    internalLabel.text: modelData + internal.startYear
                    height: yearTumbler.height / yearTumbler.visibleItemCount
                    width: yearTumbler.width

                    internalLabel.font.pixelSize: root.fontSize
                    internalLabel.backgroundColor: contentRectangle.color
                }

                onCurrentIndexChanged: {
                    Qt.callLater(root.updateSelectedDate)
                    Qt.callLater(root.validateDayIndex)
                }
            }
        }
    }

    // Initialization
    Component.onCompleted: {
        const today = new Date()
        monthTumbler.currentIndex = today.getMonth()
        yearTumbler.currentIndex = today.getFullYear() - internal.startYear
        dayTumbler.currentIndex = today.getDate() - 1
    }

    // Validation when month/year changes
    function validateDayIndex() {
        const maxDays = internal.daysInMonth(
                          internal.yearFromIndex(yearTumbler.currentIndex),
                          monthTumbler.currentIndex
                          )

        if (dayTumbler.currentIndex >= maxDays) {
            dayTumbler.currentIndex = maxDays - 1
        }
    }

    // Date update handler
    function updateSelectedDate() {
        const day = dayTumbler.currentIndex + 1
        const month = monthTumbler.currentIndex
        const year = internal.yearFromIndex(yearTumbler.currentIndex)
        root.selectedDate = new Date(year, month, day)
    }
}
