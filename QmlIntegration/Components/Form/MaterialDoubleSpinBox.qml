import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "../../Controls"
import "../../Components/"

CustomMaterialDoubleSpinBox {
    id: root
    property alias placeholderText: floatingLabel.text

    CustomLabel {
        id: floatingLabel
        x: 10
        y: -height / 2
        z: 5
        color: root.contentItemHasActiveFocus ? Material.accent : Material.hintTextColor
        backgroundColor: Material.backgroundColor

        background: Rectangle {
            x: -3
            color: Material.backgroundColor
            width: floatingLabel.implicitWidth + 6
        }

        font.pixelSize: 12
        text: ""
    }
}
