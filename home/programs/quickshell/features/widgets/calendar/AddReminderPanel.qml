import QtQuick
import QtQuick.Layouts
import qs.theme

// AddReminderPanel — iOS Reminders-style "New reminder" overlay form.
//
// Shown inside an Overlay PanelWindow (shell.qml).
// Opens when CalendarState.addReminderOpen becomes true.
// Saves via CalendarState.addReminder(text, time, place, notifyMins).
//
// Layout (top → bottom):
//   "New reminder"          ☆
//   ──────────────────────────
//   [Title input             ]
//                      ⊙  📷
//   ──────────────────────────
//   📅  Time
//      (inline DatePicker → TimePicker on date pick)
//   ──────────────────────────
//   🔔  Notification  (inline dropdown)
//   ──────────────────────────
//   ⊙  Place
//   ──────────────────────────
//   (spacer)
//   ══════════════════════════
//   Cancel          Save

Rectangle {
    id: root

    // ── Geometry ──────────────────────────────────────────────────────────────
    width:    360
    height:   Math.min(
                  headerSection.height
                  + titleSection.height
                  + rowsSection.implicitHeight
                  + footerRow.height,
                  maxHeight)
    property int maxHeight: 580

    radius: 20
    color:  Colors.withAlpha(Colors.base, 0.97)
    clip:   true

    // ── Form state ────────────────────────────────────────────────────────────
    property string titleText: ""
    property string placeText: ""

    // Time selection
    property bool timeSet:    false
    property int  selYear:    1970
    property int  selMonth:   0
    property int  selDay:     1
    property int  selHour:    9
    property int  selMinute:  0

    // -1 = no notification, 0 = at due time, N = N mins before
    property int  notifyMins: 10

    // "" | "date" | "time"
    property string activePicker: ""

    // whether the notification dropdown is open
    property bool notifyPickerOpen: false

    // ── Notification options ──────────────────────────────────────────────────
    readonly property var _notifyOptions: [
        { label: "No notification", mins: -1   },
        { label: "At due time",     mins: 0    },
        { label: "5 mins before",   mins: 5    },
        { label: "10 mins before",  mins: 10   },
        { label: "15 mins before",  mins: 15   },
        { label: "30 mins before",  mins: 30   },
        { label: "1 hour before",   mins: 60   },
        { label: "2 hours before",  mins: 120  },
        { label: "1 day before",    mins: 1440 }
    ]

    function _notifyLabel() {
        for (var i = 0; i < root._notifyOptions.length; i++) {
            if (root._notifyOptions[i].mins === root.notifyMins)
                return root._notifyOptions[i].label
        }
        if (root.notifyMins < 0)   return "No notification"
        if (root.notifyMins < 60)  return root.notifyMins + " mins before"
        return (root.notifyMins / 60) + " hours before"
    }

    // ── Formatting helpers ────────────────────────────────────────────────────
    readonly property var _dayNames:   ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    readonly property var _monthShort: ["Jan","Feb","Mar","Apr","May","Jun",
                                        "Jul","Aug","Sep","Oct","Nov","Dec"]

    function _fmtTime(h, m) {
        return String(h).padStart(2, "0") + ":" + String(m).padStart(2, "0")
    }

    function _timeLabel() {
        if (!root.timeSet) return ""
        const d = new Date(root.selYear, root.selMonth, root.selDay)
        return _dayNames[d.getDay()] + ", "
             + _monthShort[root.selMonth] + " " + root.selDay
             + "  " + _fmtTime(root.selHour, root.selMinute)
    }

    // ── Reset ─────────────────────────────────────────────────────────────────
    function _reset() {
        root.titleText       = ""
        root.placeText       = ""
        root.timeSet         = false
        root.activePicker    = ""
        root.notifyMins      = 10
        root.notifyPickerOpen = false
        titleInput.text      = ""
        placeInput.text      = ""
        const now     = new Date()
        root.selYear  = now.getFullYear()
        root.selMonth = now.getMonth()
        root.selDay   = now.getDate()
        root.selHour  = (now.getHours() + 1) % 24
        root.selMinute = 0
    }

    // ── React when panel is asked to open ─────────────────────────────────────
    Connections {
        target: CalendarState
        function onAddReminderOpenChanged() {
            if (!CalendarState.addReminderOpen) return
            root._reset()
            Qt.callLater(function() { titleInput.forceActiveFocus() })
        }
    }

    // ── Outer border ring ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill:  parent
        radius:        parent.radius
        color:         "transparent"
        border.color:  Colors.withAlpha(Colors.text, 0.08)
        border.width:  1
        z:             30
    }

    // ── Base click absorber ───────────────────────────────────────────────────
    MouseArea { anchors.fill: parent }

    // ═══════════════════════════════════════════════════════════════════════════
    // HEADER  —  "New reminder" + star
    // ═══════════════════════════════════════════════════════════════════════════
    Item {
        id: headerSection
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 64

        RowLayout {
            anchors {
                fill:         parent
                leftMargin:   20
                rightMargin:  20
                topMargin:    20
            }
            spacing: 10

            Text {
                text:  "New reminder"
                color: Colors.textPrimary
                font {
                    family:    Typography.bodyFamily
                    pixelSize: 20
                    weight:    Font.Bold
                }
                Layout.fillWidth:  true
                Layout.alignment:  Qt.AlignVCenter
            }

            Text {
                text:             "☆"
                color:            Colors.textMuted
                font.pixelSize:   22
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TITLE INPUT  +  check/camera icons
    // ═══════════════════════════════════════════════════════════════════════════
    Item {
        id: titleSection
        anchors { top: headerSection.bottom; left: parent.left; right: parent.right }
        height: 80

        // Left accent cursor bar
        Rectangle {
            x:      20; y: 0
            width:  2; height: 44; radius: 1
            color:  titleInput.activeFocus ? Colors.accent : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        TextInput {
            id: titleInput
            anchors {
                top:         parent.top
                left:        parent.left
                right:       parent.right
                leftMargin:  28
                rightMargin: 20
            }
            height:            44
            verticalAlignment: TextInput.AlignVCenter
            color:             Colors.textPrimary
            font { family: Typography.bodyFamily; pixelSize: 18 }
            selectByMouse:     true
            selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
            selectedTextColor: Colors.textPrimary
            clip:              true
            onTextChanged:     root.titleText = text
        }

        Text {
            anchors { fill: titleInput }
            verticalAlignment: Text.AlignVCenter
            visible:  titleInput.text === "" && !titleInput.activeFocus
            text:     "Title"
            color:    Colors.textDim
            font:     titleInput.font
        }

        // Check + Camera icons
        RowLayout {
            anchors {
                bottom:       parent.bottom
                right:        parent.right
                rightMargin:  20
                bottomMargin: 8
            }
            spacing: 10

            Rectangle {
                width: 28; height: 28; radius: 14
                color:        "transparent"
                border.color: Colors.overlay1
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text:           "✓"
                    color:          Colors.overlay1
                    font.pixelSize: 13
                }
            }

            Item {
                width: 28; height: 28

                Rectangle {
                    anchors.fill:  parent
                    radius:        6
                    color:         "transparent"
                    border.color:  Colors.overlay1
                    border.width:  1.5
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 12; height: 12; radius: 6
                    color:         "transparent"
                    border.color:  Colors.overlay1
                    border.width:  1.5
                }
                Rectangle {
                    anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 5 }
                    width: 3; height: 3; radius: 1.5
                    color: Colors.overlay1
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FORM ROWS  (scrollable)
    // ═══════════════════════════════════════════════════════════════════════════
    Item {
        id: rowsSection
        anchors {
            top:    titleSection.bottom
            left:   parent.left
            right:  parent.right
            bottom: footerRow.top
        }
        implicitHeight: rowsCol.implicitHeight

        Flickable {
            anchors.fill:   parent
            contentHeight:  rowsCol.implicitHeight
            clip:           true
            interactive:    contentHeight > height
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: rowsCol
                width:   rowsSection.width
                spacing: 0

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // ── Time row ──────────────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    implicitHeight:   44

                    RowLayout {
                        anchors.fill: parent
                        spacing:      14

                        Item { width: 20 }

                        // Calendar icon
                        Item {
                            width: 20; height: 20
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                x: 0; y: 2; width: 20; height: 16; radius: 3
                                color:        "transparent"
                                border.color: Colors.overlay1
                                border.width: 1.5

                                Rectangle {
                                    x: 0; y: 6
                                    width: parent.width; height: 1.5
                                    color: Colors.overlay1
                                }
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.left
                                anchors.horizontalCenterOffset: 6
                                y: 0; width: 3; height: 6; radius: 1.5
                                color: Colors.overlay1
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.right
                                anchors.horizontalCenterOffset: -6
                                y: 0; width: 3; height: 6; radius: 1.5
                                color: Colors.overlay1
                            }
                        }

                        Text {
                            text:             root.timeSet ? root._timeLabel() : "Time"
                            color:            root.timeSet ? Colors.textPrimary : Colors.textDim
                            font { family: Typography.bodyFamily; pixelSize: 15 }
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Clear-time button
                        Rectangle {
                            visible:  root.timeSet
                            width: 20; height: 20; radius: 10
                            color:  clearTimeMA.containsMouse
                                    ? Colors.withAlpha(Colors.red, 0.20) : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text:           "✕"
                                color:          Colors.overlay1
                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: clearTimeMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    root.timeSet         = false
                                    root.activePicker    = ""
                                    root.notifyPickerOpen = false
                                }
                            }
                        }

                        Item { width: 20 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.notifyPickerOpen = false
                            root.activePicker =
                                (root.activePicker === "date" || root.activePicker === "time")
                                ? "" : "date"
                        }
                    }
                }

                // ── Inline DatePicker ─────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    visible:          root.activePicker === "date"
                    implicitHeight:   visible ? remDatePick.implicitHeight + 16 : 0
                    clip:             true

                    DatePicker {
                        id: remDatePick
                        anchors {
                            top:         parent.top
                            topMargin:   8
                            left:        parent.left
                            leftMargin:  20
                            right:       parent.right
                            rightMargin: 20
                        }

                        onVisibleChanged: {
                            if (!visible) return
                            viewYear  = root.selYear
                            viewMonth = root.selMonth
                            selYear   = root.selYear
                            selMonth  = root.selMonth
                            selDay    = root.selDay
                        }

                        onDatePicked: function(y, m, d) {
                            root.selYear      = y
                            root.selMonth     = m
                            root.selDay       = d
                            root.timeSet      = true
                            root.activePicker = "time"
                        }
                    }
                }

                // ── Inline TimePicker ─────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    visible:          root.activePicker === "time"
                    implicitHeight:   visible ? remTimePick.implicitHeight + 52 : 0
                    clip:             true

                    TimePicker {
                        id: remTimePick
                        anchors {
                            top:              parent.top
                            topMargin:        8
                            horizontalCenter: parent.horizontalCenter
                        }

                        onVisibleChanged: {
                            if (!visible) return
                            hour   = root.selHour
                            minute = root.selMinute
                        }

                        onTimePicked: function(h, m) {
                            root.selHour   = h
                            root.selMinute = m
                        }
                    }

                    Rectangle {
                        anchors {
                            bottom:       parent.bottom
                            bottomMargin: 4
                            right:        parent.right
                            rightMargin:  20
                        }
                        height: 28; width: 60; radius: 14
                        color: doneTimeMA.containsMouse
                               ? Colors.withAlpha(Colors.accent, 0.25)
                               : Colors.withAlpha(Colors.accent, 0.15)
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text:  "Done"
                            color: Colors.accent
                            font { family: Typography.bodyFamily; pixelSize: 13; weight: Font.Medium }
                        }

                        MouseArea {
                            id: doneTimeMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.activePicker = ""
                        }
                    }
                }

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // ── Notification row ──────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    implicitHeight:   44

                    // Disabled look when no time is set
                    opacity: root.timeSet ? 1.0 : 0.38
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        spacing:      14

                        Item { width: 20 }

                        // Bell icon
                        Item {
                            width: 20; height: 20
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                x: 4; y: 3; width: 12; height: 10; radius: 6
                                color:        "transparent"
                                border.color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1
                                border.width: 1.5

                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                    height: 3
                                    color:  Colors.base
                                }
                            }
                            Rectangle {
                                x: 3; y: 12; width: 14; height: 2; radius: 1
                                color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 1; width: 4; height: 3; radius: 2
                                color: root.notifyMins >= 0 ? Colors.accent : Colors.overlay1
                            }
                        }

                        Text {
                            text:  root._notifyLabel()
                            color: root.notifyMins >= 0 ? Colors.textPrimary : Colors.textDim
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

                        Item { width: 20 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  root.timeSet ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled:      root.timeSet
                        onClicked: {
                            root.activePicker     = ""
                            root.notifyPickerOpen = !root.notifyPickerOpen
                        }
                    }
                }

                // ── Inline notification option list ───────────────────────────
                Item {
                    Layout.fillWidth: true
                    visible:          root.notifyPickerOpen && root.timeSet
                    implicitHeight:   visible ? notifyOptCol.implicitHeight + 8 : 0
                    clip:             true

                    Rectangle {
                        anchors {
                            fill:        parent
                            leftMargin:  12
                            rightMargin: 12
                            topMargin:   4
                            bottomMargin: 4
                        }
                        color:  Colors.withAlpha(Colors.surface0, 0.50)
                        radius: 10
                    }

                    Column {
                        id: notifyOptCol
                        anchors {
                            top:         parent.top
                            left:        parent.left
                            right:       parent.right
                            topMargin:   8
                            leftMargin:  12
                            rightMargin: 12
                        }

                        Repeater {
                            model: root._notifyOptions

                            delegate: Item {
                                required property var  modelData
                                required property int  index

                                width:  parent.width
                                height: 40

                                readonly property bool _selected: root.notifyMins === modelData.mins

                                // Hover / selected highlight
                                Rectangle {
                                    anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                                    radius: 8
                                    color:  _selected
                                            ? Colors.withAlpha(Colors.accent, 0.18)
                                            : (optMA.containsMouse
                                               ? Colors.withAlpha(Colors.surface0, 0.60)
                                               : "transparent")
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }

                                RowLayout {
                                    anchors {
                                        fill:        parent
                                        leftMargin:  12
                                        rightMargin: 12
                                    }
                                    spacing: 10

                                    // Checkmark (only for selected)
                                    Text {
                                        text:           "✓"
                                        color:          Colors.accent
                                        font.pixelSize: 13
                                        visible:        _selected
                                        Layout.preferredWidth: 16
                                    }

                                    // Spacer when not selected
                                    Item {
                                        visible:             !_selected
                                        Layout.preferredWidth: 16
                                        height: 1
                                    }

                                    Text {
                                        text:             modelData.label
                                        color:            _selected ? Colors.accent : Colors.textPrimary
                                        font {
                                            family:    Typography.bodyFamily
                                            pixelSize: 14
                                            weight:    _selected ? Font.Medium : Font.Normal
                                        }
                                        Layout.fillWidth: true
                                    }
                                }

                                // Bottom separator (not on last item)
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                                    height:  1
                                    color:   Colors.withAlpha(Colors.divider, 0.5)
                                    visible: index < root._notifyOptions.length - 1
                                }

                                MouseArea {
                                    id: optMA
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

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // ── Place row ─────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    height:           44
                    spacing:          14

                    Item { width: 20 }

                    // Location pin
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
                            y: 8; width: 2; height: 8; radius: 1
                            color: Colors.overlay1
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 44

                        TextInput {
                            id: placeInput
                            anchors.fill:      parent
                            verticalAlignment: TextInput.AlignVCenter
                            color:             Colors.textPrimary
                            font { family: Typography.bodyFamily; pixelSize: 15 }
                            selectByMouse:     true
                            selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
                            selectedTextColor: Colors.textPrimary
                            clip:              true
                            onTextChanged:     root.placeText = text
                        }

                        Text {
                            anchors.fill:      placeInput
                            verticalAlignment: Text.AlignVCenter
                            visible:           placeInput.text === "" && !placeInput.activeFocus
                            text:              "Place"
                            color:             Colors.textDim
                            font:              placeInput.font
                        }
                    }

                    Item { width: 20 }
                }

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // Fill
                Item { Layout.fillWidth: true; implicitHeight: 24 }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FOOTER  —  Cancel  |  Save
    // ═══════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: footerRow
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 52
        color:  "transparent"

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
                    onClicked:     CalendarState.addReminderOpen = false
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
                    anchors.fill:  parent
                    hoverEnabled:  true
                    cursorShape:   parent._canSave ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled:       parent._canSave

                    onClicked: {
                        const timeStr = root.timeSet
                            ? (String(root.selYear) + "-"
                               + String(root.selMonth + 1).padStart(2, "0") + "-"
                               + String(root.selDay).padStart(2, "0") + "T"
                               + root._fmtTime(root.selHour, root.selMinute))
                            : ""
                        CalendarState.addReminder(
                            root.titleText.trim(),
                            timeStr,
                            root.placeText.trim(),
                            root.notifyMins
                        )
                        CalendarState.addReminderOpen = false
                    }
                }
            }
        }
    }
}
