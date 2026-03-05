import QtQuick
import QtQuick.Layouts
import qs.theme

// AddReminderPanel — iOS Reminders-style "New reminder" overlay form.
//
// Shown inside an Overlay PanelWindow (shell.qml).
// Opens when CalendarState.addReminderOpen becomes true.
// Saves via CalendarState.addReminder(text, time, place) and closes by
// setting addReminderOpen = false.
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
//   ⊙  Place
//   ──────────────────────────
//   🔔  My reminders
//   ──────────────────────────
//   (spacer)
//   ══════════════════════════
//   Cancel          Save

Rectangle {
    id: root

    // ── Geometry ──────────────────────────────────────────────────────────────
    width:          360
    // Height: header + title area + rows + footer; capped at maxHeight
    height:         Math.min(
                        headerSection.height
                        + titleSection.height
                        + rowsSection.implicitHeight
                        + footerRow.height,
                        maxHeight)
    property int maxHeight: 520

    radius: 20
    color:  Colors.withAlpha(Colors.base, 0.97)
    clip:   true

    // ── Form state ────────────────────────────────────────────────────────────
    property string titleText:  ""
    property string placeText:  ""

    // Time selection
    property bool   timeSet:    false
    property int    selYear:    1970
    property int    selMonth:   0
    property int    selDay:     1
    property int    selHour:    9
    property int    selMinute:  0

    // "" | "date" | "time"
    property string activePicker: ""

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
        root.titleText    = ""
        root.placeText    = ""
        root.timeSet      = false
        root.activePicker = ""
        titleInput.text   = ""
        placeInput.text   = ""
        const now      = new Date()
        root.selYear   = now.getFullYear()
        root.selMonth  = now.getMonth()
        root.selDay    = now.getDate()
        root.selHour   = (now.getHours() + 1) % 24
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

    // ── Base click absorber (prevents clicks escaping through empty gaps) ──────
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
                fill:        parent
                leftMargin:  20
                rightMargin: 20
                topMargin:   20
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
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            // Star icon
            Text {
                text:              "☆"
                color:             Colors.textMuted
                font.pixelSize:    22
                Layout.alignment:  Qt.AlignVCenter
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

        // Left accent bar (cursor-like) when focused
        Rectangle {
            x:       20
            y:       0
            width:   2
            height:  44
            radius:  1
            color:   titleInput.activeFocus ? Colors.accent : "transparent"
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
            height: 44
            verticalAlignment: TextInput.AlignVCenter
            color:             Colors.textPrimary
            font {
                family:    Typography.bodyFamily
                pixelSize: 18
            }
            selectByMouse:     true
            selectionColor:    Colors.withAlpha(Colors.accent, 0.35)
            selectedTextColor: Colors.textPrimary
            clip:              true
            onTextChanged:     root.titleText = text
        }

        Text {
            anchors {
                top:        titleInput.top
                left:       titleInput.left
                right:      titleInput.right
                bottom:     titleInput.bottom
            }
            verticalAlignment: Text.AlignVCenter
            visible:  titleInput.text === "" && !titleInput.activeFocus
            text:     "Title"
            color:    Colors.textDim
            font:     titleInput.font
        }

        // Check + Camera icons (bottom-right of the title area)
        RowLayout {
            anchors {
                bottom:      parent.bottom
                right:       parent.right
                rightMargin: 20
                bottomMargin: 8
            }
            spacing: 10

            // Checkmark circle
            Rectangle {
                width: 28; height: 28; radius: 14
                color:        "transparent"
                border.color: Colors.overlay1
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text:          "✓"
                    color:         Colors.overlay1
                    font.pixelSize: 13
                }
            }

            // Camera (rounded rect + inner circle)
            Item {
                width: 28; height: 28

                Rectangle {
                    anchors.fill: parent
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
                // viewfinder dot
                Rectangle {
                    anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 5 }
                    width: 3; height: 3; radius: 1.5
                    color: Colors.overlay1
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FORM ROWS  (scrollable if needed)
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

                        Item { width: 20 }   // left indent

                        // Calendar icon (drawn)
                        Item {
                            width: 20; height: 20
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                x: 0; y: 2; width: 20; height: 16; radius: 3
                                color:        "transparent"
                                border.color: Colors.overlay1
                                border.width: 1.5

                                // horizontal line below header
                                Rectangle {
                                    x: 0; y: 6
                                    width: parent.width; height: 1.5
                                    color: Colors.overlay1
                                }
                            }
                            // left ring binder
                            Rectangle {
                                anchors.horizontalCenter: parent.left
                                anchors.horizontalCenterOffset: 6
                                y: 0; width: 3; height: 6; radius: 1.5
                                color: Colors.overlay1
                            }
                            // right ring binder
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

                        // Clear-time button (shown only when time is set)
                        Rectangle {
                            visible:  root.timeSet
                            width: 20; height: 20; radius: 10
                            color:    clearTimeMA.containsMouse
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
                                    root.timeSet      = false
                                    root.activePicker = ""
                                }
                            }
                        }

                        Item { width: 20 }   // right indent
                    }

                    // Full-row tap area — anchored to parent Item (valid, not inside layout)
                    MouseArea {
                        anchors.fill:  parent
                        cursorShape:   Qt.PointingHandCursor
                        onClicked: {
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
                            top:              parent.top
                            topMargin:        8
                            left:             parent.left
                            leftMargin:       20
                            right:            parent.right
                            rightMargin:      20
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
                    implicitHeight:   visible ? remTimePick.implicitHeight + 16 : 0
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

                    // "Done" button to close the time picker
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

                // ── Place row ─────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    height:           44
                    spacing:          14

                    Item { width: 20 }   // left indent

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

                    Item { width: 20 }   // right indent
                }

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // ── "My reminders" list row ───────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    height:           44
                    spacing:          14

                    Item { width: 20 }   // left indent

                    // Purple bell circle
                    Rectangle {
                        width:   28
                        height:  28
                        radius:  14
                        color:   Colors.withAlpha("#818cf8", 0.18)
                        Layout.alignment: Qt.AlignVCenter

                        // Bell icon (drawn in purple tones)
                        Item {
                            anchors.centerIn: parent
                            width: 16; height: 16

                            // dome
                            Rectangle {
                                x: 2; y: 2; width: 12; height: 9; radius: 6
                                color:        "transparent"
                                border.color: "#818cf8"
                                border.width: 1.5
                                // cover the bottom gap of the arc
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                    height: 3; color: Colors.withAlpha("#818cf8", 0.18)
                                }
                            }
                            // clapper bar
                            Rectangle { x: 1; y: 10; width: 14; height: 2; radius: 1; color: "#818cf8" }
                            // handle stub
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 0; width: 4; height: 3; radius: 2; color: "#818cf8"
                            }
                        }
                    }

                    Text {
                        text:             "My reminders"
                        color:            Colors.textPrimary
                        font {
                            family:    Typography.bodyFamily
                            pixelSize: 15
                            weight:    Font.Medium
                        }
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { width: 20 }   // right indent
                }

                // ── Divider ───────────────────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

                // Fill remaining space
                Item { Layout.fillWidth: true; implicitHeight: 40 }
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
                    onClicked:     CalendarState.addReminderOpen = false
                }
            }

            // Vertical separator
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
                            root.placeText.trim()
                        )
                        CalendarState.addReminderOpen = false
                    }
                }
            }
        }
    }
}
