import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

Column {
    required property var shell
    
    Layout.alignment: Qt.AlignVCenter
    spacing: 8

    Row {
        spacing: 8

        Repeater {
            model: shell.workspaces
            delegate: Rectangle {
                id: workspaceRect
                radius: 20
                width: 24
                height: 24
                color: modelData && modelData.id === shell.focusedWorkspace?.id
                    ? shell.accentColor : Qt.darker(shell.fgColor, 2.5)
                
                property bool isActive: modelData && modelData.id === shell.focusedWorkspace?.id
                property bool isHovered: workspaceMouseArea.containsMouse

                // Smooth color transitions
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                // Scale animation for active workspace
                scale: isActive ? 1.1 : (isHovered ? 1.05 : 1.0)
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                // Subtle glow effect for active workspace
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 4
                    height: parent.height + 4
                    radius: parent.radius + 2
                    color: "transparent"
                    border.color: shell.accentColor
                    border.width: isActive ? 1 : 0
                    opacity: isActive ? 0.3 : 0
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on border.width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Label {
                    text: modelData?.id || "?"
                    anchors.centerIn: parent
                    color: shell.bgColor
                    font.pixelSize: 12
                    font.bold: true
                    
                    // Subtle text animation
                    scale: parent.isActive ? 1.05 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    id: workspaceMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData?.id && Hyprland.dispatch) {
                            Hyprland.dispatch("workspace " + modelData.id)
                        }
                    }
                }
            }
        }
    }
}