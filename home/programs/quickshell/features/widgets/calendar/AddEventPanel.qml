import QtQuick
import QtQuick.Layouts
import qs.theme

// AddEventPanel — "New Event" overlay form, Google Calendar style.
//
// Shown inside an Overlay PanelWindow (shell.qml).
// Opens when CalendarState.addEventOpen becomes true.
// Saves via CalendarState.addEvent() and closes by setting addEventOpen = false.
//
// Layout (top → bottom):
//   Title input + color dot
//   ─────
//   ⏰ All day ──────────── [toggle]
//   Start date   →   End date
//   Start time       End time
//   (inline DatePicker / TimePicker expands on tap)
//   ─────
//   ⊙  Location
//   ─────
//   🔔 10 mins before
//   ─────
//   ↻  Don't repeat
//   ─────
//   ≡  Notes
//   ─────
//   ▷  Video conference
//   ─────
//   ⌖  Attachment
//   ─────
//   ⊙  Invitees
//   ─────
//   ⊕  (GMT+7) Western Indonesia Time
//   ═══════════════════════
//   Cancel          Save

Rectangle {
    id: root

    // ── Geometry ──────────────────────────────────────────────────────────────
    width:          360
    height:         Math.min(formFlickable.contentHeight + footerRow.height, maxHeight)
    property int maxHeight: 620

    radius: 20
    color:  Colors.withAlpha(Colors.base, 0.97)
    clip:   true

    // ── Form state ────────────────────────────────────────────────────────────
    property string titleText:    ""
    property bool   allDay:       false

    property int startYear:   1970
    property int startMonth:  0
    property int startDay:    1
    property int startHour:   9
    property int startMinute: 0

    property int endYear:     1970
    property int endMonth:    0
    property int endDay:      1
    property int endHour:     10
    property int endMinute:   0

    property string locationText: ""
    property string notesText:    ""

    // "none" | "daily" | "weekly" | "monthly"
    property string repeatMode: "none"

    // 0 | 5 | 10 | 15 | 30 | 60  (minutes)
    property int notifyMins: 10

    // "" | "startDate" | "startTime" | "endDate" | "endTime"
    property string activePicker: ""

    // ── Formatting helpers ────────────────────────────────────────────────────
    readonly property var _dayNames:   ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    readonly property var _monthShort: ["Jan","Feb","Mar","Apr","May","Jun",
                                        "Jul","Aug","Sep","Oct","Nov","Dec"]

    function _fmtDate(y, m, d) {
        return _dayNames[new Date(y, m, d).getDay()] + ", " + _monthShort[m] + " " + d
    }

    function _fmtTime(h, min) {
        return String(h).padStart(2, "0") + ":" + String(min).padStart(2, "0")
    }

    function _notifyLabel() {
        if (root.notifyMins === 0)  return "At time of event"
        if (root.notifyMins === 5)  return "5 mins before"
        if (root.notifyMins === 10) return "10 mins before"
        if (root.notifyMins === 15) return "15 mins before"
        if (root.notifyMins === 30) return "30 mins before"
        if (root.notifyMins === 60) return "1 hour before"
        return root.notifyMins + " mins before"
    }

    function _cycleNotify() {
        const opts = [0, 5, 10, 15, 30, 60]
        const idx  = opts.indexOf(root.notifyMins)
        root.notifyMins = opts[(idx + 1) % opts.length]
    }

    function _repeatLabel() {
        switch (root.repeatMode) {
            case "daily":   return "Every day"
            case "weekly":  return "Every week"
            case "monthly": return "Every month"
            default:        return "Don't repeat"
        }
    }

    function _cycleRepeat() {
        const opts = ["none", "daily", "weekly", "monthly"]
        root.repeatMode = opts[(opts.indexOf(root.repeatMode) + 1) % opts.length]
    }

    // ── Reset to a clean state ────────────────────────────────────────────────
    function _reset() {
        root.titleText    = ""
        root.allDay       = false
        root.locationText = ""
        root.notesText    = ""
        root.repeatMode   = "none"
        root.notifyMins   = 10
        root.activePicker = ""
        titleInput.text    = ""
        locationInput.text = ""
        notesInput.text    = ""

        const now          = new Date()
        root.startYear     = now.getFullYear()
        root.startMonth    = now.getMonth()
        root.startDay      = now.getDate()
        root.startHour     = now.getHours()
        root.startMinute   = 0
        root.endYear       = now.getFullYear()
        root.endMonth      = now.getMonth()
        root.endDay        = now.getDate()
        root.endHour       = (now.getHours() + 1) % 24
        root.endMinute     = 0
    }

    function _applyDefaultDate() {
        const s = CalendarState.addEventDefaultDate
        if (!s || s.length < 10) return
        const parts = s.split("-")
        if (parts.length < 3) return
        root.startYear  = parseInt(parts[0])
        root.startMonth = parseInt(parts[1]) - 1
        root.startDay   = parseInt(parts[2])
        root.endYear    = root.startYear
        root.endMonth   = root.startMonth
        root.endDay     = root.startDay
    }

    // ── React when the panel is asked to open ─────────────────────────────────
    Connections {
        target: CalendarState
        function onAddEventOpenChanged() {
            if (!CalendarState.addEventOpen) return
            root._reset()
            root._applyDefaultDate()
            Qt.callLater(function() { titleInput.forceActiveFocus() })
        }
    }

    // ── Outer border ring ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        "transparent"
        border.color: Colors.withAlpha(Colors.text, 0.08)
        border.width: 1
        z:            30
    }

    // ── Base click absorber (prevents clicks escaping through empty areas) ─────
    MouseArea { anchors.fill: parent }

    // ── Scrollable form body ──────────────────────────────────────────────────
    Flickable {
        id: formFlickable
        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
            bottom: footerRow.top
        }
        contentHeight:  formCol.implicitHeight + 32
        clip:           true
        interactive:    contentHeight > height
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: formCol
            width: root.width - 32
            anchors {
                top:              parent.top
                topMargin:        20
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 0

            // ── Title row ─────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height: 44
                spacing: 12

                Item {
                    Layout.fillWidth: true
                    height: 44

                    TextInput {
                        id: titleInput
                        anchors.fill:      parent
                        verticalAlignment: TextInput.AlignVCenter
                        color:             Colors.textPrimary
                        font {
                            family:    Typography.bodyFamily
                            pixelSize: 22
                            weight:    Font.Medium
                        }
                        selectByMouse:     true
                        selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
                        selectedTextColor: Colors.textPrimary
                        clip:              true
                        onTextChanged:     root.titleText = text
                    }

                    Text {
                        anchors.fill:      titleInput
                        verticalAlignment: Text.AlignVCenter
                        visible:           titleInput.text === "" && !titleInput.activeFocus
                        text:              "Title"
                        color:             Colors.textDim
                        font:              titleInput.font
                    }
                }

                // Event colour dot (accent indicator)
                Rectangle {
                    width:   24
                    height:  24
                    radius:  12
                    color:   Colors.accent
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Item { height: 6 }

            // divider
            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

            Item { height: 14 }

            // ── All-day toggle ────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height: 36
                spacing: 14

                // Clock icon (drawn with rectangles)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16; height: 16; radius: 8
                        color:        "transparent"
                        border.color: Colors.overlay1
                        border.width: 1.5

                        // hour hand  (12 → 3)
                        Rectangle {
                            x: 6.5; y: 2.5
                            width: 1.5; height: 5; radius: 1
                            color: Colors.overlay1
                        }
                        // minute hand
                        Rectangle {
                            x: 6.5; y: 7
                            width: 4; height: 1.5; radius: 1
                            color: Colors.overlay1
                        }
                    }
                }

                Text {
                    text:             "All day"
                    color:            Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                }

                // Toggle pill
                Rectangle {
                    width: 46; height: 26; radius: 13
                    color: root.allDay ? Colors.accent : Colors.bgElevated
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        x: root.allDay ? parent.width - width - 3 : 3
                        y: 3
                        width: 20; height: 20; radius: 10
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.allDay = !root.allDay
                            if (root.allDay) root.activePicker = ""
                        }
                    }
                }
            }

            Item { height: 16 }

            // ── Start / End date-time section ─────────────────────────────────
            // Layout: [Start column] → [End column], each col has date on top, time below
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                // ── Start column ──────────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Start date (tappable)
                    Text {
                        Layout.alignment:   Qt.AlignHCenter
                        text:  root._fmtDate(root.startYear, root.startMonth, root.startDay)
                        color: root.activePicker === "startDate" ? Colors.accent : Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 14; weight: Font.Medium }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.activePicker = (root.activePicker === "startDate") ? "" : "startDate"
                        }
                    }

                    // Start time (tappable, hidden when all-day)
                    Text {
                        visible:           !root.allDay
                        Layout.alignment:  Qt.AlignHCenter
                        text:  root._fmtTime(root.startHour, root.startMinute)
                        color: root.activePicker === "startTime" ? Colors.accent : Colors.textSecondary
                        font { family: Typography.monoTextFamily; pixelSize: 15 }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.activePicker = (root.activePicker === "startTime") ? "" : "startTime"
                        }
                    }
                }

                // Arrow between start and end
                Text {
                    text:             "→"
                    color:            Colors.overlay1
                    font.pixelSize:   14
                    Layout.alignment: Qt.AlignVCenter
                    leftPadding:      8
                    rightPadding:     8
                }

                // ── End column ────────────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // End date (tappable)
                    Text {
                        Layout.alignment:  Qt.AlignHCenter
                        text:  root._fmtDate(root.endYear, root.endMonth, root.endDay)
                        color: root.activePicker === "endDate" ? Colors.accent : Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 14; weight: Font.Medium }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.activePicker = (root.activePicker === "endDate") ? "" : "endDate"
                        }
                    }

                    // End time (tappable, hidden when all-day)
                    Text {
                        visible:          !root.allDay
                        Layout.alignment: Qt.AlignHCenter
                        text:  root._fmtTime(root.endHour, root.endMinute)
                        color: root.activePicker === "endTime" ? Colors.accent : Colors.textSecondary
                        font { family: Typography.monoTextFamily; pixelSize: 15 }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.activePicker = (root.activePicker === "endTime") ? "" : "endTime"
                        }
                    }
                }
            }

            Item { height: 8 }

            // ── Inline DatePicker ─────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                visible:          root.activePicker === "startDate" || root.activePicker === "endDate"
                implicitHeight:   visible ? datePick.implicitHeight + 8 : 0
                clip:             true

                DatePicker {
                    id: datePick
                    width: parent.width

                    onVisibleChanged: {
                        if (!visible) return
                        const isSt = root.activePicker === "startDate"
                        viewYear   = isSt ? root.startYear  : root.endYear
                        viewMonth  = isSt ? root.startMonth : root.endMonth
                        selYear    = isSt ? root.startYear  : root.endYear
                        selMonth   = isSt ? root.startMonth : root.endMonth
                        selDay     = isSt ? root.startDay   : root.endDay
                    }

                    onDatePicked: function(y, m, d) {
                        if (root.activePicker === "startDate") {
                            root.startYear = y; root.startMonth = m; root.startDay = d
                        } else {
                            root.endYear   = y; root.endMonth   = m; root.endDay   = d
                        }
                        root.activePicker = ""
                    }
                }
            }

            // ── Inline TimePicker ─────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                visible:          root.activePicker === "startTime" || root.activePicker === "endTime"
                implicitHeight:   visible ? timePick.implicitHeight + 8 : 0
                clip:             true

                TimePicker {
                    id: timePick
                    anchors.horizontalCenter: parent.horizontalCenter

                    onVisibleChanged: {
                        if (!visible) return
                        const isSt = root.activePicker === "startTime"
                        hour   = isSt ? root.startHour   : root.endHour
                        minute = isSt ? root.startMinute : root.endMinute
                    }

                    onTimePicked: function(h, m) {
                        if (root.activePicker === "startTime") {
                            root.startHour = h; root.startMinute = m
                        } else {
                            root.endHour   = h; root.endMinute   = m
                        }
                    }
                }
            }

            Item { height: 14 }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Location ──────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height:  36
                spacing: 14

                // Location pin (drawn)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 0; width: 12; height: 12; radius: 6
                        color:        "transparent"
                        border.color: Colors.overlay1
                        border.width: 1.5
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 6; width: 3; height: 9; radius: 1
                        color: Colors.overlay1
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: 36

                    TextInput {
                        id: locationInput
                        anchors.fill:      parent
                        verticalAlignment: TextInput.AlignVCenter
                        color:             Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 15 }
                        selectByMouse:     true
                        selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
                        selectedTextColor: Colors.textPrimary
                        clip:              true
                        onTextChanged:     root.locationText = text
                    }

                    Text {
                        anchors.fill:      locationInput
                        verticalAlignment: Text.AlignVCenter
                        visible:           locationInput.text === "" && !locationInput.activeFocus
                        text:              "Location"
                        color:             Colors.textDim
                        font:              locationInput.font
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Notification ──────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight: 36

                RowLayout {
                    anchors.fill: parent
                    spacing: 14

                    // Bell icon (drawn)
                    Item {
                        width: 20; height: 20
                        Layout.alignment: Qt.AlignVCenter

                        // bell dome
                        Rectangle {
                            x: 4; y: 3
                            width: 12; height: 10; radius: 6
                            color:        "transparent"
                            border.color: Colors.overlay1
                            border.width: 1.5
                            // cut bottom edge — overlap with clapper bar
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                height: 3; color: Colors.base
                            }
                        }
                        // clapper bar
                        Rectangle { x: 3; y: 12; width: 14; height: 2; radius: 1; color: Colors.overlay1 }
                        // handle stub
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 1; width: 4; height: 3; radius: 2; color: Colors.overlay1
                        }
                    }

                    Text {
                        text:             root._notifyLabel()
                        color:            Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 15 }
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root._cycleNotify()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Don't repeat ──────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight: 36

                RowLayout {
                    anchors.fill: parent
                    spacing: 14

                    // Repeat arrows icon (drawn)
                    Item {
                        width: 20; height: 20
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text:  "↻"
                            color: Colors.overlay1
                            font { pixelSize: 17 }
                        }
                    }

                    Text {
                        text:             root._repeatLabel()
                        color:            root.repeatMode === "none" ? Colors.textDim : Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 15 }
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root._cycleRepeat()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Notes ─────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // Notes icon (three lines)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 4

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: 3
                            Rectangle {
                                width: 14; height: 1.5; radius: 1
                                color: Colors.overlay1
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight:   Math.max(36, notesInput.implicitHeight)

                    TextEdit {
                        id: notesInput
                        width:             parent.width
                        color:             Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 15 }
                        selectByMouse:     true
                        selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
                        selectedTextColor: Colors.textPrimary
                        wrapMode:          TextEdit.Wrap
                        onTextChanged:     root.notesText = text
                    }

                    Text {
                        anchors { top: parent.top; left: parent.left }
                        topPadding: 2
                        visible:    notesInput.text === "" && !notesInput.activeFocus
                        text:       "Notes"
                        color:      Colors.textDim
                        font:       notesInput.font
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Video conference ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height:  36
                spacing: 14

                // Video camera icon (drawn)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    // camera body
                    Rectangle {
                        x: 1; y: 5; width: 13; height: 10; radius: 2
                        color: "transparent"; border.color: Colors.overlay1; border.width: 1.5
                    }
                    // lens triangle
                    Rectangle { x: 14; y: 7; width: 6; height: 2; radius: 1; color: Colors.overlay1 }
                    Rectangle { x: 14; y: 11; width: 6; height: 2; radius: 1; color: Colors.overlay1 }
                    Rectangle { x: 18; y: 7; width: 2; height: 6; radius: 1; color: Colors.overlay1 }
                }

                Text {
                    text:             "Video conference"
                    color:            Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Attachment ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height:  36
                spacing: 14

                // Paperclip icon (drawn)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 8; height: 16; radius: 4
                        color:        "transparent"
                        border.color: Colors.overlay1
                        border.width: 1.5
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 2
                        width: 4; height: 10; radius: 2
                        color: Colors.base
                    }
                    // inner clip line
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 6; width: 1.5; height: 10; radius: 1
                        color: Colors.overlay1
                    }
                }

                Text {
                    text:             "Attachment"
                    color:            Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Invitees ──────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height:  36
                spacing: 14

                // Person icon (drawn)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    // head
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 1; width: 8; height: 8; radius: 4
                        color: "transparent"; border.color: Colors.overlay1; border.width: 1.5
                    }
                    // shoulders arc (semi-circle)
                    Rectangle {
                        x: 2; y: 11; width: 16; height: 10; radius: 8
                        color: "transparent"; border.color: Colors.overlay1; border.width: 1.5
                        // clip top half so only bottom arc shows
                        clip: true
                        Rectangle {
                            anchors {
                                top:   parent.top
                                left:  parent.left
                                right: parent.right
                            }
                            height: 5
                            color:  Colors.base
                        }
                    }
                }

                Text {
                    text:             "Invitees"
                    color:            Colors.textDim
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Timezone ──────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height:  36
                spacing: 14

                // Globe icon (circle + lines)
                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16; height: 16; radius: 8
                        color:        "transparent"
                        border.color: Colors.overlay1
                        border.width: 1.5
                    }
                    // horizontal equator
                    Rectangle { x: 2; y: 9; width: 16; height: 1.5; color: Colors.overlay1 }
                    // vertical prime meridian
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 2; width: 1.5; height: 16; color: Colors.overlay1 }
                }

                Text {
                    text:             "(GMT+7) Western Indonesia Time"
                    color:            Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Item { height: 16 }
        }
    }

    // ── Footer: Cancel / Save ─────────────────────────────────────────────────
    Rectangle {
        id: footerRow
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 52
        color:  "transparent"

        // top divider
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Colors.divider
        }

        RowLayout {
            anchors.fill: parent
            spacing:      0

            // Cancel
            Item {
                Layout.fillWidth: true
                height: 52

                Rectangle {
                    anchors.fill: parent
                    color:        cancelMA.containsMouse
                                  ? Colors.withAlpha(Colors.surface0, 0.45) : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Cancel"
                    color: Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                }

                MouseArea {
                    id: cancelMA
                    anchors.fill:  parent
                    hoverEnabled:  true
                    cursorShape:   Qt.PointingHandCursor
                    onClicked:     CalendarState.addEventOpen = false
                }
            }

            Rectangle {
                width: 1; height: 28; color: Colors.divider
                Layout.alignment: Qt.AlignVCenter
            }

            // Save
            Item {
                Layout.fillWidth: true
                height: 52

                readonly property bool _canSave: root.titleText.trim() !== ""

                Rectangle {
                    anchors.fill: parent
                    color:        saveMA.containsMouse && parent._canSave
                                  ? Colors.withAlpha(Colors.surface0, 0.45) : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Save"
                    color: parent._canSave ? Colors.textPrimary : Colors.textDim
                    font { family: Typography.bodyFamily; pixelSize: 15; weight: Font.Bold }
                }

                MouseArea {
                    id: saveMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  parent._canSave ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled:      parent._canSave

                    onClicked: {
                        const dateStr = String(root.startYear) + "-"
                                      + String(root.startMonth + 1).padStart(2, "0") + "-"
                                      + String(root.startDay).padStart(2, "0")
                        const timeStr = root.allDay
                                      ? ""
                                      : root._fmtTime(root.startHour, root.startMinute)
                        CalendarState.addEvent(dateStr, timeStr, root.titleText.trim(), "#4ade80")
                        CalendarState.addEventOpen = false
                    }
                }
            }
        }
    }
}
