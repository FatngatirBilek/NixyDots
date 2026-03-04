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

    // Dot — fill based on occupied, glow based on active:
    //   occupied → solid accent (has apps on this workspace)
    //   empty    → hollow ring (no apps)
    //   active   → glow shadow added (independent of fill)
    Rectangle {
        id: dot
        anchors.centerIn: parent

        width: root.isActive ? 10 : (root.isOccupied ? 8 : 6)
        height: width
        radius: width / 2

        color: root.isOccupied ? Colors.accent : "transparent"

        border.width: !root.isOccupied ? 1.5 : 0
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
