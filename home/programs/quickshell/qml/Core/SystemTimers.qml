import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Hyprland

Item {
    id: service
    
    property var shell
    property var weatherService
    
    // Main timer - updates every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            shell.time = Qt.formatDateTime(new Date(), "hh:mm AP")
            shell.date = Qt.formatDateTime(new Date(), "ddd MMM d")
            if (Hyprland.refreshWorkspaces) Hyprland.refreshWorkspaces()
            shell.trayItems = SystemTray.items
        }
    }
    
    // Weather update timer - updates every 10 minutes
    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: weatherService.loadWeather()
    }
}