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

    // ── Widget cluster layout ─────────────────────────────────────────────────
    //
    //   ┌──────────────┐  ┌───────────────────────────────┐
    //   │  Photo       │  │  Reminders                    │
    //   │  (square)    │  │  (same height as photo)       │
    //   └──────────────┘  └───────────────────────────────┘
    //   ┌──────────────────────────────────────────────────┐
    //   │  Calendar  (width = photo + gap + reminders)     │
    //   └──────────────────────────────────────────────────┘
    //
    // All three widgets share the same left margin and top margin.
    // Adjust widgetClusterMarginLeft / widgetClusterMarginTop to move the cluster.
    // widgetGap controls the space between cards both horizontally and vertically.

    readonly property int widgetClusterMarginLeft: 24
    readonly property int widgetClusterMarginTop:  28
    readonly property int widgetGap:               16

    // ── Photo Widget ──────────────────────────────────────────────────────────
    readonly property bool showPhotoWidget:   true
    readonly property int  photoWidgetWidth:  200
    readonly property int  photoWidgetHeight: 200

    // ── Bottom Photo Widget (additional photo card) ───────────────────────────
    // Created so you can show a second photo below the calendar. Disabled by default.
    readonly property bool showPhotoWidgetBottom: false
    readonly property int  photoWidgetBottomWidth: photoWidgetWidth
    readonly property int  photoWidgetBottomHeight: photoWidgetHeight

    // ── Reminders Widget ──────────────────────────────────────────────────────
    // Height is intentionally the same as photoWidgetHeight so the top row aligns.
    readonly property bool showRemindersWidget:   true
    readonly property int  remindersWidgetWidth:  430
    readonly property int  remindersWidgetHeight: photoWidgetHeight

    // ── Calendar Widget ───────────────────────────────────────────────────────
    // Width auto-spans photo + gap + reminders so all three cards are flush.
    readonly property bool showCalendarWidget:   true
    readonly property int  calendarWidgetWidth:  photoWidgetWidth + widgetGap + remindersWidgetWidth
    readonly property int  calendarWidgetHeight: 278
}
