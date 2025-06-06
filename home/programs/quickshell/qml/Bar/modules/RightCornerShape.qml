import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Shape {
    id: rightCornerShape
    required property var shell
    required property var popup
    required property var barRect
    width: 60
    height: barRect.height
    y: barRect.y
    //x: barRect.x + barRect.width - 5
    x: barRect.x + barRect.width - 16
    preferredRendererType: Shape.CurveRenderer

    // Entrance animation
    opacity: 0
    Component.onCompleted: opacity = 1
    Behavior on opacity {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }
    }

    ShapePath {
        strokeWidth: 0
        fillColor: shell.accentColor
        strokeColor: "transparent"

        startX: rightCornerShape.width
        startY: 0

        PathLine { x: 15; y: 0 }
        PathLine { x: 15; y: 20 }

        PathArc {
            x: 5; y: 40
            radiusX: 20; radiusY: 20
            useLargeArc: false
            direction: PathArc.Clockwise
        }

        PathLine { x: 0; y: 42 }
        PathLine { x: rightCornerShape.width - 20; y: rightCornerShape.height }

        PathArc {
            x: rightCornerShape.width; y: rightCornerShape.height - 20
            radiusX: 20; radiusY: 20
            useLargeArc: false
            direction: PathArc.Counterclockwise
        }

        PathLine { x: rightCornerShape.width; y: 0 }
    }

    Rectangle {
        id: popupButtons
        width: 24
        height: 24
        radius: 20
        color: (shell.cliphistWindow && shell.cliphistWindow.visible) ? Qt.darker(shell.accentColor, 1.3) : shell.bgColor
        anchors.verticalCenter: parent.verticalCenter
        x: 23
        
        property bool isHovered: rightPopupMouseArea.containsMouse
        property bool isCliphistActive: shell.cliphistWindow && shell.cliphistWindow.visible

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        // Hover and active state animations
        scale: isCliphistActive ? 1.1 : (isHovered ? 1.05 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Label {
            anchors.centerIn: parent
            text: ""
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 14
            color: shell.fgColor
            
            // Clipboard icon bounce animation
            scale: parent.isHovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }
        }

        MouseArea {
            id: rightPopupMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                console.log("Right button clicked - toggling cliphistWindow")
                if (shell.cliphistWindow) {
                    // Close the main popup if it's open
                    if (popup.visible) {
                        popup.visible = false
                    }
                    
                    // Toggle clipboard window
                    if (shell.cliphistWindow.visible) {
                        shell.cliphistWindow.visible = false
                    } else {
                        shell.cliphistWindow.visible = true
                    }
                } else {
                    console.log("cliphistWindow not found")
                }
            }
        }
    }
}