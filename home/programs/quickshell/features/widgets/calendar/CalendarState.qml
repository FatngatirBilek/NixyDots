pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CalendarState — shared singleton for all calendar/reminder widgets.
//
// Responsibilities:
//   • Load & save events  → ~/.config/quickshell/calendar-events.json
//   • Load & save reminders → ~/.config/quickshell/reminders.json
//   • Expose addEventOpen / addReminderOpen / editEventOpen flags so that
//     Bottom-layer widgets can signal Overlay-layer form panels to open.
//   • Fire desktop notifications (notify-send) before events based on
//     each event's notifyMins field.
//
// Format – events:
//   [{"date":"YYYY-MM-DD","time":"HH:MM","title":"...","color":"#rrggbb",...}, ...]
//   Extended fields (optional, stored when editing):
//     endDate, endTime, location, notes, repeat, notifyMins
// Format – reminders:
//   [{"id":1234,"text":"...","done":false,"time":"","place":""}, ...]

Singleton {
    id: root

    // ── Panel visibility flags ────────────────────────────────────────────────
    property bool   addEventOpen:        false
    property bool   addReminderOpen:     false
    property bool   editEventOpen:       false

    // Pre-fill default date for the Add Event form (set before opening).
    property string addEventDefaultDate: ""

    // Index of the event being edited (-1 = none).
    property int    editEventIndex:      -1

    // ── File paths ────────────────────────────────────────────────────────────
    readonly property string eventsFile:    "/home/fathirbimashabri/.config/quickshell/calendar-events.json"
    readonly property string remindersFile: "/home/fathirbimashabri/.config/quickshell/reminders.json"

    // ── In-memory data ────────────────────────────────────────────────────────
    property var events:    []
    property var reminders: []

    // ── Notification state ────────────────────────────────────────────────────
    // Queue of {title, body} objects waiting to be sent.
    property var  _notifyQueue:   []
    property bool _notifyBusy:    false
    // Keys of notifications already sent this session (reset on restart).
    // Key format: "YYYY-MM-DDTHH:MM|title|notifyMins"
    property var  _notifiedKeys:  ({})

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

    // ── Desktop notifications via notify-send ─────────────────────────────────
    Process {
        id: notifyProc
        running: false

        property string _title:   ""
        property string _message: ""

        command: [
            "notify-send",
            "--app-name=Calendar",
            "--icon=x-office-calendar",
            "--urgency=normal",
            "--expire-time=8000",
            notifyProc._title,
            notifyProc._message
        ]

        onExited: {
            root._notifyBusy = false
            root._drainNotifyQueue()
        }
    }

    // ── Per-minute event notification check ───────────────────────────────────
    // Fires on startup and then every 60 seconds.
    Timer {
        id: notifyCheckTimer
        interval:          60000
        running:           true
        repeat:            true
        triggeredOnStart:  true

        onTriggered: {
            const now    = new Date()
            const nowH   = now.getHours()
            const nowMin = now.getMinutes()

            // Build today's date string YYYY-MM-DD
            const todayStr = String(now.getFullYear()) + "-"
                           + String(now.getMonth() + 1).padStart(2, "0") + "-"
                           + String(now.getDate()).padStart(2, "0")

            // ── Check calendar events ─────────────────────────────────────────
            for (let i = 0; i < root.events.length; i++) {
                const ev = root.events[i]

                // Must have a date and a specific time (not all-day)
                if (!ev.date || !ev.time || ev.time === "") continue

                // Only today's events
                if (ev.date !== todayStr) continue

                // notifyMins: default 10, -1 means "no notification"
                const nm = (ev.notifyMins !== undefined && ev.notifyMins !== null)
                           ? ev.notifyMins : 10
                if (nm < 0) continue

                // Parse event start time
                const tp  = ev.time.split(":")
                const evH = parseInt(tp[0]) || 0
                const evM = parseInt(tp[1]) || 0

                // Notification fires at: event time − nm minutes
                const notifyTotal = evH * 60 + evM - nm
                // Skip if notification would fall on a previous day
                if (notifyTotal < 0) continue

                const notifyH   = Math.floor(notifyTotal / 60)
                const notifyMin = notifyTotal % 60

                // Check current minute matches
                if (notifyH !== nowH || notifyMin !== nowMin) continue

                // Deduplicate within this session
                const key = ev.date + "T" + ev.time + "|" + ev.title + "|" + nm
                if (root._notifiedKeys[key]) continue
                root._notifiedKeys[key] = true

                // Build human-readable body
                let evBody
                if (nm === 0) {
                    evBody = "Starting now"
                } else if (nm < 60) {
                    evBody = "In " + nm + " minute" + (nm === 1 ? "" : "s")
                } else if (nm < 1440) {
                    const hrs = nm / 60
                    evBody = "In " + hrs + " hour" + (hrs === 1 ? "" : "s")
                } else {
                    evBody = "Tomorrow"
                }

                root._pushNotify(ev.title, evBody)
            }

            // ── Check reminders ───────────────────────────────────────────────
            for (let j = 0; j < root.reminders.length; j++) {
                const rem = root.reminders[j]

                // Skip completed reminders and those with no time set
                if (rem.done) continue
                if (!rem.time || rem.time === "") continue

                // notifyMins: default 10, -1 means "no notification"
                const rnm = (rem.notifyMins !== undefined && rem.notifyMins !== null)
                            ? rem.notifyMins : 10
                if (rnm < 0) continue

                // Parse time "YYYY-MM-DDTHH:MM"
                const remParts = rem.time.split("T")
                if (remParts.length < 2) continue
                const remDateStr = remParts[0]
                const remTimeParts = remParts[1].split(":")
                const remH = parseInt(remTimeParts[0]) || 0
                const remM = parseInt(remTimeParts[1]) || 0

                // Notification fires at: due time − rnm minutes
                const remNotifyTotal = remH * 60 + remM - rnm
                if (remNotifyTotal < 0) continue

                const remNotifyH   = Math.floor(remNotifyTotal / 60)
                const remNotifyMin = remNotifyTotal % 60

                if (remDateStr !== todayStr) continue
                if (remNotifyH !== nowH || remNotifyMin !== nowMin) continue

                // Deduplicate
                const remKey = "rem|" + rem.time + "|" + rem.text + "|" + rnm
                if (root._notifiedKeys[remKey]) continue
                root._notifiedKeys[remKey] = true

                // Build body
                let remBody
                if (rnm === 0) {
                    remBody = "Due now"
                } else if (rnm < 60) {
                    remBody = "Due in " + rnm + " minute" + (rnm === 1 ? "" : "s")
                } else if (rnm < 1440) {
                    const remHrs = rnm / 60
                    remBody = "Due in " + remHrs + " hour" + (remHrs === 1 ? "" : "s")
                } else {
                    remBody = "Due tomorrow"
                }

                root._pushNotify(rem.text, remBody)
            }
        }
    }

    // ── Private: push a notification into the send queue ─────────────────────
    function _pushNotify(title, body) {
        root._notifyQueue = root._notifyQueue.concat([{ title: title, body: body }])
        root._drainNotifyQueue()
    }

    // ── Private: send the next queued notification if not already sending ─────
    function _drainNotifyQueue() {
        if (root._notifyBusy || root._notifyQueue.length === 0) return
        root._notifyBusy = true
        var arr  = root._notifyQueue.slice()
        var item = arr.splice(0, 1)[0]
        root._notifyQueue   = arr
        notifyProc._title   = item.title
        notifyProc._message = item.body
        notifyProc.running  = true
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

    // notifyMins: 0=at time, 5/10/15/30/60=N mins before, -1=no notification
    function addEvent(date, time, title, color, notifyMins) {
        var arr = root.events.slice()
        arr.push({
            date:       date,
            time:       time        || "",
            title:      title,
            color:      color       || "#4ade80",
            notifyMins: (notifyMins !== undefined && notifyMins !== null) ? notifyMins : 10
        })
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

    // Update an existing event by index.
    // All fields are replaced; pass existing values to keep them unchanged.
    function updateEvent(idx, date, time, title, color, endDate, endTime, location, notes, repeat, notifyMins) {
        var arr = JSON.parse(JSON.stringify(root.events))
        if (idx < 0 || idx >= arr.length) return
        arr[idx] = {
            date:       date,
            time:       time       || "",
            title:      title,
            color:      color      || arr[idx].color || "#4ade80",
            endDate:    endDate    || date,
            endTime:    endTime    || "",
            location:   location   || "",
            notes:      notes      || "",
            repeat:     repeat     || "none",
            notifyMins: (notifyMins !== undefined && notifyMins !== null) ? notifyMins : 10
        }
        arr.sort(function(a, b) {
            var ka = (a.date || "") + "T" + (a.time || "")
            var kb = (b.date || "") + "T" + (b.time || "")
            return ka < kb ? -1 : ka > kb ? 1 : 0
        })
        _flushEvents(arr)
    }

    // ── Public API: Reminders ─────────────────────────────────────────────────

    // text       — reminder title (required)
    // time       — ISO-ish datetime string "YYYY-MM-DDTHH:MM" or "" (optional)
    // place      — location string or "" (optional)
    // notifyMins — -1=none, 0=at due time, N=N mins before (default 10)
    function addReminder(text, time, place, notifyMins) {
        if (!text || text.trim() === "") return
        var arr = root.reminders.slice()
        arr.push({
            id:        Date.now(),
            text:      text.trim(),
            done:      false,
            time:      time  || "",
            place:     place || "",
            notifyMins: (notifyMins !== undefined && notifyMins !== null) ? notifyMins : 10
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
