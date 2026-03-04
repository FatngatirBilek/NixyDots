import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets.icons

RowLayout {
    id: root

    spacing: Spacing.spacingXs

    // ── Network icon ─────────────────────────────────────────────────────────
    Item {
        Layout.preferredWidth: Spacing.iconMd
        Layout.preferredHeight: Spacing.iconMd

        DuotoneIcon {
            anchors.centerIn: parent
            name: Network.icon !== null && Network.icon !== undefined ? Network.icon : "wifi-slash"
            size: Spacing.iconSm
            iconState: !Network.ready || Network.connected === true ? "default" : "disabled"
        }
    }

    // ── Audio icon ───────────────────────────────────────────────────────────
    Item {
        Layout.preferredWidth: Spacing.iconMd
        Layout.preferredHeight: Spacing.iconMd

        DuotoneIcon {
            anchors.centerIn: parent
            name: Audio.icon !== null && Audio.icon !== undefined ? Audio.icon : "speaker-high"
            size: Spacing.iconSm
            iconState: Audio.muted === true ? "disabled" : "default"
        }
    }

    // ── Battery icon + percentage ─────────────────────────────────────────────
    RowLayout {
        visible: Battery.available === true
        spacing: Spacing.spacingXs / 2

        Item {
            Layout.preferredWidth: Spacing.iconMd
            Layout.preferredHeight: Spacing.iconMd

            DuotoneIcon {
                anchors.centerIn: parent
                name: Battery.icon !== null && Battery.icon !== undefined ? Battery.icon : "battery-full"
                size: Spacing.iconSm
                iconState: Battery.isLow === true ? "active" : "default"
            }
        }

        Text {
            text: Battery.percentageInt + "%"
            font.family: Typography.uiFamily
            font.pixelSize: Typography.labelSize
            font.weight: Typography.labelWeight
            color: Battery.isLow === true ? Colors.red : Colors.textPrimary
            verticalAlignment: Text.AlignVCenter
        }
    }
}
