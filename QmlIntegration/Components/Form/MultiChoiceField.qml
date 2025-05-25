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
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../../Controls"
import "../../Components/"
import "../../Components/Menu/"

T.TextField {
    id: control

    // ========================================================================
    // PROPERTIES
    // ========================================================================

    // Appearance Properties
    property bool animated: true
    property bool textFieldBackgroundVisible: true
    property color baseOutlineColor: Material.hintTextColor
    property color outlineColor: control.hasError ? control.Material.accent :
                                                    (control.enabled && control.hovered) ? control.Material.primaryTextColor :
                                                                                           control.baseOutlineColor
    property real scaleFactor: 1
    property string closeIconSource: ""
    property Component bottomSourceComponent: null
    property bool bottomSourceComponentActive: bottomSourceComponent
    property alias indicator: indicatorLoader.sourceComponent

    // Data Model Properties
    property int roleIndex: -1
    property string textRole: "text"
    property int uidRoleIndex: roleIndex
    property string uidTextRole: textRole
    property var initialSelection: []
    property bool hasChanged: false
    property int selectedCount: 0
    property bool busy: false
    property var _cachedSelectedItems: null

    // Selection Properties
    property alias delegate: control.delegateModel.delegate
    property ButtonGroup selectionCheckboxGroup: ButtonGroup {
        exclusive: false
    }

    // ========================================================================
    // MODELS
    // ========================================================================
    property var model: null
    property ListModel enhancedModel: ListModel {
    }
    property ListModel selectedModel: ListModel { id: selectedListModel }

    property DelegateModel delegateModel: DelegateModel{
        model: control.enhancedModel
        groups: [
            DelegateModelGroup {
                name: "selected"
                includeByDefault: false
            }
        ]
        delegate: CustomBaseMaterialMenuItem {
            id: delegateCustomBaseMaterialMenuItem
            required property var model
            required property int index
            property bool mSelected:  model.selected

            width: ListView.view ? ListView.view.width : 0
            text: model.originalData
            hoverEnabled: control.hoverEnabled
            focusPolicy: Qt.NoFocus
            checkable: true
            ButtonGroup.group: control.selectionCheckboxGroup

            // indicator: CheckIndicator {
            //     control: delegateCustomBaseMaterialMenuItem
            //     x: delegateCustomBaseMaterialMenuItem.text ? (delegateCustomBaseMaterialMenuItem.mirrored
            //                                                   ? delegateCustomBaseMaterialMenuItem.width - width - delegateCustomBaseMaterialMenuItem.rightPadding : delegateCustomBaseMaterialMenuItem.leftPadding)
            //                                                : delegateCustomBaseMaterialMenuItem.leftPadding + (delegateCustomBaseMaterialMenuItem.availableWidth - width) / 2
            //     y: delegateCustomBaseMaterialMenuItem.topPadding + (delegateCustomBaseMaterialMenuItem.availableHeight - height) / 2
            //     visible: delegateCustomBaseMaterialMenuItem.checkable
            //     checkState: control.mSelected ? Qt.Checked : Qt.Unchecked
            // }

            onMSelectedChanged: {
                if (checked !== mSelected) {
                    checked = mSelected;
                    checkedChanged()
                }
            }

            onCheckedChanged: {
                if (checked !== mSelected) {
                    let item_ = model;
                    control.updateSelection(item_, checked)
                }
            }
        }
    }

    property DelegateModel selectedItemsDelegateModel: DelegateModel{
        groups: [
            DelegateModelGroup {
                id: selectedDelegateModelGroup
                name: "selected"
                includeByDefault: true
            }
        ]
        filterOnGroup: "selected"
        model: control.enhancedModel

        delegate: Item{
            width: materialTagDelegate.width
            height: control.height

            MaterialTagDelegate{
                id: materialTagDelegate
                anchors.verticalCenter: parent.verticalCenter
                text: model.originalData
                maximunLabelWidth: 100
                backgroundColor: Material.hintTextColor
                iconSource: control.closeIconSource
                property bool mSelected: model.selected
                scale: mSelected
                layer.enabled: true
                state: mSelected ? "visible" : "hidden"

                states: [
                    State {
                        name: "hidden"
                        PropertyChanges {
                            target: materialTagDelegate
                            scale: 0
                            opacity: 0
                        }
                    },
                    State {
                        name: "visible"
                        PropertyChanges {
                            target: materialTagDelegate
                            scale: 1
                            opacity: 1
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "visible"
                        to: "hidden"
                        ParallelAnimation{
                            NumberAnimation { properties: "scale"; duration: control.animated ? 100 : 0; easing.type: Easing.InOutQuad }
                            OpacityAnimator { duration: control.animated ? 100 : 0; easing.type: Easing.InOutQuad }
                        }
                    },
                    Transition {
                        from: "hidden"
                        to: "visible"
                        ParallelAnimation{
                            NumberAnimation { properties: "scale"; duration: control.animated ? 300 : 0; easing.type: Easing.InOutQuad }
                            OpacityAnimator { duration: control.animated ? 350 : 0; easing.type: Easing.InOutQuad }
                        }
                    }
                ]


                onMSelectedChanged: {
                    DelegateModel.inSelected = mSelected
                }

                onRigthButtonClicked: {
                    control.updateSelection(model, false)
                }

                Component.onCompleted: {
                    DelegateModel.inSelected = mSelected
                    DelegateModel.inPersistedItems = true
                }
            }
        }

        Component.onCompleted: {
            control.selectedCount = Qt.binding(function(){return selectedDelegateModelGroup.count})
        }
    }

    // ========================================================================
    // POPUP CONFIGURATION
    // ========================================================================

    property T.Popup popup:  T.Popup {
        id: mPopup
        y: parent.height
        width: control.width
        height: Math.min(contentItem.implicitHeight + verticalPadding * 2, control.Window.height - topMargin - bottomMargin)
        transformOrigin: Item.Top
        topMargin: 12
        bottomMargin: 12
        verticalPadding: 8
        padding: 0
        closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

        Material.theme: control.Material.theme
        Material.accent: control.Material.accent
        Material.primary: control.Material.primary
        Material.roundedScale: control.Material.roundedScale

        contentItem: ColumnLayout{
            width: parent.width
            ListView {
                id: popupListview
                property real headerHeight: 0
                property real footerHeight: 0
                clip: true
                implicitHeight: Math.min(contentHeight, 200)
                height: implicitHeight
                Layout.preferredWidth: width
                width: parent.width
                model: control.delegateModel
                boundsBehavior: Flickable.StopAtBounds
                headerPositioning: ListView.OverlayHeader
                footerPositioning:ListView.OverlayFooter

                ScrollBar.vertical: CustomScrollBar {
                    topPadding:  popupListview.headerHeight
                    topInset: popupListview.headerHeight
                    bottomPadding:  popupListview.footerHeight
                    bottomInset: popupListview.footerHeight
                    policy: ScrollBar.AlwaysOn
                }
            }

            Loader{
                id: bottomLoader
                Layout.leftMargin: mPopup.topPadding
                Layout.preferredWidth: width
                active: control.bottomSourceComponentActive
                Layout.preferredHeight: height
                width: parent.width - mPopup.topPadding * 2
                sourceComponent: control.bottomSourceComponent
            }
        }

        enter: Transition {
            // grow_fade_in
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: control.animated ? 320 : 0 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: control.animated ? 250 : 0 }
        }

        exit: Transition {
            // shrink_fade_out
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: control.animated ? 320 : 0 }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: control.animated ? 250 : 0 }
        }

        background: Rectangle {
            radius: popup.Material.roundedScale
            color: parent.Material.dialogColor


            layer.enabled: control.enabled
            layer.effect: RoundedElevationEffect {
                elevation: 4
                roundedScale: background.Material.roundedScale
            }
        }
    }

    // ========================================================================
    // SIGNALS
    // ========================================================================

    signal itemChecked(var item, bool checked)
    signal clearAllRequested()
    signal hasChanged(bool isEqualToInitial)

    // ========================================================================
    // CONFIGURATION
    // ========================================================================


    readOnly: true
    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)
    topInset: clip ? placeholder.largestHeight / 2 : 0
    leftPadding: Material.textFieldHorizontalPadding
    rightPadding: rightComponent.width
    topPadding: Material.containerStyle === Material.Filled
                ? placeholderText.length > 0 && (activeFocus || length > 0)
                  ? Material.textFieldVerticalPadding + placeholder.largestHeight
                  : Material.textFieldVerticalPadding
    : Material.textFieldVerticalPadding + topInset
    bottomPadding: Material.textFieldVerticalPadding

    color: enabled ? Material.foreground : Material.hintTextColor
    selectionColor: Material.accentColor
    selectedTextColor: Material.primaryHighlightedTextColor
    placeholderTextColor: enabled && activeFocus ? Material.accentColor : Material.hintTextColor
    verticalAlignment: TextInput.AlignVCenter

    Material.containerStyle: Material.Outlined
    Material.roundedScale: Material.SmallScale

    // ========================================================================
    // VISUAL COMPONENTS
    // ========================================================================

    background: MaterialTextContainer {
        implicitWidth: 200
        implicitHeight: control.Material.textFieldHeight
        layer.enabled: false

        filled: control.Material.containerStyle === Material.Filled
        fillColor: control.Material.textFieldFilledContainerColor
        outlineColor: control.outlineColor
        focusedOutlineColor: control.Material.accent
        placeholderTextWidth: Math.min(placeholder.width, placeholder.implicitWidth) * placeholder.scale
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.length > 0 || selectedItemsListView.count > 0
        placeholderHasText: placeholder.text.length > 0
        horizontalPadding: control.Material.textFieldHorizontalPadding
    }

    FloatingPlaceholderText {
        id: placeholder
        x: control.leftPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        elide: Text.ElideRight
        renderType: control.renderType

        filled: control.Material.containerStyle === Material.Filled
        verticalPadding: control.Material.textFieldVerticalPadding
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.length > 0 || selectedItemsListView.count > 0
        controlImplicitBackgroundHeight: control.implicitBackgroundHeight
        controlHeight: control.height
    }

    Item {
        id: rightComponent
        height: parent.height
        width: rightComponentLayout.implicitWidth
        anchors.right: parent.right
        state: selectedCount > 0 ? "visible" : "hidden"

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: counterItem
                    scale: 0
                    opacity: 0
                }
                PropertyChanges {
                    target: rightComponentSeparator
                    animatorQ: 0
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: counterItem
                    scale: 1
                    opacity: 1
                }
                PropertyChanges {
                    target: rightComponentSeparator
                    animatorQ: 1
                }
            }
        ]

        transitions: [
            Transition {
                from: "visible"
                to: "hidden"
                ParallelAnimation {
                    NumberAnimation { target:counterItem; properties: "scale"; duration: control.animated ? 300 : 0; easing.type: Easing.InBack }
                    OpacityAnimator { target:counterItem;duration: control.animated ? 250 : 0; easing.type: Easing.InBack }
                    NumberAnimation{target: rightComponentSeparator; duration: control.animated ? 300 : 0 }
                }
            },
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation { target:counterItem; properties: "scale"; duration: control.animated ? 300 : 0; easing.type: Easing.OutBack }
                    OpacityAnimator { target:counterItem; duration: control.animated ? 350 : 0; easing.type: Easing.OutBack }
                    NumberAnimation{target: rightComponentSeparator; duration: control.animated ? 300 : 0 }
                }
            }
        ]

        RowLayout{
            id: rightComponentLayout
            height: parent.height
            spacing: 0

            Item{
                id: rightComponentSeparator
                property int animatorQ: 1
                height: implicitHeight
                implicitHeight: parent.height * animatorQ
                implicitWidth: background.width + 3
                property Item background: Rectangle{
                    parent: rightComponentSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    width: control.activeFocus ? 2 : 1
                    radius: control.Material.roundedScale
                    color: control.activeFocus ? control.Material.accent : control.outlineColor
                    Behavior on height {
                        NumberAnimation{}
                    }
                }
            }

            Item {
                id: counterItem
                width: implicitWidth
                height: implicitHeight
                implicitWidth: counterTag.width
                implicitHeight: counterTag.height
                Layout.rightMargin: -10 * control.scaleFactor


                MaterialTag{
                    id: counterTag
                    anchors.verticalCenter: parent.verticalCenter
                    verticalPadding: 3 * control.scaleFactor
                    padding: 5 * control.scaleFactor
                    backgroundColor: enabled ? control.Material.accent : control.Material.hintTextColor
                    maximunLabelWidth: 30
                    text: control.selectedCount < 100 ? control.selectedCount : "99+"
                }
            }

            Loader {
                id: indicatorLoader
                Layout.alignment: Qt.AlignVCenter
                Layout.fillHeight: true
                sourceComponent: ColorImage {
                    color: control.enabled ? control.Material.foreground : control.Material.hintTextColor
                    source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"
                }
            }
        }
    }

    ListView {
        id: selectedItemsListView
        height: parent.height
        anchors {
            left: parent.left
            leftMargin: control.leftPadding
            right: rightComponent.left
            // rightMargin: 3
        }

        footer: Item {
            width: 5 * control.scaleFactor
        }

        interactive: contentWidth > width
        clip: true
        model: selectedItemsDelegateModel
        spacing: 5
        orientation: ListView.Horizontal

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    // ========================================================================
    // EVENT HANDLERS
    // ========================================================================

    onActiveFocusChanged: if (activeFocus) openPopup()
    onPressed: if (activeFocus) openPopup()

    HoverHandler {
        cursorShape: Qt.ArrowCursor
    }

    // ========================================================================
    // FUNCTIONS
    // ========================================================================

    function resetSelection() {
        initialize()
    }

    function openPopup() {
        if(control.popup) {
            control.popup.open()
        }
    }

    function initialize() {
        if (!enhancedModel) {
            enhancedModel = new ListModel();
        }

        enhancedModel.clear();

        if (!control.model) {
            console.error("Original model is null or undefined.");
            return;
        }

        // Convert initialSelection array to Set for faster lookups
        const initialSelectionSet = new Set(initialSelection);
        const modelCount = control.getModelCount();
        const textRole = control.textRole;
        const roleIndex = control.roleIndex;

        // Pre-allocate array for batch insertion
        const itemsToAdd = [];

        for (let i = 0; i < modelCount; i++) {
            const originalDataText = getDataFromModel(control.model, i, textRole, roleIndex);
            const uidDataText = getDataFromModel(control.model, i, control.uidTextRole, control.uidRoleIndex);

            itemsToAdd.push({
                selected: initialSelectionSet.has(originalDataText), // Direct string comparison
                originalData: originalDataText,
                uidDataText: uidDataText
            });
        }

        // Batch append for better performance
        enhancedModel.append(itemsToAdd);
        control.hasChanged = false;
    }

    function getDataFromModel(model, index, role, roleIndex = -1) {
        let returnData = null;
        if (model instanceof ListModel) {
            returnData = model.get(index)[role];
        }
        else {
            returnData = model.data(model.index(index, 0), roleIndex);
        }
        return returnData;
    }

    function updateEnhancedModel() {
        if (!enhancedModel || enhancedModel.count === 0) {
            initialize();
            return;
        }

        // Create a map of originalData to enhanced model items
        const enhancedItemsMap = {};
        for (let i = 0; i < enhancedModel.count; i++) {
            const item = enhancedModel.get(i);
            enhancedItemsMap[item.originalData] = item; // Using originalData as key
        }

        // Track which items still exist
        const existingItems = new Set();
        const modelCount = control.getModelCount();

        for (let i = 0; i < modelCount; i++) {
            const originalData = getDataFromModel(control.model, i, control.textRole, control.roleIndex);
            existingItems.add(originalData);

            if (!enhancedItemsMap[originalData]) {
                // New item - add to enhanced model
                const uidDataText = getDataFromModel(control.model, i, control.uidTextRole, control.uidRoleIndex);
                enhancedModel.append({
                    selected: initialSelection.includes(originalData), // Direct array includes check
                    originalData: originalData,
                    uidDataText: uidDataText
                });
            }
        }

        // Remove items that no longer exist
        for (let i = enhancedModel.count - 1; i >= 0; i--) {
            const item = enhancedModel.get(i);
            if (!existingItems.has(item.originalData)) {
                enhancedModel.remove(i);
            }
        }

        detectChange();
    }

    function invalidateSelectionCache() {
        control._cachedSelectedItems = null;
    }

    function getSelectedItems() {
        if (_cachedSelectedItems !== null) {
            return _cachedSelectedItems;
        }

        const selected = [];
        for (let i = 0; i < enhancedModel.count; i++) {
            const item = enhancedModel.get(i);
            if (item.selected) {
                selected.push(item.originalData); // Just store the text
            }
        }
        _cachedSelectedItems = selected;
        return selected;
    }

    function getSelectedItemsByUidRole() {
        let selected = []
        for (let i = 0; i < enhancedModel.count; i++) {
            let item = enhancedModel.get(i)
            if (item.selected) {
                selected.push(item.uidDataText)
            }
        }
        return selected
    }

    function addItemFromJsonToEnhancedModel(jsonItem) {
        // Determine if the item is part of initial selection
        const isSelected = initialSelection.includes(jsonItem.originalData); // Check against original data

        // Append the item to enhancedListModel
        enhancedListModel.append({
                                     selected: isSelected, // Set selected property based on initial selection
                                     originalData: jsonItem.originalData, // Store reference to the original data
                                     uidDataText: jsonItem.uidDataText // Store uid data text if needed
                                 });
    }

    function compareOriginalData(originalData1, originalData2) {
        return originalData1 === originalData2; // Adjust based on your data structure
    }

    function updateSelectionState() {
        let currentSelection = getSelectedItems(); // Get currently selected items
        selectionChanged = (currentSelection.length !== initialSelection.length) ||
                !currentSelection.every(item => initialSelection.includes(item));

        // Emit a signal if the selection has changed
        if (selectionChanged) {
            hasChanged(true);
        } else {
            hasChanged(false);
        }
    }

    function updateSelection(item, checked) {
        if (item.selected !== checked) {
            item.selected = checked;
            invalidateSelectionCache();
            detectChange();
        }
    }

    function detectChange() {
        if (selectedCount !== initialSelection.length) {
            control.hasChanged = true;
            return;
        }

        const currentSelected = getSelectedItems();

        if (currentSelected.length !== initialSelection.length) {
            control.hasChanged = true;
            return;
        }

        const currentSet = new Set(currentSelected);
        control.hasChanged = !initialSelection.every(item => currentSet.has(item));
    }

    function compareSelectionToInitial() {
        let selectedItems = [];

        // Collect currently selected items
        for (let i = 0; i < selectedItemsDelegateModel.items.count; i++) {
            selectedItems.push(selectedItemsDelegateModel.items.get(i).model.originalData);
        }

        // Compare to initial selection
        if (selectedItems.length !== initialSelection.length) {
            control.selectionChanged(false);
        } else {
            for (let item of initialSelection) {
                if (!selectedItems.includes(item)) {
                    control.selectionChanged(false);
                    return;
                }
            }
            control.selectionChanged(true);
        }
    }

    function reset(){
        initialize()
    }

    function getModelCount() {
        if (!model) return 0

        // For QML ListModel
        if (typeof model.count !== "undefined") {
            return model.count
        }

        // For C++ models (QAbstractItemModel)
        else if (typeof model.rowCount !== "undefined") {
            return model.rowCount()
        }

        return 0
    }

    // ========================================================================
    // CONNECTIONS
    // ========================================================================

    Connections {
        id: modelConnections
        target: control.model
        ignoreUnknownSignals: true

        // For QML ListModel
        function onCountChanged() {
            control.updateEnhancedModel()
        }

        // For C++ models (QAbstractItemModel signals)
        function onRowsInserted() { control.updateEnhancedModel() }
        function onRowsRemoved() { control.updateEnhancedModel() }
        function onModelReset() { control.updateEnhancedModel() }
    }

    // ========================================================================
    // COMPONENT LIFECYCLE
    // ========================================================================

    Component.onCompleted: {
        Qt.callLater(initialize)
    }
}
