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
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

Item {
    // id: control
    // property int value: 0
    // property real stepSize: 1.0
    // property alias slider: slider
    // property bool horizontal: true
    // property real horizontalInset: 0
    // property bool vertical: !horizontal
    // property alias spinBox: spinBox
    // property bool spinBoxVisible: true
    // property int spinBoxEdge: Qt.LeftEdge
    // property real spinBoxMargin: 0
    // property real spinBoxSliderMargin: spinBoxVisible ? 10 : 0
    // property bool editable: true

    // width: horizontal ? 200 : 48
    // height: horizontal ? 48 : 200

    // CustomSlider {
    //     id: slider
    //     value: control.value
    //     onValueChanged: control.value = value
    //     width: control.horizontal ? (parent.width - (spinBoxVisible ? spinBox.width + control.horizontalInset + (control.spinBoxEdge === Qt.RightEdge ? spinBoxSliderMargin : 0) : 0)) : parent.width
    //     height: control.vertical ? (parent.height - (spinBoxVisible ? spinBox.height : 0)) : parent.height

    //     x: control.horizontal ? (spinBoxVisible && spinBoxEdge === Qt.LeftEdge ? spinBox.width + spinBoxSliderMargin : control.horizontalInset) + spinBoxMargin : (parent.width - width) / 2
    //     y: control.vertical ? (spinBoxVisible && spinBoxEdge === Qt.TopEdge ? spinBox.height + spinBoxSliderMargin : 0) + spinBoxMargin : (parent.height - height) / 2
    //     stepSize: 1.0
    //     focus: true

    //     Keys.onPressed: (event) => {
    //                         let increment = event.modifiers === Qt.ShiftModifier ? 5 : slider.stepSize;

    //                         if (control.horizontal) {
    //                             if (event.key === Qt.Key_Left) {
    //                                 slider.decreaseValue(increment);
    //                                 event.accepted = true;
    //                             } else if (event.key === Qt.Key_Right) {
    //                                 slider.increaseValue(increment);
    //                                 event.accepted = true;
    //                             }
    //                         } else {
    //                             if (event.key === Qt.Key_Up) {
    //                                 slider.increaseValue(increment);
    //                                 event.accepted = true;
    //                             } else if (event.key === Qt.Key_Down) {
    //                                 slider.decreaseValue(increment);
    //                                 event.accepted = true;
    //                             }
    //                         }
    //                     }

    //     function increaseValue(value = slider.stepSize) {
    //         if (control.value + value <= slider.to) {
    //             control.value += value;
    //         }
    //         else{
    //             control.value = slider.to
    //         }
    //     }

    //     function decreaseValue(value = slider.stepSize) {
    //         if (control.value - value >= slider.from) {
    //             control.value -= value;
    //         }
    //         else{
    //             control.value = slider.from
    //         }
    //     }
    // }


    // CustomMaterialSpinBox {
    //     id: spinBox
    //     visible: control.spinBoxVisible
    //     from: Math.min(slider.from, slider.to)
    //     to: Math.max(slider.from, slider.to)
    //     value: control.value
    //     onValueChanged: control.value = value
    //     editable: control.editable

    //     background.implicitWidth: Math.min(parent.width, parent.height)/2 + font.pixelSize
    //     background.implicitHeight: Math.min(parent.width, parent.height)/2 + font.pixelSize

    //     up.indicator: Item {
    //     }
    //     down.indicator: Item {
    //     }


    //     x: control.horizontal ? (control.spinBoxVisible && control.spinBoxEdge === Qt.RightEdge ? parent.width - width - control.spinBoxSliderMargin : control.spinBoxSliderMargin) : (parent.width - width) / 2
    //     y: control.vertical ? (control.spinBoxVisible && control.spinBoxEdge === Qt.TopEdge ? control.spinBoxSliderMargin : parent.height - height - control.spinBoxSliderMargin) : (parent.height - height) / 2
    // }
}






