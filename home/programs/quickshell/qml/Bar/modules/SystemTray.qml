import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

Row {
    property var bar
    property var shell
    property var trayMenu
    spacing: 8
    Layout.alignment: Qt.AlignVCenter
    
    // Reference to SystemTray singleton
    property var systemTray: SystemTray
    
    Repeater {
        model: systemTray.items
        delegate: Item {
            width: 24
            height: 24
            // Hide Spotify icon, or adjust to your liking
            visible: modelData && modelData.id !== "spotify"
            property bool isHovered: trayMouseArea.containsMouse
            
            // Hover scale animation
            scale: isHovered ? 1.15 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
            
            // Subtle rotation on hover
            rotation: isHovered ? 5 : 0
            Behavior on rotation {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: modelData.icon
                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            MouseArea {
                id: trayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: (mouse) => {
                    if (!modelData) return;
                    
                    if (mouse.button === Qt.LeftButton) {
                        // Close any open menu first
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hide()
                        }
                        
                        if (!modelData.onlyMenu) {
                            modelData.activate()
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        // Close any open menu first
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hide()
                        }
                        
                        modelData.secondaryActivate && modelData.secondaryActivate()
                    } else if (mouse.button === Qt.RightButton) {
                        console.log("Right click on", modelData.id, "hasMenu:", modelData.hasMenu, "menu:", modelData.menu)
                        
                        // If menu is already visible, close it
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hide()
                            return
                        }
                        
                        if (modelData.hasMenu && modelData.menu && trayMenu) {
                            
                            // Find the bar's root element (traverse up to avoid animations)
                            let barRoot = parent
                            while (barRoot.parent && barRoot.parent.parent) {
                                barRoot = barRoot.parent
                            }
                            
                            // Get this icon's position relative to the bar root
                            const iconPos = mapToItem(barRoot, 0, 0)
                            
                            // Position the menu relative to the bar root
                            const menuX = iconPos.x - (trayMenu.width / 2) + (width / 2) // Center under icon
                            const menuY = iconPos.y + height + 15 // 15px below icon
                            
                            console.log("Using bar root as parent")
                            console.log("Icon position in bar root:", iconPos.x, iconPos.y)
                            console.log("Setting menu position:", menuX, menuY)
                            
                            trayMenu.menu = modelData.menu
                            trayMenu.show(Qt.point(menuX, menuY), barRoot) // Use bar root as parent
                        } else {
                            console.log("No menu available for", modelData.id, "or trayMenu not set")
                        }
                    }
                }
            }
        }
    }
}