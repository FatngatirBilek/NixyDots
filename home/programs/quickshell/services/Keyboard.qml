pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Hyprland XKB layout (fallback when fcitx5 is not running)
    property string layoutFull: "?"

    // Fcitx5 current input method name (e.g. "mozc", "keyboard-us")
    property string fcitxIM: ""

    // Resolved display string — fcitx5 takes priority over Hyprland XKB
    readonly property string layout: {
        if (fcitxIM !== "") {
            // Mozc → Japanese
            if (fcitxIM === "mozc")
                return "ja"
            // keyboard-us / keyboard-jp / etc. → strip prefix, take first 2 chars
            if (fcitxIM.startsWith("keyboard-"))
                return fcitxIM.replace("keyboard-", "").slice(0, 2)
            // Any other IM: take first 2 chars of its name
            return fcitxIM.slice(0, 2)
        }
        // Fallback: Hyprland XKB layout
        return layoutFull.slice(0, 2).toLowerCase()
    }

    // ── Hyprland XKB layout events ───────────────────────────────────────────
    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "activelayout") {
                root.layoutFull = event.parse(2)[1]
                // Re-sync fcitx5 state whenever Hyprland fires a layout event too
                if (!fcitxQuery.running)
                    fcitxQuery.running = true
            }
        }
    }

    // Initial Hyprland keyboard layout query
    Process {
        running: true
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: root.layoutFull = JSON.parse(text).keyboards.find(k => k.main).active_keymap
        }
    }

    // ── Fcitx5 current IM query ───────────────────────────────────────────────
    // fcitx5-remote -n prints the active input method name and exits immediately.
    // Returns e.g. "mozc", "keyboard-us". Empty / error when fcitx5 is not running.
    Process {
        id: fcitxQuery
        command: ["fcitx5-remote", "-n"]
        stdout: StdioCollector {
            onStreamFinished: {
                const im = text.trim()
                if (im !== "")
                    root.fcitxIM = im
            }
        }
    }

    // Poll fcitx5-remote every second so IM switches show up quickly.
    // (Fcitx5 does not fire Hyprland events, so event-driven detection is not
    // possible without a persistent dbus-monitor process.)
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (!fcitxQuery.running)
                fcitxQuery.running = true
        }
    }

    // Run an initial query shortly after startup so the indicator is correct
    // before the first poll tick fires.
    Timer {
        interval: 300
        repeat: false
        running: true
        onTriggered: {
            if (!fcitxQuery.running)
                fcitxQuery.running = true
        }
    }
}
