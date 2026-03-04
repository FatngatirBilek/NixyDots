import QtQuick
import qs.theme
import qs.widgets.text
import qs.widgets.icons

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool isOn: false
    property bool enabled: true
    property alias hovered: mouseArea.containsMouse

    signal toggled()

    implicitWidth: 72
    implicitHeight: 64
    opacity: enabled ? 1.0 : 0.5

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Spacing.radiusMd
        color: {
            if (root.isOn) {
                return root.hovered ? Colors.accentAlt : Colors.accent
            }
            return root.hovered ? Colors.bgHover : Colors.bgElevated
        }
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: Motion.hoverDuration }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Spacing.spacingXs

        DuotoneIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: root.icon
            size: Spacing.iconMd
            // When on: use crust (very dark) so icon pops on the bright accent fill.
            // When off: normal active/hover/default tinting.
            color: {
                if (root.isOn)   return Colors.crust
                if (root.hovered) return Colors.iconHoverPrimary
                return Colors.iconPrimary
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.pixelSize: Typography.sizeMicro
            font.letterSpacing: Typography.microLabelSpacing
            color: root.isOn ? Colors.crust : Colors.textMuted

            Behavior on color {
                ColorAnimation { duration: Motion.hoverDuration }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (root.enabled) {
                root.toggled()
            }
        }
    }
}
