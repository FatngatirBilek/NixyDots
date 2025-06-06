import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Shape {
    id: leftCornerShape
    required property var shell
    required property var popup
    required property var barRect
    
    width: 60
    height: barRect.height
    y: barRect.y
    x: barRect.x - width + 16
    preferredRendererType: Shape.CurveRenderer
    
    opacity: 1
    
    ShapePath {
        strokeWidth: 0
        fillColor: shell.accentColor
        strokeColor: "transparent"
        startX: 0
        startY: 0
        PathLine { x: leftCornerShape.width - 15; y: 0 }
        PathLine { x: leftCornerShape.width - 15; y: 20 }
        PathArc {
            x: leftCornerShape.width - 5; y: 40
            radiusX: 20; radiusY: 20
            useLargeArc: false
            direction: PathArc.Counterclockwise
        }
        PathLine { x: leftCornerShape.width; y: 42 }
        PathLine { x: 20; y: leftCornerShape.height }
        PathArc {
            x: 0; y: leftCornerShape.height - 20
            radiusX: 20; radiusY: 20
            useLargeArc: false
            direction: PathArc.Clockwise
        }
        PathLine { x: 0; y: 0 }
    }
    
    Rectangle {
        id: popupButtonsLeft
        width: 24
        height: 24
        radius: 20
        color: popup.visible ? Qt.darker(shell.accentColor, 1.3) : shell.bgColor
        anchors.verticalCenter: parent.verticalCenter
        x: width - 13
        
        state: popup.visible ? "active" : (leftPopupMouseArea.containsMouse ? "hovered" : "normal")
        
        states: [
            State {
                name: "normal"
                PropertyChanges { target: popupButtonsLeft; scale: 1.0 }
                PropertyChanges { target: iconLabel; scale: 1.0 }
            },
            State {
                name: "hovered"
                PropertyChanges { target: popupButtonsLeft; scale: 1.05 }
                PropertyChanges { target: iconLabel; scale: 1.1 }
            },
            State {
                name: "active"
                PropertyChanges { target: popupButtonsLeft; scale: 1.1 }
                PropertyChanges { target: iconLabel; scale: 1.1 }
            }
        ]
        
        transitions: [
            Transition {
                NumberAnimation {
                    properties: "scale"
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                ColorAnimation {
                    properties: "color"
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        ]
        
        Label {
            id: iconLabel
            anchors.centerIn: parent
            text: "󰘖"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 14
            color: shell.fgColor
        }
        
        MouseArea {
            id: leftPopupMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Close the clipboard window if it's open
                if (shell.cliphistWindow && shell.cliphistWindow.visible) {
                    shell.cliphistWindow.visible = false
                }
                
                // Toggle main popup
                popup.visible = !popup.visible
            }
        }
    }
}