import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.theme
import qs.core
import qs.services
import qs.widgets.indicators
import qs.config

RowLayout {
    id: root

    property var screen: null

    readonly property HyprlandMonitor monitor: {
        if (screen === null || screen === undefined) return null
        return Hyprland.monitorFor(screen)
    }

    readonly property int activeWsIdForMonitor: {
        if (monitor === null || monitor === undefined) return -1
        const aw = monitor.activeWorkspace
        if (aw === null || aw === undefined) return -1
        return aw.id
    }

    readonly property bool isFocusedMonitor: {
        if (monitor === null || monitor === undefined) return false
        const fm = Hyprland.focusedMonitor
        if (fm === null || fm === undefined) return false
        return fm.id === monitor.id
    }

    spacing: Spacing.spacingSm

    Repeater {
        model: Config.maxWorkspaces

        Dot {
            required property int index

            readonly property int wsId: index + 1

            isActive: root.isFocusedMonitor && root.activeWsIdForMonitor === wsId

            isOccupied: {
                const tls = Hyprland.toplevels
                if (tls === null || tls === undefined) return false
                const values = tls.values
                if (values === null || values === undefined) return false
                for (let i = 0; i < values.length; i++) {
                    const tl = values[i]
                    if (tl !== null && tl !== undefined &&
                        tl.workspace !== null && tl.workspace !== undefined &&
                        tl.workspace.id === wsId) {
                        return true
                    }
                }
                return false
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Dispatcher.dispatch(Actions.switchWorkspace(wsId))
                }
            }
        }
    }
}
