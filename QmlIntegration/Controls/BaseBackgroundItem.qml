import QtQuick 2.15

Rectangle {
    id: root
    property alias contentMArea : mArea
    property color backgroundColor : "transparent"
    color: root.backgroundColor
    signal backgroundClicked

    MouseArea {
        id:mArea
        anchors.fill: parent
        onClicked: {
            parent.forceActiveFocus()
            backgroundClicked()
        }
    }
}
