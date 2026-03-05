pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CalendarState — shared singleton for all calendar/reminder widgets.
//
// Responsibilities:
//   • Load & save events  → ~/.config/quickshell/calendar-events.json
//   • Load & save reminders → ~/.config/quickshell/reminders.json
//   • Expose addEventOpen / addReminderOpen flags so that
//     Bottom-layer widgets can signal Overlay-layer form panels to open.
//
// Format – events:
//   [{"date":"YYYY-MM-DD","time":"HH:MM","title":"...","color":"#rrggbb"}, ...]
// Format – reminders:
//   [{"id":1234,"text":"...","done":false,"time":"","place":""}, ...]

Singleton {
    id: root

    // ── Panel visibility flags ────────────────────────────────────────────────
    // Set to true from the widget (Bottom layer); the Overlay panel windows
    // watch these and show/hide themselves accordingly.
    property bool   addEventOpen:         false
    property bool   addReminderOpen:      false

    // Pre-fill default date for the Add Event form (set before opening).
    property string addEventDefaultDate:  ""

    // ── File paths ────────────────────────────────────────────────────────────
    readonly property string eventsFile:    "/home/fathirbimashabri/.config/quickshell/calendar-events.json"
    readonly property string remindersFile: "/home/fathirbimashabri/.config/quickshell/reminders.json"

    // ── In-memory data ────────────────────────────────────────────────────────
    property var events:    []
    property var reminders: []

    // ── Boot: load both files ─────────────────────────────────────────────────
    Component.onCompleted: {
        loadEventsProc.running    = true
        loadRemindersProc.running = true
    }

    // ── Load events ───────────────────────────────────────────────────────────
    Process {
        id: loadEventsProc
        command: ["cat", root.eventsFile]
        running: false

        property string _buf: ""

        stdout: SplitParser {
            onRead: function(line) { loadEventsProc._buf += line + "\n" }
        }

        onExited: function(code) {
            if (code === 0) {
                try { root.events = JSON.parse(_buf.trim()) } catch(e) { root.events = [] }
            }
            _buf = ""
        }
    }

    // ── Load reminders ────────────────────────────────────────────────────────
    Process {
        id: loadRemindersProc
        command: ["cat", root.remindersFile]
        running: false

        property string _buf: ""

        stdout: SplitParser {
            onRead: function(line) { loadRemindersProc._buf += line + "\n" }
        }

        onExited: function(code) {
            if (code === 0) {
                try { root.reminders = JSON.parse(_buf.trim()) } catch(e) { root.reminders = [] }
            }
            _buf = ""
        }
    }

    // ── Persist events ────────────────────────────────────────────────────────
    Process {
        id: saveEventsProc
        running: false
        property string _payload: "[]"

        command: [
            "python3", "-c",
            "import json,sys,os\n" +
            "p=sys.argv[2]\n" +
            "os.makedirs(os.path.dirname(p),exist_ok=True)\n" +
            "open(p,'w',encoding='utf-8').write(json.dumps(json.loads(sys.argv[1]),indent=2,ensure_ascii=False))\n",
            saveEventsProc._payload,
            root.eventsFile
        ]
    }

    // ── Persist reminders ─────────────────────────────────────────────────────
    Process {
        id: saveRemindersProc
        running: false
        property string _payload: "[]"

        command: [
            "python3", "-c",
            "import json,sys,os\n" +
            "p=sys.argv[2]\n" +
            "os.makedirs(os.path.dirname(p),exist_ok=True)\n" +
            "open(p,'w',encoding='utf-8').write(json.dumps(json.loads(sys.argv[1]),indent=2,ensure_ascii=False))\n",
            saveRemindersProc._payload,
            root.remindersFile
        ]
    }

    // ── Private: commit events array to disk ──────────────────────────────────
    function _flushEvents(arr) {
        root.events = arr
        try {
            saveEventsProc._payload = JSON.stringify(arr)
            saveEventsProc.running  = true
        } catch(e) {
            console.warn("CalendarState: failed to serialize events:", e)
        }
    }

    // ── Private: commit reminders array to disk ───────────────────────────────
    function _flushReminders(arr) {
        root.reminders = arr
        try {
            saveRemindersProc._payload = JSON.stringify(arr)
            saveRemindersProc.running  = true
        } catch(e) {
            console.warn("CalendarState: failed to serialize reminders:", e)
        }
    }

    // ── Public API: Events ────────────────────────────────────────────────────

    function addEvent(date, time, title, color) {
        var arr = root.events.slice()
        arr.push({ date: date, time: time, title: title, color: color || "#4ade80" })
        arr.sort(function(a, b) {
            var ka = (a.date || "") + "T" + (a.time || "")
            var kb = (b.date || "") + "T" + (b.time || "")
            return ka < kb ? -1 : ka > kb ? 1 : 0
        })
        _flushEvents(arr)
    }

    function deleteEvent(idx) {
        var arr = root.events.slice()
        if (idx < 0 || idx >= arr.length) return
        arr.splice(idx, 1)
        _flushEvents(arr)
    }

    // ── Public API: Reminders ─────────────────────────────────────────────────

    // text    — reminder title (required)
    // time    — ISO-ish datetime string "YYYY-MM-DDTHH:MM" or "" (optional)
    // place   — location string or "" (optional)
    function addReminder(text, time, place) {
        if (!text || text.trim() === "") return
        var arr = root.reminders.slice()
        arr.push({
            id:    Date.now(),
            text:  text.trim(),
            done:  false,
            time:  time  || "",
            place: place || ""
        })
        _flushReminders(arr)
    }

    function toggleReminder(idx) {
        var arr = JSON.parse(JSON.stringify(root.reminders))
        if (idx < 0 || idx >= arr.length) return
        arr[idx].done = !arr[idx].done
        _flushReminders(arr)
    }

    function deleteReminder(idx) {
        var arr = JSON.parse(JSON.stringify(root.reminders))
        if (idx < 0 || idx >= arr.length) return
        arr.splice(idx, 1)
        _flushReminders(arr)
    }
}
