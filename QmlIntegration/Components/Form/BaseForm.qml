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

Item {
    property bool hasBeenChanged: changedFieldsCounter !== 0
    property var lastErrorsMap: null
    property int changedFieldsCounter: 0
    property int completedFieldsCount: 0
    property int requiredFieldsCount: 0
    property string generalError: ""
    property bool canSubmitForm: hasBeenChanged && requiredFieldsCount === completedFieldsCount
}
