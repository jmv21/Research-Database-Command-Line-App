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
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../../Controls"
import "../../Components/"
import "../../js/utils.js" as Utils

T.TreeViewDelegate {
    id: control

    required property int row
    required property var model
    readonly property real __contentIndent: !isTreeNode ? 0 : (depth * indentation) + (indicator ? indicator.width + spacing : 0)

    property string indicatorIconSource:"qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/arrow-indicator.png"
    property alias rightComponentLoader: rightComponentLoader
    property color backgroundColor: Material.background
    property color textColor: backgroundColor.toString() !== "#00000000" ? Utils.getTextColor(backgroundColor) : Material.foreground
    property Component rightItemComponent: null

    property bool statusBannerVisible: true
    property color statusBannerColor: "transparent"

    Material.roundedScale: Material.SmallScale

    implicitWidth: leftMargin + __contentIndent + implicitContentWidth + rightPadding + rightMargin
    implicitHeight: Math.max(implicitBackgroundHeight, implicitContentHeight, implicitIndicatorHeight)

    indentation: indicator ? indicator.width : 12
    leftMargin: 3
    rightMargin: leftMargin + 4
    spacing: 0

    topPadding: contentItem ? (height - contentItem.implicitHeight) / 2 : 0
    leftPadding: !mirrored ? leftMargin + __contentIndent : width - leftMargin - __contentIndent - implicitContentWidth

    highlighted: control.selected || control.current
                 || ((control.treeView.selectionBehavior === TableView.SelectRows
                      || control.treeView.selectionBehavior === TableView.SelectionDisabled)
                     && control.row === control.treeView.currentRow)


    signal expandStateToggled()

    icon.color: control.enabled ? control.textColor : control.Material.hintTextColor

    indicator: Item {
        readonly property real __indicatorIndent: control.leftMargin + (control.depth * control.indentation)
        x: !control.mirrored ? __indicatorIndent : control.width - __indicatorIndent - width
        y: (control.height - height) / 2
        implicitWidth: Math.max(arrow.width, 20)
        implicitHeight: control.Material.buttonHeight

        property CustomMaterialToolButton arrow : CustomMaterialToolButton {
            parent: control.indicator
            anchors.centerIn: parent
            rotation:  control.expanded ? 360 : (control.mirrored ? 180 : 270)
            icon.source: control.indicatorIconSource
            icon.color: control.enabled ? control.textColor : control.Material.hintTextColor

            onClicked: {
                control.expandStateToggled()
            }
        }
    }

    background: Pane {
        x: indicator.x - control.leftMargin
        width: control.width - x
        implicitHeight: control.Material.buttonHeight
        Material.background: control.backgroundColor
        Material.roundedScale: control.Material.roundedScale
        Material.elevation: control.Material.elevation
    }

    Rectangle{
        id: statusBanner
        x: indicator.x - control.leftMargin
        visible: control.statusBannerVisible
        color: control.statusBannerColor
        height: parent.height
        width: 6
        topLeftRadius: control.Material.roundedScale
        bottomLeftRadius: control.Material.roundedScale
    }

    contentItem: Item{
        id: contentLayout
        property int spacing: 3
        implicitWidth: contentContainer.implicitWidth
        implicitHeight: contentContainer.implicitHeight
        visible: !control.editing

        Item{
            id: contentContainer
            y: -control.topPadding
            width: parent.width
            height: control.height
            implicitWidth: iconLabel.implicitWidth + textLabel.implicitWidth + spacing + rightComponentLoader.width
            implicitHeight: Math.max(iconLabel.implicitHeight, textLabel.implicitHeight)

            IconLabel{
                id: iconLabel
                anchors{
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                icon: control.icon
                mirrored: control.mirrored
                display: control.display
                alignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
                font: control.font
            }

            CustomLabel{
                id: textLabel
                anchors{
                    left: iconLabel.right
                    leftMargin: contentLayout.spacing
                    verticalCenter: parent.verticalCenter
                }
                text: control.text
                font: control.font
                color: control.enabled ? control.textColor : control.Material.hintTextColor
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }
        }
    }

    Loader{
        id: rightComponentLoader
        anchors{
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        sourceComponent: control.rightItemComponent
    }


    /*Item{
        implicitHeight: contentLayout.implicitHeight
        implicitWidth: contentLayout.implicitWidth
        width: implicitWidth
        height: implicitHeight
        RowLayout{
            id: contentLayout
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
            spacing: control.spacing

            IconLabel{
                icon: control.icon
                mirrored: control.mirrored
                display: control.display
                alignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            CustomLabel{
                text: control.text
                font: control.font
                color: control.enabled ? control.textColor : control.Material.hintTextColor
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }
        }
    }*/

    // The edit delegate is a separate component, and doesn't need
    // to follow the same strict rules that are applied to a control.
    // qmllint disable attached-property-reuse
    // qmllint disable controls-attached-property-reuse
    // qmllint disable controls-sanity
    TableView.editDelegate: FocusScope {
        width: parent.width
        height: parent.height

        readonly property int __role: {
            let model = control.treeView.model
            let index = control.treeView.index(row, column)
            let editText = model.data(index, Qt.EditRole)
            return editText !== undefined ? Qt.EditRole : Qt.DisplayRole
        }

        TextField {
            id: textField
            x: control.contentItem.x
            y: (parent.height - height) / 2
            width: control.contentItem.width
            text: control.treeView.model.data(control.treeView.index(row, column), __role)
            focus: true
        }

        TableView.onCommit: {
            let index = TableView.view.index(row, column)
            TableView.view.model.setData(index, textField.text, __role)
        }

        Component.onCompleted: textField.selectAll()
    }
    // qmllint enable attached-property-reuse
    // qmllint enable controls-attached-property-reuse
    // qmllint enable controls-sanity
}


