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

Item {
    id: control
    property var model: null
    property alias horizontalHeaderViewItem: horizontalHeader
    property alias verticalHeaderViewItem: verticalHeader
    property alias tableViewItem: tableView
    property alias backgroundLoaderItem: backgroundLoader
    property int headerTableSpacing: 0
    property Component background: null
    implicitHeight: horizontalHeader.implicitHeight + tableView.implicitHeight
    implicitWidth: gridlayout.implicitWidth

    Loader {
        id: backgroundLoader
        // anchors.fill: gridlayout
        height: horizontalHeader.height + tableView.contentHeight + gridlayout.rowSpacing * 2
        width: Math.min(tableView.contentWidth, tableView.width) + verticalHeader.width + gridlayout.columnSpacing * 2
        sourceComponent: control.background
    }

    GridLayout {
        id: gridlayout
        anchors.fill: parent
        columns: 2
        rows: 2
        columnSpacing: 3
        rowSpacing: control.headerTableSpacing

        HorizontalHeaderView {
            id: horizontalHeader
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            syncView: tableView
            interactive: false
            clip: true
        }

        VerticalHeaderView{
            id: verticalHeader
            Layout.row: 1
            Layout.column: 0
            Layout.fillHeight: true
            implicitWidth: 50
            syncView: tableView
            interactive: false
            clip: true
        }

        CustomBaseMaterialTableView {
            id: tableView
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: tableViewItem.columns * 53 ?? 0
            implicitHeight: tableViewItem.contentHeight
            property bool highlightHoveredRows: false
            model: control.model
            clip: true
        }
    }
}
