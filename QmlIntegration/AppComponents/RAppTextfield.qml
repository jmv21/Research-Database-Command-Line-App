import QtQuick
import QtQuick.Controls.Material

import "../Components"

import QmlIntegration


CustomMaterialTextfield{
    id: control
    errorIconSource: Globals.icons.error
    hasError: errorText
    errorColor: Globals.colors.error
    property string originalText: ""
    property string previousErrorText: ""
    property bool hasChanged: text !== originalText
    text: originalText
    Material.roundedScale: Globals.roundedScale
    Material.accent: Globals.colors.primary
    Connections{
        target: control
        function onTextChanged() {
            errorText = ""
        }
    }
}
