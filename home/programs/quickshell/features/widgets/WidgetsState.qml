pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.theme

// WidgetsState — centralized persistent storage for widget positions and photos.
// Saved to: ~/.config/quickshell/widgets.json
//
// Structure:
// {
//   "positions": { "<instanceId>": { "x": 24, "y": 28 }, ... },
//   "photos":    { "<instanceId>": "/home/you/Pictures/foo.jpg", ... }
// }

Singleton {
    id: root

    readonly property string widgetsFile: "/home/fathirbimashabri/.config/quickshell/widgets.json"

    // In-memory state (mirrors file contents)
    property var positions: {}
    property var photos: {}
    // True when initial load from disk (or defaults + migration) has finished.
    // Widgets (PhotoWidget/CalendarWidget) can wait for this flag before reading state.
    property bool loaded: false

    // Internal buffer used during load
    property string _buf: ""
    // Set when we initialize in-memory defaults but intentionally do NOT
    // persist them immediately to disk. This avoids clobbering an existing
    // widgets.json that may be unreadable in some startup environments
    // (for example when systemd user env differs). Migration or the first
    // widget save will persist when appropriate.
    property bool _createdDefaults: false

    Component.onCompleted: {
        // Trigger initial load
        loadProc.running = true
    }

    // ── Load existing widgets.json (if present); if missing, create defaults ──
    Process {
        id: loadProc
        // If file missing emit a marker so we can create defaults without overwriting existing file
        command: ["bash", "-c", "cat '/home/fathirbimashabri/.config/quickshell/widgets.json' 2>/dev/null || echo '__MISSING__'"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root._buf += line + "\n"
            }
        }

        onExited: function(code) {
            var trimmed = root._buf.trim()
            if (trimmed === "__MISSING__") {
                // File doesn't exist — create defaults based on current Config/Spacing values
                try {
                    var defaultClusterLeft = (typeof Config !== "undefined" && Config.widgetClusterMarginLeft !== undefined) ? Config.widgetClusterMarginLeft : 24
                    var defaultClusterTopBase = (typeof Spacing !== "undefined" && Spacing.barHeight !== undefined) ? Spacing.barHeight : 36
                    var defaultClusterTopOffset = (typeof Config !== "undefined" && Config.widgetClusterMarginTop !== undefined) ? Config.widgetClusterMarginTop : 28
                    var defaultClusterTop = defaultClusterTopBase + defaultClusterTopOffset

                    var pw = (typeof Config !== "undefined" && Config.photoWidgetWidth !== undefined) ? Config.photoWidgetWidth : 200
                    var ph = (typeof Config !== "undefined" && Config.photoWidgetHeight !== undefined) ? Config.photoWidgetHeight : 200
                    var rw = (typeof Config !== "undefined" && Config.remindersWidgetWidth !== undefined) ? Config.remindersWidgetWidth : 430
                    var gw = (typeof Config !== "undefined" && Config.widgetGap !== undefined) ? Config.widgetGap : 16
                    var calh = (typeof Config !== "undefined" && Config.calendarWidgetHeight !== undefined) ? Config.calendarWidgetHeight : 278

                    var left = defaultClusterLeft
                    var top = defaultClusterTop

                    root.positions = {}
                    // photo-top: top-left of the cluster
                    root.positions["photo-top"] = { x: left, y: top }
                    // reminders: to the right of photo-top
                    root.positions["reminders"] = { x: left + pw + gw, y: top }
                    // calendar: below photo+reminders row
                    root.positions["calendar"] = { x: left, y: top + ph + gw }
                    // photo-bottom: below calendar (same left margin)
                    root.positions["photo-bottom"] = { x: left, y: root.positions["calendar"].y + calh + gw }

                    // no photos selected by default
                    root.photos = {}

                    // Do NOT persist defaults immediately. Persisting at this early
                    // stage has caused the file to be overwritten in environments
                    // where the service couldn't read the real user config, resulting
                    // in a default file with empty photos that clobbers a user's
                    // saved photo paths. Keep defaults in-memory and let migration
                    // processes or the first real widget save write the file.
                    root._createdDefaults = true
                    console.log("WidgetsState: initialized default state in-memory (not written) for", root.widgetsFile)

                    // If there are legacy per-widget photo files (created by older versions),
                    // migrate them into widgets.json so users keep their chosen pictures.
                    // Known legacy filenames (in ~/.config/quickshell):
                    //   photo-widget-photo.txt
                    //   photo-widget-bottom-photo.txt
                    //
                    // We kick off short-lived Processes to read those files (if present)
                    // and then update root.photos + re-save.
                    try {
                        // start migration processes (defined below)
                        if (typeof migrateTopProc !== "undefined") migrateTopProc.running = true
                        if (typeof migrateBottomProc !== "undefined") migrateBottomProc.running = true
                    } catch(e) {
                        console.warn("WidgetsState: migration procs could not be started", e)
                    }
                } catch(e) {
                    // If anything fails while computing defaults, fall back to empty state.
                    root.positions = {}
                    root.photos = {}
                    console.warn("WidgetsState: failed to create defaults:", e)
                }
            } else if (trimmed !== "") {
                try {
                    var parsed = JSON.parse(root._buf)
                    root.positions = parsed.positions || {}
                    root.photos = parsed.photos || {}
                    console.log("WidgetsState: loaded", Object.keys(root.positions).length, "positions and", Object.keys(root.photos).length, "photos from", root.widgetsFile)
                } catch(e) {
                    // If parsing fails, reset to empty objects and log
                    root.positions = {}
                    root.photos = {}
                    console.warn("WidgetsState: failed to parse widgets.json:", e)
                }
            } else {
                // Empty file or unexpected — leave empty objects but do not overwrite
                root.positions = {}
                root.photos = {}
                console.log("WidgetsState: widgets.json empty or unreadable; starting with empty state")
            }
            // Mark that the initial load/migration step finished so widgets can safely read state.
            root.loaded = true
            root._buf = ""
        }
    }

    // ── Save helper ──────────────────────────────────────────────────────────
    function _writePayload(obj) {
        // Ensure the payload is serialized and scheduled for saving
        try {
            var payloadStr = JSON.stringify(obj)
            // quick debug logs: payload length and short preview
            console.log("WidgetsState._writePayload: payload_len=", payloadStr.length)
            // show only first 512 chars of payload to avoid huge logs
            console.log("WidgetsState._writePayload: preview=", payloadStr.substring(0, 512))
            saveProc._payload = payloadStr
            console.log("WidgetsState: scheduling save (len=" + payloadStr.length + ") to", root.widgetsFile)
            saveProc.running = true
        } catch(e) {
            console.warn("WidgetsState: failed to stringify payload", e)
        }
    }

    // Use a bash-based writer (more portable in minimal user service envs than relying on python3)
    Process {
        id: saveProc
        running: false
        property string _payload: "{}"

        // Write pretty JSON to disk atomically (ensuring parent dir exists)
        // Note: positional args: $1 = payload, $2 = path
        command: [
            "bash", "-c",
            "p=\"$1\"; mkdir -p \"$(dirname \\\"$2\\\")\"; printf '%s' \"$p\" > \"$2.tmp\" && mv \"$2.tmp\" \"$2\"",
            "_",
            saveProc._payload,
            root.widgetsFile
        ]

        onExited: function(code) {
            if (code !== 0) {
                console.warn("WidgetsState: saveProc exited with code", code)
            } else {
                console.log("WidgetsState: saveProc completed successfully, wrote", root.widgetsFile)
            }
        }
    }

    // ── Migration readers for legacy per-widget photo files ────────────────
    // These processes are intentionally simple: they cat a fixed file path (if present)
    // and update root.photos accordingly. They are triggered once when defaults are created.
    Process {
        id: migrateTopProc
        // argv[1] unused placeholder, argv[2] can be used if we later parameterize
        command: ["bash", "-c", "cat \"$1\" 2>/dev/null || true", "_", "/home/fathirbimashabri/.config/quickshell/photo-widget-photo.txt"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim()
                if (p !== "") {
                    try {
                        root.photos["photo-top"] = p
                        console.log("WidgetsState: migrated photo-top from legacy file:", p)
                        // persist updated photos object (keep current positions)
                        _writePayload({ positions: root.positions, photos: root.photos })
                    } catch(e) {
                        console.warn("WidgetsState: failed to migrate photo-top", e)
                    }
                }
            }
        }
    }

    Process {
        id: migrateBottomProc
        command: ["bash", "-c", "cat \"$1\" 2>/dev/null || true", "_", "/home/fathirbimashabri/.config/quickshell/photo-widget-bottom-photo.txt"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim()
                if (p !== "") {
                    try {
                        root.photos["photo-bottom"] = p
                        console.log("WidgetsState: migrated photo-bottom from legacy file:", p)
                        _writePayload({ positions: root.positions, photos: root.photos })
                    } catch(e) {
                        console.warn("WidgetsState: failed to migrate photo-bottom", e)
                    }
                }
            }
        }
    }

    // ── Public API ──────────────────────────────────────────────────────────

    // Internal implementations (underscore-prefixed) — used by wrapper properties below
    function _setPosition(id, x, y) {
        if (!id) return
        root.positions[id] = { x: x, y: y }
        _writePayload({ positions: root.positions, photos: root.photos })
    }

    function _getPosition(id) {
        if (!id) return null
        var p = root.positions[id]
        return (p === undefined) ? null : p
    }

    function _setPhotoPath(id, path) {
        if (!id) return
        root.photos[id] = path
        _writePayload({ positions: root.positions, photos: root.photos })
    }

    function _getPhotoPath(id) {
        if (!id) return ""
        return root.photos[id] || ""
    }

    function _removeEntry(id) {
        if (!id) return
        if (root.positions[id] !== undefined) delete root.positions[id]
        if (root.photos[id] !== undefined) delete root.photos[id]
        _writePayload({ positions: root.positions, photos: root.photos })
    }

    // Public function APIs — expose as real functions so callers can invoke them directly.
    // These delegate to the internal implementations above.
    function setPosition(id, x, y) {
        root._setPosition(id, x, y)
    }

    function getPosition(id) {
        return root._getPosition(id)
    }

    function setPhotoPath(id, path) {
        root._setPhotoPath(id, path)
    }

    function getPhotoPath(id) {
        return root._getPhotoPath(id)
    }

    function removeEntry(id) {
        root._removeEntry(id)
    }
}
