import QtQuick
import Quickshell.Services.Notifications
import "root:/Data/" as Data

Item {
    id: service
    
    property var shell
    property alias notificationServer: notificationServer
    
    property int maxHistorySize: 50
    
    NotificationServer {
        id: notificationServer
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        
        Component.onCompleted: {
            console.log("Notification server initialized")
        }
        
        onNotification: (notification) => {
            // Early filtering to prevent unnecessary processing
            if (!notification.appName && !notification.summary && !notification.body) {
                // Immediately dismiss invalid notifications
                if (typeof notification.dismiss === 'function') {
                    notification.dismiss()
                }
                return
            }
            
            if (Data.Settings.ignoredApps.includes(notification.appName)) {
                // Dismiss ignored notifications immediately
                if (typeof notification.dismiss === 'function') {
                    notification.dismiss()
                }
                return
            }
            
            if (Qt.application.arguments.includes("--debug")) {
                console.log("[NOTIFICATION]", notification.appName, notification.summary)
            }
            
            shell.addToNotificationHistory(notification, maxHistorySize)
            
            if (!shell.notificationWindow.visible) {
                shell.notificationWindow.visible = true
            }
        }
    }
}