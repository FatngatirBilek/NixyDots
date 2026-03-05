import QtQuick
import QtQuick.Layouts
import qs.theme

// EditEventPanel — "Edit Event" overlay form, Google Calendar style.
//
// Shown inside an Overlay PanelWindow (shell.qml).
// Opens when CalendarState.editEventOpen becomes true.
// Pre-populates fields from CalendarState.events[CalendarState.editEventIndex].
// Saves via CalendarState.updateEvent() and closes by setting editEventOpen = false.
// Deletes via CalendarState.deleteEvent() then closes.

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

    property string locationText:  ""
    property string notesText:     ""
    property string selectedColor: "#4ade80"

    // "none" | "daily" | "weekly" | "monthly"
    property string repeatMode: "none"

    // 0 | 5 | 10 | 15 | 30 | 60  (minutes)
    property int notifyMins: 10

    // "" | "startDate" | "startTime" | "endDate" | "endTime"
    property string activePicker: ""

    // Confirm-delete state
    property bool confirmDelete: false

    // ── Color palette ─────────────────────────────────────────────────────────
    readonly property var colorPalette: [
        "#4ade80", "#60a5fa", "#f472b6", "#fb923c",
        "#facc15", "#a78bfa", "#f87171", "#34d399"
    ]
    property bool colorPickerOpen: false

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

    // whether the notification dropdown is open
    property bool notifyPickerOpen: false

    readonly property var _notifyOptions: [
        { label: "No notification",  mins: -1   },
        { label: "At time of event", mins: 0    },
        { label: "5 mins before",    mins: 5    },
        { label: "10 mins before",   mins: 10   },
        { label: "15 mins before",   mins: 15   },
        { label: "30 mins before",   mins: 30   },
        { label: "1 hour before",    mins: 60   },
        { label: "2 hours before",   mins: 120  },
        { label: "1 day before",     mins: 1440 }
    ]

    function _notifyLabel() {
        for (var i = 0; i < root._notifyOptions.length; i++) {
            if (root._notifyOptions[i].mins === root.notifyMins)
                return root._notifyOptions[i].label
        }
        if (root.notifyMins < 0)  return "No notification"
        if (root.notifyMins < 60) return root.notifyMins + " mins before"
        return (root.notifyMins / 60) + " hours before"
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

    // ── Populate from CalendarState.events[editEventIndex] ───────────────────
    function _loadEvent() {
        const idx = CalendarState.editEventIndex
        if (idx < 0 || idx >= CalendarState.events.length) return

        const ev = CalendarState.events[idx]
        root.confirmDelete    = false
        root.colorPickerOpen  = false
        root.activePicker     = ""

        // Title
        root.titleText     = ev.title   || ""
        titleInput.text    = ev.title   || ""

        // Color
        root.selectedColor = ev.color   || "#4ade80"

        // Location
        root.locationText  = ev.location || ""
        locationInput.text = ev.location || ""

        // Notes
        root.notesText     = ev.notes   || ""
        notesInput.text    = ev.notes   || ""

        // Repeat & notify
        root.repeatMode       = ev.repeat     || "none"
        root.notifyMins       = (ev.notifyMins !== undefined) ? ev.notifyMins : 10
        root.notifyPickerOpen = false

        // Start date/time
        const dateStr = ev.date || ""
        if (dateStr.length >= 10) {
            const parts = dateStr.split("-")
            root.startYear  = parseInt(parts[0]) || 1970
            root.startMonth = (parseInt(parts[1]) || 1) - 1
            root.startDay   = parseInt(parts[2])  || 1
        }

        const timeStr = ev.time || ""
        if (timeStr.length >= 5) {
            const tp = timeStr.split(":")
            root.startHour   = parseInt(tp[0]) || 0
            root.startMinute = parseInt(tp[1]) || 0
            root.allDay      = false
        } else {
            root.startHour   = 9
            root.startMinute = 0
            root.allDay      = (ev.time === "" || ev.time === undefined)
        }

        // End date/time
        const endDateStr = ev.endDate || ev.date || ""
        if (endDateStr.length >= 10) {
            const ep = endDateStr.split("-")
            root.endYear  = parseInt(ep[0]) || root.startYear
            root.endMonth = (parseInt(ep[1]) || 1) - 1
            root.endDay   = parseInt(ep[2])  || root.startDay
        } else {
            root.endYear  = root.startYear
            root.endMonth = root.startMonth
            root.endDay   = root.startDay
        }

        const endTimeStr = ev.endTime || ""
        if (endTimeStr.length >= 5) {
            const etp = endTimeStr.split(":")
            root.endHour   = parseInt(etp[0]) || (root.startHour + 1) % 24
            root.endMinute = parseInt(etp[1]) || 0
        } else {
            root.endHour   = (root.startHour + 1) % 24
            root.endMinute = root.startMinute
        }

        Qt.callLater(function() { titleInput.forceActiveFocus() })
    }

    // ── React when the panel is asked to open ─────────────────────────────────
    Connections {
        target: CalendarState
        function onEditEventOpenChanged() {
            if (!CalendarState.editEventOpen) return
            root._loadEvent()
        }
        function onEditEventIndexChanged() {
            if (!CalendarState.editEventOpen) return
            root._loadEvent()
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

    // ── Base click absorber ───────────────────────────────────────────────────
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

                // Color dot — click to open palette
                Rectangle {
                    id: colorDot
                    width:   28
                    height:  28
                    radius:  14
                    color:   root.selectedColor
                    Layout.alignment: Qt.AlignVCenter

                    // ring when picker is open
                    Rectangle {
                        anchors.centerIn: parent
                        width:   32; height: 32; radius: 16
                        color:   "transparent"
                        border.color: Colors.withAlpha(Colors.text, 0.30)
                        border.width: 1.5
                        visible: root.colorPickerOpen
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.colorPickerOpen = !root.colorPickerOpen
                    }
                }
            }

            // ── Inline color picker ───────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                visible:          root.colorPickerOpen
                implicitHeight:   visible ? 44 : 0
                clip:             true

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Repeater {
                        model: root.colorPalette

                        delegate: Rectangle {
                            required property string modelData
                            width:  26; height: 26; radius: 13
                            color:  modelData
                            scale:  root.selectedColor === modelData ? 1.20 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width:  32; height: 32; radius: 16
                                color:  "transparent"
                                border.color: Colors.withAlpha(Colors.text, 0.35)
                                border.width: 1.5
                                visible: root.selectedColor === modelData
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedColor   = modelData
                                    root.colorPickerOpen = false
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 6 }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

            Item { height: 14 }

            // ── All-day toggle ────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                height: 36
                spacing: 14

                Item {
                    width: 20; height: 20
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16; height: 16; radius: 8
                        color:        "transparent"
                        border.color: Colors.overlay1
                        border.width: 1.5

                        Rectangle { x: 6.5; y: 2.5; width: 1.5; height: 5; radius: 1; color: Colors.overlay1 }
                        Rectangle { x: 6.5; y: 7;   width: 4;   height: 1.5; radius: 1; color: Colors.overlay1 }
                    }
                }

                Text {
                    text:             "All day"
                    color:            Colors.textPrimary
                    font { family: Typography.bodyFamily; pixelSize: 15 }
                    Layout.fillWidth: true
                }

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

            // ── Start / End date-time row ─────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

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

                Text {
                    text:             "→"
                    color:            Colors.overlay1
                    font.pixelSize:   14
                    Layout.alignment: Qt.AlignVCenter
                    leftPadding:      8
                    rightPadding:     8
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

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

                    // Bell icon
                    Item {
                        width: 20; height: 20
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            x: 4; y: 3
                            width: 12; height: 10; radius: 6
                            color:        "transparent"
                            border.color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1
                            border.width: 1.5
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                height: 3; color: Colors.base
                            }
                        }
                        Rectangle { x: 3; y: 12; width: 14; height: 2; radius: 1
                            color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1 }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 1; width: 4; height: 3; radius: 2
                            color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1
                        }
                    }

                    Text {
                        text:             root._notifyLabel()
                        color:            root.notifyMins >= 0 ? Colors.textPrimary : Colors.textDim
                        font { family: Typography.bodyFamily; pixelSize: 15 }
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Chevron
                    Text {
                        text:             root.notifyPickerOpen ? "▴" : "▾"
                        color:            Colors.overlay1
                        font.pixelSize:   10
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.activePicker     = ""
                        root.notifyPickerOpen = !root.notifyPickerOpen
                    }
                }
            }

            // ── Inline notification dropdown ──────────────────────────────────
            Item {
                Layout.fillWidth: true
                visible:          root.notifyPickerOpen
                implicitHeight:   visible ? editNotifyOptCol.implicitHeight + 8 : 0
                clip:             true

                Rectangle {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 4; bottomMargin: 4 }
                    color:  Colors.withAlpha(Colors.surface0, 0.50)
                    radius: 10
                }

                Column {
                    id: editNotifyOptCol
                    anchors { top: parent.top; left: parent.left; right: parent.right
                              topMargin: 8; leftMargin: 12; rightMargin: 12 }

                    Repeater {
                        model: root._notifyOptions

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width:  parent.width
                            height: 40

                            readonly property bool _selected: root.notifyMins === modelData.mins

                            Rectangle {
                                anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                                radius: 8
                                color:  _selected
                                        ? Colors.withAlpha(Colors.accent, 0.18)
                                        : (editNotifyOptMA.containsMouse
                                           ? Colors.withAlpha(Colors.surface0, 0.60)
                                           : "transparent")
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                spacing: 10

                                Text {
                                    text:           "✓"
                                    color:          Colors.accent
                                    font.pixelSize: 13
                                    visible:        _selected
                                    Layout.preferredWidth: 16
                                }
                                Item {
                                    visible:              !_selected
                                    Layout.preferredWidth: 16
                                    height: 1
                                }

                                Text {
                                    text:  modelData.label
                                    color: _selected ? Colors.accent : Colors.textPrimary
                                    font {
                                        family:    Typography.bodyFamily
                                        pixelSize: 14
                                        weight:    _selected ? Font.Medium : Font.Normal
                                    }
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right
                                          leftMargin: 16; rightMargin: 16 }
                                height:  1
                                color:   Colors.withAlpha(Colors.divider, 0.5)
                                visible: index < root._notifyOptions.length - 1
                            }

                            MouseArea {
                                id: editNotifyOptMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    root.notifyMins       = modelData.mins
                                    root.notifyPickerOpen = false
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }
            Item { height: 12 }

            // ── Repeat ────────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight: 36

                RowLayout {
                    anchors.fill: parent
                    spacing: 14

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

            Item { height: 16 }
        }
    }

    // ── Footer: Delete | Cancel | Save ────────────────────────────────────────
    Rectangle {
        id: footerRow
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 52
        color:  "transparent"

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Colors.divider
        }

        // ── Confirm-delete banner (replaces normal footer) ────────────────────
        Item {
            anchors.fill: parent
            visible: root.confirmDelete

            Rectangle {
                anchors.fill: parent
                color:        Colors.withAlpha(Colors.red, 0.12)
                radius:       root.radius

                // clip top corners only — bottom follows card shape
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: parent.radius
                    color:  parent.color
                }
            }

            RowLayout {
                anchors.fill:        parent
                anchors.leftMargin:  16
                anchors.rightMargin: 16
                spacing:             12

                Text {
                    text:             "Delete this event?"
                    color:            Colors.red
                    font { family: Typography.bodyFamily; pixelSize: 14 }
                    Layout.fillWidth: true
                }

                // Confirm delete
                Item {
                    width: 72; height: 52

                    Rectangle {
                        anchors.fill: parent
                        color:        confirmDelMA.containsMouse
                                      ? Colors.withAlpha(Colors.red, 0.22) : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "Delete"
                        color: Colors.red
                        font { family: Typography.bodyFamily; pixelSize: 14; weight: Font.Bold }
                    }

                    MouseArea {
                        id: confirmDelMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            CalendarState.deleteEvent(CalendarState.editEventIndex)
                            CalendarState.editEventIndex = -1
                            CalendarState.editEventOpen  = false
                        }
                    }
                }

                Rectangle {
                    width: 1; height: 28; color: Colors.divider
                    Layout.alignment: Qt.AlignVCenter
                }

                // Cancel delete
                Item {
                    width: 64; height: 52

                    Rectangle {
                        anchors.fill: parent
                        color:        cancelDelMA.containsMouse
                                      ? Colors.withAlpha(Colors.surface0, 0.45) : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "Cancel"
                        color: Colors.textPrimary
                        font { family: Typography.bodyFamily; pixelSize: 14 }
                    }

                    MouseArea {
                        id: cancelDelMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.confirmDelete = false
                    }
                }
            }
        }

        // ── Normal footer: Delete icon | Cancel | Save ────────────────────────
        RowLayout {
            anchors.fill: parent
            spacing:      0
            visible:      !root.confirmDelete

            // Trash / Delete button
            Item {
                Layout.preferredWidth: 52
                height: 52

                Rectangle {
                    anchors.fill: parent
                    color:        trashMA.containsMouse
                                  ? Colors.withAlpha(Colors.red, 0.15) : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                // Trash-can icon (drawn)
                Item {
                    anchors.centerIn: parent
                    width: 20; height: 20

                    // lid
                    Rectangle { x: 2; y: 2; width: 16; height: 2; radius: 1; color: trashMA.containsMouse ? Colors.red : Colors.overlay2 }
                    // handle arc on lid
                    Rectangle { x: 7; y: 0; width: 6; height: 3; radius: 1; color: "transparent"; border.color: trashMA.containsMouse ? Colors.red : Colors.overlay2; border.width: 1.5 }
                    // body
                    Rectangle { x: 3; y: 5; width: 14; height: 13; radius: 2; color: "transparent"; border.color: trashMA.containsMouse ? Colors.red : Colors.overlay2; border.width: 1.5 }
                    // lines inside
                    Rectangle { x: 7; y: 8; width: 1.5; height: 7; radius: 1; color: trashMA.containsMouse ? Colors.red : Colors.overlay2 }
                    Rectangle { x: 11.5; y: 8; width: 1.5; height: 7; radius: 1; color: trashMA.containsMouse ? Colors.red : Colors.overlay2 }
                }

                MouseArea {
                    id: trashMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.confirmDelete = true
                }
            }

            Rectangle {
                width: 1; height: 28; color: Colors.divider
                Layout.alignment: Qt.AlignVCenter
            }

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
                    onClicked: {
                        CalendarState.editEventOpen  = false
                        CalendarState.editEventIndex = -1
                    }
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
                        const dateStr = String(root.startYear)
                                      + "-" + String(root.startMonth + 1).padStart(2, "0")
                                      + "-" + String(root.startDay).padStart(2, "0")
                        const timeStr = root.allDay
                                      ? ""
                                      : root._fmtTime(root.startHour, root.startMinute)
                        const endDateStr = String(root.endYear)
                                      + "-" + String(root.endMonth + 1).padStart(2, "0")
                                      + "-" + String(root.endDay).padStart(2, "0")
                        const endTimeStr = root.allDay
                                      ? ""
                                      : root._fmtTime(root.endHour, root.endMinute)

                        CalendarState.updateEvent(
                            CalendarState.editEventIndex,
                            dateStr,
                            timeStr,
                            root.titleText.trim(),
                            root.selectedColor,
                            endDateStr,
                            endTimeStr,
                            root.locationText.trim(),
                            root.notesText.trim(),
                            root.repeatMode,
                            root.notifyMins
                        )

                        CalendarState.editEventOpen  = false
                        CalendarState.editEventIndex = -1
                    }
                }
            }
        }
    }
}
