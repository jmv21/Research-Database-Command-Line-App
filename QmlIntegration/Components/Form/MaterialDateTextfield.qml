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

import "../../Controls"
import "../../Components/"

CustomMaterialTextfield{
    id: control
    property bool isEditing: false
    property int lastCursorPosition: 0

    baseTextfield.inputMask: "99/99/9999;-"
    placeholderText: "dd/MM/yyyy"

    baseTextfield.onPressed: {
        control.isEditing = true
        control.lastCursorPosition = control.baseTextfield.cursorPosition
    }

    baseTextfield.onActiveFocusChanged: {
        if (!baseTextfield.activeFocus) {
            control.isEditing = false
            control.enforceValidDate()
        }
    }

    baseTextfield.onTextChanged: {
        if (!isEditing || text.includes("-")) return;

        const currentPos = control.baseTextfield.cursorPosition;
        const result = processDate(text, true); // true for partial validation

        if (result.formatted !== text) {
            const oldLength = text.length;
            text = result.formatted;
            // Adjust cursor position only if length changed
            control.baseTextfield.cursorPosition = oldLength === result.formatted.length
                    ? currentPos
                    : Math.max(0, Math.min(result.formatted.length, currentPos + (result.formatted.length - oldLength)));
        }
    }

    function enforceValidDate() {
        const currentPos = control.baseTextfield.cursorPosition;
        const result = processDate(baseTextfield.text, false); // false for complete validation
        if (result.formatted !== baseTextfield.text) {
            text = result.formatted || "01/01/2000"; // Default date if invalid
            control.baseTextfield.cursorPosition = currentPos;
        }
    }

    function processDate(inputText, isPartial) {
        if (!inputText || inputText.length < 10) return { formatted: isPartial ? inputText : "", valid: false };

        const parts = inputText.split('/');
        if (parts.length !== 3) return { formatted: isPartial ? inputText : "", valid: false };

        let day = parseInt(parts[0], 10) || 1;
        let month = parseInt(parts[1], 10) || 1;
        const year = parseInt(parts[2], 10) || 2000;

        // Boundary checks
        month = Math.max(1, Math.min(12, month));
        const maxDays = new Date(year, month, 0).getDate();
        day = Math.max(1, Math.min(maxDays, day));

        // For complete validation, check if the date was actually changed
        if (!isPartial && (day !== parseInt(parts[0], 10) || month !== parseInt(parts[1], 10))) {
            return { formatted: "", valid: false };
        }

        return {
            formatted: `${day.toString().padStart(2, '0')}/${month.toString().padStart(2, '0')}/${year.toString().padStart(4, '0')}`,
            valid: day === parseInt(parts[0], 10) && month === parseInt(parts[1], 10)
        };
    }
}
