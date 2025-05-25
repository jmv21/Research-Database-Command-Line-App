import QtQuick
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl
import QtQuick.Layouts
import QmlIntegration

import "../Components/Form"
import "../Components/"
import "../AppComponents"
import "../Controls"
import "./"

BaseForm {
    id: root
    requiredFieldsCount: 2
    onLastErrorsMapChanged: {
        if (lastErrorsMap) {
            root.generalError = lastErrorsMap["generalError"] ? lastErrorsMap["generalError"] : ""
            if(generalError)
                generalError =  "Error: " + generalError
            usernameTextfield.errorText = lastErrorsMap["username"] ? lastErrorsMap["username"] : ""
            passwordTextfield.errorText = lastErrorsMap["password"] ? lastErrorsMap["password"] : ""
        }
    }

    signal registerRequested()

    // Connections{
    //     target: mainStore

    //     function onUnsuccessfullLogin(map){
    //         root.lastErrorsMap = map
    //     }
    // }

    implicitHeight: formLayout.implicitHeight
    implicitWidth: formLayout.implicitWidth

    ColumnLayout{
        id: formLayout
        width: parent.width
        anchors.centerIn: parent
        spacing: 10

        CustomLabel{
            backgroundColor: root.Material.background
            text: qsTr("Welcome Back")
            font.weight: Font.Bold
            font.pixelSize: Globals.typography.textHeadline
            Layout.preferredWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        // CustomLabel{
        //     backgroundColor: root.Material.background
        //     text: "Enter your username and password to access the application"
        //     maximumLineCount: 2
        //     elide: Text.ElideNone
        //     font.pixelSize: Globals.typography.textSubtitle
        //     color: Material.hintTextColor
        //     Layout.preferredWidth: parent.width
        //     horizontalAlignment: Text.AlignHCenter
        //     Layout.bottomMargin: 30 * Globals.scaleFactor
        // }

        Pane {
            id: errorPane
            visible: errorTextElement.text
            Layout.preferredWidth: parent.width
            padding: 10
            Material.roundedScale: Globals.roundedScale
            Material.background: "#2C2C2C"
            background: Rectangle{
                color: "transparent"
                radius: errorPane.Material.roundedScale
                border.width: 2
                border.color: Globals.colors.error
            }

            CustomLabel {
                id: errorTextElement
                text: root.generalError
                color:  Globals.colors.error
                Layout.alignment: Qt.AlignCenter
                width: errorPane.width - 2 * errorPane.padding
            }
            Layout.bottomMargin: 10 * Globals.scaleFactor
        }

        RAppTextfield{
            id: usernameTextfield
            property bool previousTextEmpty: true
            enabled: !loginButton.busy
            Layout.bottomMargin: 5
            text: "admin"
            width: parent.width
            Layout.fillWidth: true
            baseTextfield.placeholderText: "Username"

            onTextChanged: {
                if(text !== ""){
                    if(previousTextEmpty)
                        root.completedFieldsCount++
                    previousTextEmpty = false
                }

                else{
                    previousTextEmpty = true
                    root.completedFieldsCount--
                }
            }

            onHasChangedChanged: {
                if(hasChanged)
                    root.changedFieldsCounter++
                else
                    root.changedFieldsCounter--
            }
        }

        RAppTextfield{
            id: passwordTextfield
            property bool previousTextEmpty: true
            property bool passwordVisible: false
            enabled: !loginButton.busy
            text: "admin123"
            Layout.fillWidth: true
            baseTextfield.placeholderText: qsTr("Password")
            sideComponent: CustomMaterialToolButton{
                activeFocusOnTab: false
                icon.source: passwordTextfield.passwordVisible ? Globals.icons.visibilityOff : Globals.icons.visibilityOn
                Material.accent: root.Material.foreground
                icon.color: !enabled ? Material.hintTextColor : Material.accent
                tooltipText: passwordTextfield.passwordVisible ? qsTr("Hide the password") : qsTr("Show the password")
                onClicked: {
                    passwordTextfield.passwordVisible = !passwordTextfield.passwordVisible
                }
            }
            baseTextfield.echoMode: passwordVisible ? TextInput.Normal  : TextInput.Password

            onTextChanged: {
                if(text !== ""){
                    if(previousTextEmpty)
                        root.completedFieldsCount++
                    previousTextEmpty = false
                }

                else{
                    previousTextEmpty = true
                    root.completedFieldsCount--
                }
            }

            onHasChangedChanged: {
                if(hasChanged)
                    root.changedFieldsCounter++
                else
                    root.changedFieldsCounter--
            }
        }

        TextLink{
            id: forgPasswLink
            enabled: !loginButton.busy && false
            Layout.alignment: Qt.AlignRight
            text: qsTr('Forgot password?')
            Material.foreground: Globals.colors.tertiary
        }

        RAppButton{
            id: loginButton
            busy: Globals.userState === 1
            extraEnableHint: root.canSubmitForm
            width: parent.width
            text:  "Login"
            Layout.fillWidth: true
            onClicked: {
                console.log("Here")
                // actionProvider.login(usernameTextfield.text, passwordTextfield.text)
                mainController.login(usernameTextfield.text, passwordTextfield.text)
                root.clearErrors()
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            CustomLabel{
                text: qsTr("Do not have an account?")
            }

            TextLink{
                text: "Register"
                color: Globals.colors.tertiary
                onClicked: {
                    root.registerRequested()
                }
            }
        }

        Keys.onReturnPressed: {
            loginButton.clicked()
        }
    }



    function clearErrors(){
        usernameTextfield.errorText = ""
        passwordTextfield.errorText = ""
        root.generalError = ""
    }

    Component.onCompleted: {
        usernameTextfield.baseTextfield.forceActiveFocus()
    }
}
