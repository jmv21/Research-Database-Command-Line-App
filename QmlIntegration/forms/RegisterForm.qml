import QtQuick
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl
import QtQuick.Layouts
import QmlIntegration

import "../Components/Form"
import "../Components/"
import "../Components/Text"
import "../AppComponents"
import "../Controls"
import "./"

BaseForm {
    id: root
    property string generalError: ""
    requiredFieldsCount: 4

    implicitHeight: formLayout.implicitHeight
    implicitWidth: formLayout.implicitWidth
    signal returnBackRequested()

    ColumnLayout{
        id: formLayout
        width: parent.width
        anchors.centerIn: parent
        spacing: 10

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
            Layout.fillWidth: true
            baseTextfield.placeholderText: qsTr("Password*")
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


        RAppTextfield{
            id: fullNameTextfield
            property bool previousTextEmpty: true
            enabled: !loginButton.busy
            Layout.bottomMargin: 5
            width: parent.width
            Layout.fillWidth: true
            baseTextfield.placeholderText: "Full Name*"

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
            id: emailTextfield
            property bool previousTextEmpty: true
            enabled: !loginButton.busy
            Layout.bottomMargin: 5
            width: parent.width
            Layout.fillWidth: true
            baseTextfield.placeholderText: "Email"

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

        RAppButton{
            id: loginButton
            busy: Globals.userState === 1
            extraEnableHint: root.canSubmitForm
            width: parent.width
            text:  "Register"
            Layout.fillWidth: true
            onClicked: {
                console.log("Here")
                // actionProvider.login(usernameTextfield.text, passwordTextfield.text)
                registerController.register(root.getValuesMap())
                root.clearErrors()
            }
        }

        Keys.onReturnPressed: {
            loginButton.clicked()
        }
    }

    function getValuesMap(){
        return {
            "username": usernameTextfield.text,
            "password": passwordTextfield.text,
            "confirm_password": passwordTextfield.text,
            "full_name": fullNameTextfield.text,
            "email": emailTextfield.text
        }
    }

    Connections {
        target: registerController // Assuming registerController is exposed as a property

        function onRegistrationSucceeded() {
            root.returnBackRequested()
        }

        function onRegistrationFailed(errorMessage, fieldErrors) {
            // for (var key in fieldErrors) {
            //     if (fieldErrors[key]) {  // Only print if the value is non-empty
            //         console.log(key + " →", fieldErrors[key]);
            //     }
            // }

            // Handle field errors if needed
            if (fieldErrors.username) {
                usernameTextfield.errorText = fieldErrors.username
            }
            if (fieldErrors.password) {
                passwordTextfield.errorText = fieldErrors.password
            }
            if (fieldErrors.full_name) {
                fullNameTextfield.errorText = fieldErrors.full_name
            }
            if (fieldErrors.email) {
                emailTextfield.errorText = fieldErrors.email
            }
            if (fieldErrors.generalError) {
                root.generalError = fieldErrors.generalError
            }
        }
    }
}
