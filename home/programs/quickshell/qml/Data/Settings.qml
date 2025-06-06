pragma Singleton
import Quickshell

Singleton {

    // Weather
    property string weatherLocation: "Dinslaken"

    // System Monitor
    property int cpuRefreshInterval: 5000
    property int ramRefreshInterval: 10000

    // Notification blacklist
    readonly property var ignoredApps: ["some-app", "another-app"]

    // Screen Boarder
    property real borderWidth: 6
    property real cornerRadius: 20

    // Recording location
    property string videoPath: "~/Videos/"

}