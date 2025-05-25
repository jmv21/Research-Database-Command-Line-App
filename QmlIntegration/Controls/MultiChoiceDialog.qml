import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl


Dialog {
    id: control

    Material.roundedScale: Material.NotRounded

    topPadding: 0
    bottomPadding: 0



    property color bgColor: "black"
    property color textBgColor: "grey"
    property color textColor: "blue"

    property color buttonColor: "grey"
    property color closeButtonMainColor: "grey"
    property color closeButtonSecondaryColor: "red"


    property string titleText: "Title text"
    property string dialogText: "dialog text"
    property string button1Text: "button 1"
    property string button2Text: "button 2"

    property var button1Function: undefined
    property var button2Function: undefined

    property real buttonsHeight: 45


    property alias titleIconSource: iconTitle.source
    property alias titleIconWidth: iconTitle.width
    property alias titleIconHeight: iconTitle.height
    property alias titleIconScale: iconTitle.scale
    property alias titleIconColor: iconTitle.color

    property alias textIconSource: iconText.source
    property alias textIconWidth: iconText.width
    property alias textIconHeight: iconText.height
    property alias textIconScale: iconText.scale
    property alias textIconColor: iconText.color

    property alias enabledCloseButton: closeButtonPane.visible

    anchors.centerIn: parent
    implicitWidth: 400
    implicitHeight: 100

    Pane {
        id: closeButtonPane

        z:1
        anchors{
            top: parent.top
            topMargin: -8
            right: parent.right
            rightMargin: -30
        }


        height: 25
        width: height


        Material.background: bgColor

        Material.elevation: 10

        property int radius: height
        background: Rectangle {
            color: closeButtonPane.Material.backgroundColor
            radius: closeButtonPane.Material.elevation > 0 ? closeButtonPane.radius : 0

            layer.enabled: closeButtonPane.enabled && closeButtonPane.Material.elevation > 0
            layer.effect: ElevationEffect {
                elevation: closeButtonPane.Material.elevation
            }
        }


    }

    CustomToolButton2{

        anchors.fill: closeButtonPane
        z:2

        buttonMainColor: closeButtonMainColor
        buttonSecondaryColor: closeButtonSecondaryColor


        buttonIconSource: "qrc:/IconsSVG/cross.svg"
        iconScale: 0.8
        forceFocusOnClick: false


        onButtonClicked: {

            control.close()
        }


    }


    contentItem: Rectangle {
            color: "transparent"




            IconImage{

                id: iconTitle
                visible: status!== Image.Null
                width: 20
                anchors{
                    left: parent.left

                    verticalCenter:  title.verticalCenter
                }


                mipmap: true
                scale:1
                color: settings.theme.accentColor

            }

            Label{
                id:title
                text: titleText
                Layout.alignment: Qt.AlignLeft

                width: iconTitle.visible? parent.width - iconTitle.width - 15: parent.width -10
                anchors{
                    top: parent.top

                    right: parent.right
                    rightMargin: 10
                    leftMargin: 0
                    topMargin: 50
                }


                font.pointSize: 18
                color: textColor

                wrapMode: Text.WordWrap
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter

                font.bold: false
                minimumPointSize: 8
                textFormat: Text.RichText
                scale: 1
            }


            IconImage{

                id: iconText
                visible: status!== Image.Null
                width: 20
                anchors{

                    left: parent.left

                    verticalCenter:  text.verticalCenter
                }

                mipmap: true
                scale:1
                color: settings.theme.accentColor

            }

            Text {
                id: text

                width: iconText.visible? parent.width - iconText.width - 15: parent.width - 2
                anchors{

                    top: title.bottom
                    right: parent.right
                    rightMargin: 0
                    leftMargin: 0
                    topMargin: 20
                }



                font.pixelSize: 14
                text: dialogText
                textFormat: Text.RichText

                wrapMode: Text.WordWrap
                color: textColor

            }
        }



    background:
    Rectangle{
        id: bgRectangle
        color: bgColor
        radius: 8
        opacity: 0.95

        border.color: textColor
        border.width: 0

        Rectangle{
            color: textBgColor

            anchors{
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 40
                bottom: parent.bottom
                bottomMargin: buttonsHeight + 20

            }
        }

        Material.elevation: 5
    }



    RowLayout{
        id: buttons

        width: parent.width
        height: buttonsHeight + 10
        Layout.alignment: Qt.AlignHCenter
        anchors{

            bottom: parent.bottom
            bottomMargin: 5
        }



        spacing: 10

        Item{
            Layout.fillWidth: true
        }


        CustomButton{
            id: bt1
            text: button1Text

            height: buttonsHeight
            Material.background: buttonColor
            Material.elevation: 10

            onClicked: {
                button1Function()
            }
        }


        CustomButton{
            id: bt2
            text: button2Text

            height: buttonsHeight
            Material.background: buttonColor
            Material.elevation: 10

            onClicked: {
                button2Function()
            }
        }

        Item{
            Layout.fillWidth: true
        }

}

}

