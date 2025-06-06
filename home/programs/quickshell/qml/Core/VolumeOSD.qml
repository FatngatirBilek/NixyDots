import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Shapes
import "root:/Data/" as Data

PanelWindow {
    id: volumeOsd
    property var shell
    
    // Window properties
    anchors {
        right: true
    }
    
    width: 45  // Match your WorkspaceOSD width
    height: 250
    visible: false
    color: "transparent"
    exclusiveZone: 0
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: hideOsd()
    }
    
    // Monitor volume changes from shell
    property int lastVolume: -1
    
    Connections {
        target: shell
        function onVolumeChanged() {
            if (shell.volume !== lastVolume && lastVolume !== -1) {
                showOsd()
            }
            lastVolume = shell.volume
        }
    }
    
    Component.onCompleted: {
        if (shell && shell.volume !== undefined) {
            lastVolume = shell.volume
        }
    }
    
    function showOsd() {
        if (!volumeOsd.visible) {
            volumeOsd.visible = true
            slideInAnimation.start()
        }
        hideTimer.restart()
    }
    
    function hideOsd() {
        slideOutAnimation.start()
    }
    
    // Slide in animation (from right to left)
    NumberAnimation {
        id: slideInAnimation
        target: osdContent
        property: "x"
        from: volumeOsd.width
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
    }
    
    // Slide out animation (from left to right)
    NumberAnimation {
        id: slideOutAnimation
        target: osdContent
        property: "x"
        from: 0
        to: volumeOsd.width
        duration: 250
        easing.type: Easing.InCubic
        
        onFinished: {
            volumeOsd.visible = false
            osdContent.x = 0 // Reset position for next show
        }
    }
    
    // OSD Content Container
    Rectangle {
        id: osdContent
        width: parent.width
        height: parent.height
        color: Data.Colors.accentColor
        topLeftRadius: 20
        bottomLeftRadius: 20
        
        // Use Column instead of ColumnLayout for simpler behavior
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Volume icon at top
            Text {
                id: volumeIcon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16  // Reduced for smaller width
                color: Data.Colors.bgColor
                text: {
                    if (!shell || shell.volume === undefined) return "󰝟"
                    
                    var vol = shell.volume
                    
                    if (vol === 0) return "󰝟"
                    else if (vol < 33) return "󰕿"
                    else if (vol < 66) return "󰖀"
                    else return "󰕾"
                }
                
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Subtle animation on icon change
                Behavior on text {
                    SequentialAnimation {
                        PropertyAnimation {
                            target: volumeIcon
                            property: "scale"
                            to: 1.2
                            duration: 100
                        }
                        PropertyAnimation {
                            target: volumeIcon
                            property: "scale"
                            to: 1.0
                            duration: 100
                        }
                    }
                }
            }
            
            // Vertical volume bar container
            Rectangle {
                width: 10
                height: parent.height - volumeIcon.height - volumeLabel.height - 24 - 12 // Account for spacing and margins
                radius: 5
                color: Qt.darker(Data.Colors.accentColor, 1.5)
                border.color: Qt.darker(Data.Colors.accentColor, 2.0)
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Volume fill bar
                Rectangle {
                    id: volumeFill
                    width: parent.width - 2
                    radius: parent.radius - 1
                    x: 1
                    color: Data.Colors.bgColor
                    
                    // Position from bottom
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    
                    height: {
                        if (!shell || shell.volume === undefined) return 0
                        var maxHeight = parent.height - 2
                        return maxHeight * Math.max(0, Math.min(1, shell.volume / 100))
                    }
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
            
            // Volume percentage and label combined
            Text {
                id: volumeLabel
                text: (shell && shell.volume !== undefined ? shell.volume + "%" : "0%")
                font.pixelSize: 10  // Smaller to fit
                font.weight: Font.Bold
                color: Data.Colors.bgColor
                anchors.horizontalCenter: parent.horizontalCenter
                
                Behavior on text {
                    PropertyAnimation {
                        target: volumeLabel
                        property: "opacity"
                        from: 0.7
                        to: 1.0
                        duration: 150
                    }
                }
            }
        }
    }
}