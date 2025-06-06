import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root
    required property var shell
    property var notificationQueue: []
    property int displayTime: 10000 // 10 seconds
    property int maxWidth: 400
    property int maxNotifications: 5
    property int notificationSpacing: 12
    property int baseNotificationHeight: 70

    required property var notificationServer

    // Store active timers to manage them properly
    property var activeTimers: ({})
    property int lastNotificationTime: 0

    property int calculatedHeight: {
        let totalHeight = 0;
        let visibleCount = Math.min(notificationQueue.length, maxNotifications);
        
        for (let i = 0; i < visibleCount; i++) {
            let notification = notificationQueue[i];
            let notificationHeight = calculateIndividualHeight(notification);
            totalHeight += notificationHeight;
            
            if (i < visibleCount - 1) {
                totalHeight += notificationSpacing;
            }
        }
        
        return Math.max(totalHeight + 20, 0);
    }

    // Helper function to calculate individual notification height
    function calculateIndividualHeight(notification) {
        let height = 60; // Minimal base height for header + padding
        
        // Add height for app name (always present)
        height += 18;
        
        // Add height for summary if present
        if (notification?.summary && notification.summary.trim() !== "") {
            height += 20;
        }
        
        // Add height for body if present
        if (notification?.body && notification.body.trim() !== "") {
            // Count actual line breaks in the text
            let bodyText = notification.body.trim();
            let explicitLines = (bodyText.match(/\n/g) || []).length + 1;
            let wrapLines = Math.ceil(bodyText.length / 60);
            let estimatedLines = Math.max(explicitLines, wrapLines);
            height += Math.min(estimatedLines * 18, 80); // Cap at ~4 lines
        }
        
        if (notification?.actions?.length > 0) height += 35;
        
        return height;
    }

    // Timer component for auto-expiry
    Component {
        id: expiryTimerComponent
        Timer {
            property var targetNotification
            interval: displayTime
            running: true
            onTriggered: {
                console.log("Timer triggered for notification:", targetNotification?.summary || "unknown")
                if (targetNotification && targetNotification.tracked) {
                    console.log("Auto-expiring notification:", targetNotification.summary)
                    dismissNotification(targetNotification)
                }
                destroy()
            }
        }
    }

    // Connect to the notification server
    Connections {
        target: notificationServer
        
        function onNotification(notification) {
            console.log("NotificationPopup received notification:", notification?.appName || "Unknown", notification?.summary || "No summary")
            
            // Validate notification
            if (!notification) {
                console.warn("Received null notification")
                return
            }
            
            // Mark as tracked and set arrival time
            notification.tracked = true
            let currentTime = Date.now()
            notification.arrivalTime = currentTime
            lastNotificationTime = currentTime
            
            // Add to queue at the beginning (newest first)
            notificationQueue.unshift(notification)
            notificationQueueChanged()
            
            // Create timer for auto-expiry
            let timer = expiryTimerComponent.createObject(root, {
                "targetNotification": notification
            });
            
            if (timer && notification.id) {
                activeTimers[notification.id] = timer;
                console.log("Created timer for notification ID:", notification.id)
            }
            
            // Listen for the notification's closed signal
            if (notification.closed) {
                notification.closed.connect(function(reason) {
                    console.log("Notification closed signal received, reason:", reason)
                    removeFromQueue(notification.id)
                })
            }
            
            // Make sure parent window is visible when we have notifications
            if (root.parent && root.parent.visible !== undefined) {
                root.parent.visible = true
            }
        }
    }

    function removeFromQueue(notificationId) {
        console.log("Removing notification from queue:", notificationId)
        
        // Clean up timer if it exists
        if (activeTimers[notificationId]) {
            activeTimers[notificationId].destroy();
            delete activeTimers[notificationId];
        }
        
        // Remove from queue
        for (let i = 0; i < notificationQueue.length; i++) {
            if (notificationQueue[i] && notificationQueue[i].id === notificationId) {
                notificationQueue.splice(i, 1)
                notificationQueueChanged()
                break
            }
        }
        
        // Hide parent window if no more notifications
        if (notificationQueue.length === 0 && root.parent && root.parent.visible !== undefined) {
            root.parent.visible = false
        }
    }

    function dismissNotification(notification) {
        if (!notification) {
            console.warn("Attempted to dismiss null notification")
            return
        }
        
        console.log("Manually dismissing notification:", notification.summary || "unknown")
        
        // Clean up timer first
        if (notification.id && activeTimers[notification.id]) {
            activeTimers[notification.id].destroy();
            delete activeTimers[notification.id];
        }
        
        // Remove from our queue immediately
        removeFromQueue(notification.id)
        
        // Try to call dismiss on the notification if it exists
        if (typeof notification.dismiss === 'function') {
            try {
                notification.dismiss()
            } catch (e) {
                console.warn("Error calling notification.dismiss():", e)
            }
        } else if (typeof notification.expire === 'function') {
            try {
                notification.expire()
            } catch (e) {
                console.warn("Error calling notification.expire():", e)
            }
        }
    }

    // Clean up all timers when component is destroyed
    Component.onDestruction: {
        console.log("NotificationPopup destroying, cleaning up", Object.keys(activeTimers).length, "timers")
        for (let id in activeTimers) {
            if (activeTimers[id]) {
                activeTimers[id].destroy();
            }
        }
        activeTimers = {}
    }

    // Debug output
    onNotificationQueueChanged: {
        console.log("Notification queue changed, length:", notificationQueue.length)
    }

    Column {
        id: notificationColumn
        width: maxWidth
        spacing: notificationSpacing
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 2

        Repeater {
            model: notificationQueue.length > 0 ? Math.min(notificationQueue.length, maxNotifications) : 0
            
            delegate: Rectangle {
                id: notificationContainer
                property var notification: index < notificationQueue.length ? notificationQueue[index] : null
                property bool isNewest: notification ? (notification.arrivalTime === lastNotificationTime) : false
                
                // Skip rendering if notification is null
                visible: notification !== null
                
                width: maxWidth
                height: notification ? calculateIndividualHeight(notification) : 0
                
                // Main container with border and proper radius
                radius: 20
                color: shell.bgColor
                
                // Apply border directly to the main container
                border.width: 3
                border.color: shell.accentColor
                
                // Subtle gradient overlay
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: parent.border.width
                    radius: parent.radius - parent.border.width
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.08) }
                        GradientStop { position: 1.0; color: Qt.rgba(255, 255, 255, 0.02) }
                    }
                }

                // Animation for newest notification
                opacity: isNewest ? 0 : 1
                scale: isNewest ? 0.95 : 1
                
                Component.onCompleted: {
                    if (isNewest) {
                        slideInAnimation.start()
                    }
                }

                ParallelAnimation {
                    id: slideInAnimation
                    NumberAnimation {
                        target: notificationContainer
                        property: "opacity"
                        from: 0
                        to: 0.92
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: notificationContainer
                        property: "scale"
                        from: 0.95
                        to: 1
                        duration: 300
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.1
                    }
                }

                // Hover effect
                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (notification) {
                            dismissNotification(notification)
                        }
                    }
                    z: -1
                    
                    onEntered: hoverAnimation.start()
                    onExited: unhoverAnimation.start()
                }
                
                NumberAnimation {
                    id: hoverAnimation
                    target: notificationContainer
                    property: "scale"
                    to: 1.02
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                
                NumberAnimation {
                    id: unhoverAnimation
                    target: notificationContainer
                    property: "scale"
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutCubic
                }

                // Content area
                Item {
                    id: contentArea
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    clip: true
                    
                    ColumnLayout {
                        id: notificationContent
                        anchors.fill: parent
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: Qt.rgba(255, 255, 255, 0.05)
                                border.width: 1
                                border.color: shell.accentColor
                                Layout.alignment: Qt.AlignTop
                                Layout.topMargin: 6

                                // Try to show image first
                                Image {
                                    id: appImage
                                    source: notification ? (notification.image || notification.appIcon || "") : ""
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.toString() !== ""
                                }

                                // Show text fallback if no image
                                Text {
                                    id: fallbackText
                                    anchors.centerIn: parent
                                    text: notification && notification.appName ? notification.appName.charAt(0).toUpperCase() : "!"
                                    color: shell.accentColor
                                    font.pixelSize: 12
                                    font.bold: true
                                    visible: !appImage.visible
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    
                                    Text {
                                        text: notification ? (notification.appName || "Notification") : "Notification"
                                        color: shell.accentColor
                                        font.bold: true
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        id: timeText
                                        text: Qt.formatDateTime(new Date(), "hh:mm")
                                        color: Qt.lighter(shell.fgColor, 1.6)
                                        font.pixelSize: 10
                                        opacity: 0.8
                                    }
                                    
                                    // Close button
                                    Button {
                                        width: 18
                                        height: 18
                                        flat: true
                                        onClicked: {
                                            if (notification) {
                                                dismissNotification(notification)
                                            }
                                        }

                                        background: Rectangle {
                                            radius: 9
                                            color: parent.pressed ? Qt.rgba(255, 255, 255, 0.15) :
                                                   parent.hovered ? Qt.rgba(255, 255, 255, 0.1) : 
                                                   Qt.rgba(255, 255, 255, 0.05)
                                            border.width: 1
                                            border.color: Qt.rgba(255, 255, 255, 0.08)
                                        }

                                        contentItem: Text {
                                            text: "×"
                                            color: shell.fgColor
                                            font.pixelSize: 11
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            opacity: 0.8
                                        }
                                    }
                                }

                                Text {
                                    text: notification ? (notification.summary || "") : ""
                                    color: shell.fgColor
                                    font.bold: true
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    visible: text !== "" && text.trim() !== ""
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // Body text
                        Text {
                            text: notification ? (notification.body || "") : ""
                            textFormat: Text.Markdown
                            color: Qt.lighter(shell.fgColor, 1.2)
                            font.pixelSize: 14
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            visible: text !== "" && text.trim() !== ""
                            lineHeight: 1.2
                            Layout.preferredHeight: visible ? implicitHeight : 0
                        }
                    }
                }
            }
        }
    }

    // Enhanced overflow indicator
    Rectangle {
        visible: notificationQueue.length > maxNotifications
        anchors {
            bottom: notificationColumn.bottom
            right: notificationColumn.right
            margins: 12
        }
        width: 70
        height: 28
        radius: 20
        
        color: Qt.rgb(0, 0, 0, 0.2)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.3)

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: shell.accentColor
        }

        Text {
            anchors.centerIn: parent
            text: "+" + (notificationQueue.length - maxNotifications)
            color: shell.bgColor
            font.pixelSize: 12
            font.bold: true
        }
    }
}