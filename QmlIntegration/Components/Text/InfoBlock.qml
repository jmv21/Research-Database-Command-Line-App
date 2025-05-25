import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../../Controls"

Item {
    id: control
    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    property color referenceBackgroundColor: Material.background

    property alias titleLabel: titleLabel
    property string title: ""
    property alias titleColor: titleLabel.color
    property int titlePixelSize: 16
    property int titleWeight: 400

    property alias descriptionLoader: descriptionLoader
    property string description: ""
    property color descriptionColor: Material.hintTextColor
    property int descriptionPixelSize: 16
    property int descriptionWeight: 400
    property int descriptionMaximunLines: 2

    property Component descriptionComponent: Component {
        CustomLabel {
            id: descriptionLabel
            maximumLineCount: control.descriptionMaximunLines
            width: parent.width
            text: control.description
            color: control.descriptionColor ? control.descriptionColor : textColor
            backgroundColor: control.referenceBackgroundColor
            font.pixelSize: control.descriptionPixelSize
            font.weight: control.descriptionWeight
        }
    }

    ColumnLayout{
        id: contentLayout
        anchors.fill: parent

        CustomLabel {
            id: titleLabel
            Layout.fillWidth: true
            text: control.title
            maximumLineCount: 1
            backgroundColor: control.referenceBackgroundColor
            visible: control.title
            font.pixelSize: control.titlePixelSize
            font.weight: control.titleWeight
        }

        Loader {
            id: descriptionLoader
            active: control.description
            Layout.fillWidth: true
            sourceComponent: control.descriptionComponent
        }
    }
}
