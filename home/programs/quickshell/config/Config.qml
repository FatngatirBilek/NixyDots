pragma Singleton

import QtQuick
import Quickshell

// Quickshell shell configuration
// Adapted from https://github.com/karol-broda/nixos-config for fathirbimashabri's setup
Singleton {
    id: root

    // ── Pinned apps in the launcher / home panel ──────────────────────────────
    // appId must match the .desktop file name (without .desktop)
    readonly property var pinnedApps: [
        { name: "Firefox",  appId: "firefox",                    exec: "firefox" },
        { name: "Ghostty",  appId: "com.mitchellh.ghostty",      exec: "ghostty" },
        { name: "Nautilus", appId: "org.gnome.Nautilus",         exec: "nautilus" },
        { name: "Spotify",  appId: "spotify",                    exec: "spotify" }
    ]

    // ── Shell frame (decorative border around screen edges) ───────────────────
    readonly property bool showFrame: true

    // ── Maximum number of workspaces shown in the bar ─────────────────────────
    readonly property int maxWorkspaces: 10
}
