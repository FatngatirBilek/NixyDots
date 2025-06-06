import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import "Data" as Dat
import "Bar" as Bar
import "Core" as Core

ShellRoot {
    id: root
    
    // Expose windows for external access
    property alias bar: shellWindows.mainWindow
    property alias popupWindow: shellWindows.popupWindow
    property alias notificationWindow: shellWindows.notificationWindow
    property alias notificationServer: notificationService.notificationServer
    property alias cliphistWindow: shellWindows.cliphistWindow

    // Notification history
    property var notificationHistory: []
    property int maxHistoryItems: 50

    // Global theme properties from Data/Colors.qml
    readonly property color bgColor: Dat.Colors.bgColor
    readonly property color fgColor: Dat.Colors.fgColor
    readonly property color accentColor: Dat.Colors.accentColor
    readonly property color highlightBg: Dat.Colors.highlightBg
    readonly property color borderColor: Qt.darker(bgColor, 1.1)
    readonly property color errorColor: "#ff5555"

    // Time and date properties
    property string time: Qt.formatDateTime(new Date(), "hh:mm AP")
    property string date: Qt.formatDateTime(new Date(), "ddd MMM d")

    // System state properties
    property string active_window: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
    property var workspaces: Hyprland.workspaces || []
    property var focusedWorkspace: Hyprland.focusedWorkspace
    property var trayItems: SystemTray.items.values || []

    // Audio properties
    property var defaultAudioSink: Pipewire.defaultAudioSink
    property int volume: defaultAudioSink && defaultAudioSink.audio ? Math.round(defaultAudioSink.audio.volume * 100) : 0

    // Weather properties
    property string weatherLocation: Dat.Settings.weatherLocation
    property var weatherData: Dat.Settings.weatherData
    property bool weatherLoading: false

    // Utility function
    function copyToClipboard(text) {
        Clipboard.copy(text);
    }

    function addToNotificationHistory(notification) {
        notificationHistory.unshift({
            appName: notification.appName,
            summary: notification.summary,
            body: notification.body,
            timestamp: new Date(),
            icon: notification.appIcon
        })
        
        if (notificationHistory.length > maxHistoryItems) {
            notificationHistory.pop()
        }
        notificationHistoryChanged()
    }

    // Initialize services and components
    Component.onCompleted: {
        if (Hyprland.refreshWorkspaces) Hyprland.refreshWorkspaces()
        weatherService.loadWeather()
    }

    // Core services
    Core.NotificationService {
        id: notificationService
        shell: root
    }

    Core.WeatherService {
        id: weatherService
        shell: root
    }

    Core.SystemTimers {
        id: systemTimers
        shell: root
        weatherService: weatherService
    }

    Core.ShellWindows {
        id: shellWindows
        shell: root
        notificationService: notificationService
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // System info watermark
    Core.Version {}
    
}