import QtQuick
import QtQuick.Layouts
import qs.theme

// DatePicker — inline interactive month calendar.
//
// Usage:
//   DatePicker {
//     selectedDate: new Date()
//     onDatePicked: function(year, month, day) { ... }
//   }
//
// • selectedDate controls which day gets the filled-circle highlight.
// • Today gets a subtle accent ring when not selected.
// • Click ‹ / › to navigate months.
// • Clicking a date emits onDatePicked and updates selectedDate.

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property var selectedDate: new Date()

    signal datePicked(int year, int month, int day)

    // ── Derived selected parts ────────────────────────────────────────────────
    property int selYear:  selectedDate.getFullYear()
    property int selMonth: selectedDate.getMonth()   // 0-indexed
    property int selDay:   selectedDate.getDate()

    // ── Viewport: which month is shown (can differ from selection) ────────────
    property int viewYear:  selYear
    property int viewMonth: selMonth

    // ── Calendar math helpers ─────────────────────────────────────────────────
    function monthOffset(year, month) {
        // 0 = Monday … 6 = Sunday  (ISO week)
        return (new Date(year, month, 1).getDay() + 6) % 7
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    readonly property int _offset:      monthOffset(viewYear, viewMonth)
    readonly property int _dayCount:    daysInMonth(viewYear, viewMonth)
    readonly property int _totalCells:  Math.ceil((_offset + _dayCount) / 7) * 7
    readonly property int _rows:        _totalCells / 7

    readonly property var _monthNames: [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]
    readonly property var _dayLabels: ["M","T","W","T","F","S","S"]

    // ── Today's date for ring ─────────────────────────────────────────────────
    readonly property var   _now:        new Date()
    readonly property int   _todayYear:  _now.getFullYear()
    readonly property int   _todayMonth: _now.getMonth()
    readonly property int   _todayDay:   _now.getDate()

    // ── Navigation helpers ────────────────────────────────────────────────────
    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear-- }
        else                 { viewMonth-- }
    }

    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear++ }
        else                  { viewMonth++ }
    }

    // ── Size ──────────────────────────────────────────────────────────────────
    implicitWidth:  280
    implicitHeight: navRow.height + 6 + headerRow.height + 4 + calGrid.implicitHeight

    // ── Month navigation row ──────────────────────────────────────────────────
    RowLayout {
        id: navRow
        anchors { top: parent.top; left: parent.left; right: parent.right }
        spacing: 0

        // ‹ prev
        Rectangle {
            width: 28; height: 28; radius: 14
            color: prevArea.containsMouse
                   ? Colors.withAlpha(Colors.surface1, 0.80) : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text:  "‹"
                color: Colors.textMuted
                font { pixelSize: 18; weight: Font.Light }
            }
            MouseArea {
                id: prevArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.prevMonth()
            }
        }

        // Month label
        Text {
            Layout.fillWidth: true
            text:  root._monthNames[root.viewMonth] + " " + root.viewYear
            color: Colors.textPrimary
            font { family: Typography.bodyFamily; pixelSize: 13; weight: Font.Medium }
            horizontalAlignment: Text.AlignHCenter
        }

        // › next
        Rectangle {
            width: 28; height: 28; radius: 14
            color: nextArea.containsMouse
                   ? Colors.withAlpha(Colors.surface1, 0.80) : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text:  "›"
                color: Colors.textMuted
                font { pixelSize: 18; weight: Font.Light }
            }
            MouseArea {
                id: nextArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.nextMonth()
            }
        }
    }

    Item { id: navSpacer; anchors.top: navRow.bottom; height: 6 }

    // ── Day-of-week header row ────────────────────────────────────────────────
    Row {
        id: headerRow
        anchors { top: navSpacer.bottom; left: parent.left; right: parent.right }

        Repeater {
            model: root._dayLabels

            Text {
                width:  headerRow.width / 7
                text:   modelData
                color:  index === 6 ? Colors.red : Colors.overlay0
                font {
                    family:    Typography.bodyFamily
                    pixelSize: 11
                    weight:    Font.Medium
                }
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Item { id: headerSpacer; anchors.top: headerRow.bottom; height: 4 }

    // ── Date grid ─────────────────────────────────────────────────────────────
    Item {
        id: calGrid
        anchors {
            top:   headerSpacer.bottom
            left:  parent.left
            right: parent.right
        }

        readonly property real cellW: width / 7
        readonly property real cellH: 32

        implicitHeight: root._rows * cellH

        Repeater {
            model: root._totalCells

            delegate: Item {
                x:      (index % 7)           * calGrid.cellW
                y:      Math.floor(index / 7) * calGrid.cellH
                width:  calGrid.cellW
                height: calGrid.cellH

                readonly property int  _d:        index - root._offset + 1
                readonly property bool _valid:    _d >= 1 && _d <= root._dayCount
                readonly property bool _sunday:   (index % 7) === 6
                readonly property bool _selected: _valid
                                                  && _d         === root.selDay
                                                  && root.viewMonth === root.selMonth
                                                  && root.viewYear  === root.selYear
                readonly property bool _isToday:  _valid
                                                  && _d               === root._todayDay
                                                  && root.viewMonth   === root._todayMonth
                                                  && root.viewYear    === root._todayYear

                // Filled accent circle — selected
                Rectangle {
                    visible:         _selected
                    anchors.centerIn: parent
                    width:  Math.min(parent.width, parent.height) - 8
                    height: width
                    radius: width / 2
                    color:  Colors.accent
                }

                // Accent ring — today (when not selected)
                Rectangle {
                    visible:          _isToday && !_selected
                    anchors.centerIn: parent
                    width:  Math.min(parent.width, parent.height) - 8
                    height: width
                    radius: width / 2
                    color:  "transparent"
                    border.color: Colors.accent
                    border.width: 1.5
                }

                // Hover highlight
                Rectangle {
                    visible:          !_selected && _valid && cellHover.containsMouse
                    anchors.centerIn: parent
                    width:  Math.min(parent.width, parent.height) - 8
                    height: width
                    radius: width / 2
                    color:  Colors.withAlpha(Colors.surface1, 0.70)
                }

                // Date number
                Text {
                    anchors.centerIn: parent
                    text:  _valid ? _d : ""
                    color: {
                        if (_selected) return Colors.crust
                        if (_sunday)   return Colors.red
                        return Colors.textPrimary
                    }
                    font {
                        family:    Typography.bodyFamily
                        pixelSize: 13
                        weight:    _selected ? Font.Bold : Font.Normal
                    }
                }

                MouseArea {
                    id: cellHover
                    anchors.fill: parent
                    enabled:      _valid
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor

                    onClicked: {
                        root.selYear  = root.viewYear
                        root.selMonth = root.viewMonth
                        root.selDay   = _d
                        root.selectedDate = new Date(root.viewYear, root.viewMonth, _d)
                        root.datePicked(root.viewYear, root.viewMonth, _d)
                    }
                }
            }
        }
    }
}
