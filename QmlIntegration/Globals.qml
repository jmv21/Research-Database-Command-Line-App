pragma Singleton
import QtQml
import QtQuick
import QtQuick.Controls.Material

QtObject {
    // property bool isNetworkAvailable: MainStore.isNetworkAvailable
    property bool darkTheme: Qt.styleHints.colorScheme === Qt.Dark
    property bool animated: true
    property var materialTheme: darkTheme ? Material.Dark : Material.Light
    property int toolTipTimeout: 3000
    property int userState: authService.state
    property bool userLoggedIn: userState === 2

    property int roundedScale: Material.SmallScale

    signal addNotificationRequested(int notificationType, string titleText, string informationalText)

    property QtObject colors: QtObject {
        // Light mode colors (default) - kept your existing light colors
        property color primaryLight: "#331D62"    // Deep purple
        property color secondaryLight: "#636F83"  // Muted blue-gray
        property color tertiaryLight: "#FE6825"   // Vibrant orange
        property color errorLight: "#DA3434"      // Bright red
        property color successLight: "#2E7D32"    // Forest green
        property color backgroundLight: "#FFFFFF" // Pure white
        property color surfaceLight: "#F5F5F5"    // Off-white
        property color textPrimaryLight: "#212121"// Near-black
        property color textSecondaryLight: "#757575"// Medium gray

        // Enhanced dark mode colors
        property color primaryDark: "#9575CD"     // Softened purple (lighter than BB86FC)
        property color secondaryDark: "#4DB6AC"   // Muted teal (softer than 03DAC6)
        property color tertiaryDark: "#FF8A65"    // Warm, deep orange
        property color errorDark: "#EF5350"       // Coral red (softer than CF6679)
        property color successDark: "#81C784"    // Soft green
        property color backgroundDark: "#121212"  // True dark (kept from original)
        property color surfaceDark: "#1E1E1E"    // Slightly lighter dark (kept)
        property color textPrimaryDark: "#EEEEEE" // Off-white (softer than E0E0E0)
        property color textSecondaryDark: "#9E9E9E"// Light gray (better readability)

        // Current theme colors (computed properties remain same)
        property color primary: darkTheme ? primaryDark : primaryLight
        property color secondary: darkTheme ? secondaryDark : secondaryLight
        property color tertiary: darkTheme ? tertiaryDark : tertiaryLight
        property color error: darkTheme ? errorDark : errorLight
        property color success: darkTheme ? successDark : successLight
        property color background: darkTheme ? backgroundDark : backgroundLight
        property color surface: darkTheme ? surfaceDark : surfaceLight
        property color textPrimary: darkTheme ? textPrimaryDark : textPrimaryLight
        property color textSecondary: darkTheme ? textSecondaryDark : textSecondaryLight
    }

    property QtObject icons: QtObject {
        readonly property string busy: "qrc:/assets/icons/busy.svg"
        readonly property string cancel: "qrc:/assets/icons/cancel.svg"
        readonly property string calendar: "qrc:/assets/icons/calendar_month_outlined.svg"
        readonly property string deleteIcon: "qrc:/assets/icons/delete_FILL1_wght400_GRAD0_opsz24.svg"
        readonly property string download: "qrc:/assets/icons/download_outlined.svg"
        readonly property string editIcon: "qrc:/assets/icons/edit_outlined.svg"
        readonly property string file: "qrc:/assets/icons/file_outlined.svg"
        readonly property string refresh: "qrc:/assets/icons/refresh_outlined.svg"
        readonly property string scienceIcon: "qrc:/assets/icons/science_outlined.svg"
        readonly property string upload: "qrc:/assets/icons/upload_outlined.svg"
        readonly property string add: "qrc:/assets/icons/add.svg"
        readonly property string moreHorizontal: "qrc:/assets/icons/more_horiz_24dp_E8EAED_FILL0_wght400_GRAD0_opsz24.svg"
        readonly property string moreVertical: "qrc:/assets/icons/more_vert.svg"
        readonly property string search: "qrc:/assets/icons/search_outlined.svg"
        readonly property string filterList: "qrc:/assets/icons/filter_list_outlined.svg"
        readonly property string close: "qrc:/assets/icons/close_24dp_FILL0_wght400_GRAD0_opsz24.svg"
        readonly property string visibilityOn: "qrc:/assets/icons/visibility_on_outlined.svg"
        readonly property string visibilityOff: "qrc:/assets/icons/visibility_off_outlined.svg"
        readonly property string info: "qrc:/assets/icons/info.svg"
        readonly property string success: "qrc:/assets/icons/success.svg"
        readonly property string error: "qrc:/assets/icons/error.svg"
        readonly property string warning: "qrc:/assets/icons/warning.svg"
        readonly property string leftArrow: "qrc:/assets/icons/left_arrow.svg"
    }

    property QtObject typography: QtObject {
        // Base Scaling Properties
        readonly property int basePixelSize: 14
        readonly property real baseDPI: 120.0
        readonly property real screenDPI: Screen.pixelDensity * 25.4
        property real scale: 1
        readonly property real scaleFactor: screenDPI / baseDPI * scale

        // Modern Text Size Hierarchy
        readonly property int textLargeHeading: basePixelSize * 2.25 * scaleFactor
        readonly property int textDisplay: basePixelSize * 2.0 * scaleFactor
        readonly property int textHeadline: basePixelSize * 1.75 * scaleFactor
        readonly property int textTitle: basePixelSize * 1.5 * scaleFactor
        readonly property int textSubtitle: basePixelSize * 1.125 * scaleFactor
        readonly property int textBody: basePixelSize * scaleFactor
        readonly property int textTag: basePixelSize * 0.875 * scaleFactor
        readonly property int textCaption: basePixelSize * 0.625 * scaleFactor
        readonly property int textMicro: basePixelSize * 0.5 * scaleFactor
    }

    function requestAddNotification(notificationType, titleText, informationalText){
        console.log("HERE")
        addNotificationRequested(notificationType, titleText, informationalText)
    }


    // function getFileIconSource(fileType) {
    //     switch (fileType) {
    //     case "Image":
    //         return icons.imageFile; // Use image icon for "image"
    //     case "Video":
    //         return icons.videoFile
    //     // case "Audio":
    //     // case "Document":
    //     case "PDF":
    //         return icons.file;
    //     case "Archive":
    //         return icons.zipFile
    //     default:
    //         return icons.file;
    //     }
    // }
}
