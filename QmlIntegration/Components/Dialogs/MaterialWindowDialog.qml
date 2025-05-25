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

import "../../Controls"
import "../../Components/"

ApplicationWindow {
    id: control
    title: "Some Dialog"
    modality: (Qt.platform.os === "osx") ? Qt.NonModal : Qt.WindowModal
    flags: (Qt.platform.os === "osx") ? Qt.Window | Qt.WindowStaysOnTopHint : Qt.Window | Qt.Dialog
    minimumWidth: Math.max((header ? header.implicitWidth : 0), footer.implicitWidth)
    minimumHeight: (footer ? footer.height : 0) + (header ? header.height : 0)

    property int standardButtons: 0
    property color backgroundColor: Material.background
    property color dividerColor: control.Material.dividerColor
    property string headerText: ""
    property alias headerTitle: headerTitle

    header: CustomLabel{
        id: headerTitle
        backgroundColor: control.color
        text: headerText
    }

    signal accepted()
    signal applied()
    signal discarded()
    signal helpRequested()
    signal clicked(AbstractButton button)//not yet connected
    signal rejected()
    signal reset()

    footer: CustomMaterialDialogButtonBox {
        standardButtons: control.standardButtons
        visible: count > 0
        Material.roundedScale: control.Material.roundedScale
        onAccepted: control.accepted()
        onRejected: control.rejected()
        onHelpRequested: control.helpRequested()
        onApplied: control.applied()
        onDiscarded: control.discarded()
        onReset: control.reset()
    }
}
