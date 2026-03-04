import QtQuick
import qs.theme

Item {
    id: root

    property bool isActive: false
    property bool isOccupied: false

    implicitWidth: 16
    implicitHeight: 16

    // Glow — only shown for the active workspace
    Rectangle {
        id: glow
        anchors.centerIn: parent
        width: 22
        height: 22
        radius: width / 2
        color: Colors.withAlpha(Colors.accent, 0.3)
        opacity: root.isActive ? 1 : 0
        scale: root.isActive ? 1 : 0.5

        Behavior on opacity {
            NumberAnimation { duration: Motion.glowDuration }
        }
        Behavior on scale {
            NumberAnimation { duration: Motion.glowDuration }
        }
    }

    // Dot — three visual states:
    //   active   → bigger, solid accent, glow above renders the shadow
    //   occupied → medium, solid accent, no glow
    //   empty    → smaller, hollow ring (transparent fill + border)
    Rectangle {
        id: dot
        anchors.centerIn: parent

        width: root.isActive ? 10 : (root.isOccupied ? 8 : 6)
        height: width
        radius: width / 2

        color: (root.isActive || root.isOccupied) ? Colors.accent : "transparent"

        border.width: (!root.isOccupied && !root.isActive) ? 1.5 : 0
        border.color: Colors.textDim

        Behavior on width {
            NumberAnimation {
                duration: Motion.dotDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.curveGlide
            }
        }

        Behavior on color {
            ColorAnimation { duration: Motion.dotDuration }
        }
    }
}
