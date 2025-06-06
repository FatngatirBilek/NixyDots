import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Shapes
import "../Data" as Data
import "./modules" as BarModules
Item {
    id: root
    required property var shell
    required property var popup
    required property var bar
    width: 260
    height: 42
    property Process pavucontrol: null
    
    function createPavucontrol() {
        if (!pavucontrol) {
            pavucontrol = pavucontrolComponent.createObject(root)
        }
        return pavucontrol
    }
    
    Component {
        id: pavucontrolComponent
        Process {
            command: ["pavucontrol"]
        }
    }
    
    Rectangle {
        id: barRect
        anchors.fill: parent
        height: 28
        color: shell.bgColor
        bottomLeftRadius: 20
        bottomRightRadius: 20
        opacity: 1
        
        Item {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            
            RowLayout {
                anchors.fill: parent
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                BarModules.DateTimeDisplay {
                    shell: root.shell
                }
                
                Item { Layout.fillWidth: true }
                
                BarModules.SystemTray {
                    id: systemTrayModule
                    shell: root.shell
                    bar: root.bar
                    // Pass the tray menu reference
                    trayMenu: externalTrayMenu
                }
            }
        }
    }
    
    BarModules.CustomTrayMenu {
        id: externalTrayMenu
    }
    
    BarModules.RightCornerShape {
        shell: root.shell
        popup: root.popup
        barRect: barRect
    }
    
    BarModules.LeftCornerShape {
        shell: root.shell
        popup: root.popup
        barRect: barRect
    }
}