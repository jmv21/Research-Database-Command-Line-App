/* Copyright (C) 2024 The Lucerum LLC
 *
 * This program is proprietary software: you can redistribute
 * it under the terms of the Lucerum LLC under the QT Commercial License as agreed with The Qt Company.
 * For more details, see <https://www.qt.io/licensing/>.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Window
import QtQuick.Layouts
import Qt.labs.qmlmodels

import "../../Controls"
import "../../Components/"

TableView {
    id: control
    property bool hasContextualMenu: false
    property real defaultColumnWidth: maximunColumnWidth
    property real minimunColumnWidth: 100
    property real maximunColumnWidth: Math.max(columns > 0 ? width/columns|0 : 100, minimunColumnWidth) - columnSpacing
    property real maximunTableWidth: maximunColumnWidth * columns
    property bool highlightHoveredRows: false
    property int hoveredRowIndex: -1
    property int selectedRow: -1
    property var columnVisibility: []
    resizableColumns: true
    boundsMovement: Flickable.StopAtBounds
    boundsBehavior: Flickable.StopAtBounds
    columnSpacing: 1
    onWidthChanged: {
        forceLayout()
    }

    columnWidthProvider: function (column) {
        if(control.columns > control.columnVisibility.length){
            initializeColumnVisibility()
        }

        if (control.columnVisibility && !control.columnVisibility[column]) {
            return 0
        }

        let m_explicitColumnWidth = explicitColumnWidth(column)
        if(m_explicitColumnWidth <= -1) {
            if(control.columnWidthsList && column <= control.columnWidthList.length - 1 ) {
                m_explicitColumnWidth = columnWidth[column]
            }
            else{
                m_explicitColumnWidth = control.defaultColumnWidth
            }
        }

        let currentWidth = Math.max(control.minimunColumnWidth, m_explicitColumnWidth)
        let providedWidth = control.maximunColumnWidth > -1 ? Math.min(control.maximunColumnWidth, currentWidth) : currentWidth
        return providedWidth
    }

    rowHeightProvider: function (row) { return 53; }
    alternatingRows: true

    ScrollBar.vertical: CustomScrollBar {
        id: vrtScrllBar
    }

    ScrollBar.horizontal: CustomScrollBar {
        id: horScrllBar
    }


    Component.onCompleted: {
        if(control.columns > control.columnVisibility.length){
            initializeColumnVisibility()
        }
    }

    function setConditionalHoveredRowIndex(row, containsMouse) {
        if(highlightHoveredRows){
            if(containsMouse){
                control.hoveredRowIndex = row
            }
            else if(row === control.hoveredRowIndex){
                control.hoveredRowIndex = -1
            }
        }
    }

    function rowAt(y) {
        let cumulativeHeight = 0;
        // Iterate through each row to calculate the cumulative height
        for (let row = 0; row < control.contentItem.children.length; row++) {
            let rowHeight = control.rowHeightProvider(row);
            cumulativeHeight += rowHeight;
            // Check if the y-coordinate falls within the current row's height
            if (y < cumulativeHeight) {
                return row; // Return the row index if found
            }
        }
        return -1; // Return -1 if the row is not found
    }

    function columnAt(x) {
        let cumulativeWidth = 0;
        // Iterate through each column to calculate the cumulative width
        for (let column = 0; column < control.columns; column++) {
            let columnWidth = control.columnWidthProvider(column);
            cumulativeWidth += columnWidth;
            // Check if the x-coordinate falls within the current column's width
            if (x < cumulativeWidth) {
                return column; // Return the column index if found
            }
        }
        return -1; // Return -1 if the column is not found
    }

    function toggleColumnVisibility(column) {
        if (column >= 0 && column < control.columnVisibility.length) {
            control.columnVisibility[column] = !control.columnVisibility[column];
            control.forceLayout();
        }
    }

    function initializeColumnVisibility() {
        control.columnVisibility = []; // Reset the array
        for (let i = 0; i < control.columns; i++) {
            control.columnVisibility.push(true);
        }
    }
}
