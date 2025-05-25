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
import QtQuick.Controls.impl
import QtQuick.Templates as T

import "../../Controls"
import "../../Components/"
import "../../Components/Models"

T.Tumbler {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)


    delegate: MaterialTumblerDelegate {
        current: index === control.currentIndex
        displacement: Tumbler.displacement
        internalLabel.text: modelData
        internalLabel.textColor: control.Material.foreground
        internalLabel.font: control.font

        required property int index
        required property var modelData
    }

    contentItem: TumblerView {
        implicitWidth: 60
        implicitHeight: 200
        model: control.model
        delegate: control.delegate
        path: Path {
            startX: control.contentItem.width / 2
            startY: -control.contentItem.delegateHeight / 2
            PathLine {
                x: control.contentItem.width / 2
                y: (control.visibleItemCount + 1) * control.contentItem.delegateHeight - control.contentItem.delegateHeight / 2
            }
        }

        property real delegateHeight: control.availableHeight / control.visibleItemCount
    }

    // WheelHandler {
    //     target: null
    //     onWheel: (event) => {
    //         if (event.angleDelta.y > 0) {
    //             control.currentIndex +=1;
    //         } else {
    //             control.currentIndex -=1;
    //         }
    //         event.accepted = true;
    //     }
    // }
}
