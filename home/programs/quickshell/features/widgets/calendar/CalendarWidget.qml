import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.features.widgets.calendar

// CalendarWidget — macOS-style desktop calendar card

//
// Left side: mini month grid (Monday-based, today highlighted, Sundays red)
// Right side: "MON DD" header + today's event list
//
// Events are read from ~/.config/quickshell/calendar-events.json
// Format: [{"date":"YYYY-MM-DD","time":"HH:MM","title":"...","color":"#rrggbb"}, ...]
//
// "+" button opens the native AddEventPanel overlay (via CalendarState.addEventOpen).
// Drag the card anywhere on the desktop (bounds wired from shell.qml).

Item {
    id: root

    // ── Public configuration (wired from shell.qml / Config.qml) ─────────────
    property int  cardWidth:    440
    property int  cardHeight:   278
    property real cornerRadius: 20

    // Unique instance id used by WidgetsState for persisting position/photo
    // Default is "calendar" but shell.qml can override when instantiating.
    property string instanceId: "calendar"

    property int dragMinX: 0
    property int dragMinY: 0
    property int dragMaxX: 9999
    property int dragMaxY: 9999
    // Remember previous z so we can restore after dragging
    property real _prevZ: 0

    implicitWidth:  cardWidth
    implicitHeight: cardHeight

    // If a WidgetsState singleton exists and contains a saved position for
    // this instanceId, restore it on completion.
    // Apply stored position only after WidgetsState has finished loading.
    // This avoids reading a default/empty state when WidgetsState is still
    // initializing (which caused positions to be overwritten).
    function _applyStoredState() {
        if (!root.instanceId) return
        try {
            var pos = null
            if (typeof WidgetsState !== "undefined") {
                if (typeof WidgetsState.getPosition === "function") pos = WidgetsState.getPosition(root.instanceId)
                else if (WidgetsState.getPosition) pos = WidgetsState.getPosition(root.instanceId)
                else if (WidgetsState.positions) pos = WidgetsState.positions[root.instanceId]
            }
            if (pos && pos.x !== undefined && pos.y !== undefined) {
                root.x = pos.x
                root.y = pos.y
                console.log("CalendarWidget: applying stored position", root.instanceId, root.x, root.y)
            }
        } catch(e) {
            console.warn("CalendarWidget: error applying stored position", e)
        }
    }

    Component.onCompleted: {
        // If WidgetsState already loaded, apply immediately; otherwise wait for the
        // loaded signal via Connections below.
        if (typeof WidgetsState !== "undefined" && WidgetsState.loaded === true) {
            Qt.callLater(_applyStoredState)
        } else if (typeof WidgetsState !== "undefined" && WidgetsState.loaded === false) {
            // wait for loaded -> true via Connections (below)
        } else {
            // If WidgetsState not present yet, still try once later (defensive)
            Qt.callLater(_applyStoredState)
        }
    }

    Connections {
        // Defensive target so we don't error when WidgetsState is undefined
        target: typeof WidgetsState !== 'undefined' ? WidgetsState : null
        onLoadedChanged: {
            if (typeof WidgetsState === 'undefined') return
            if (!WidgetsState.loaded) return
            Qt.callLater(_applyStoredState)
        }
    }

    // ── Today's date ──────────────────────────────────────────────────────────
    readonly property var  _today:        new Date()
    readonly property int  _currentDay:   _today.getDate()
    readonly property int  _currentMonth: _today.getMonth()     // 0-indexed
    readonly property int  _currentYear:  _today.getFullYear()

    readonly property var _monthNames: [
        "JAN","FEB","MAR","APR","MAY","JUN",
        "JUL","AUG","SEP","OCT","NOV","DEC"
    ]
    readonly property var _dayLabels: ["M","T","W","T","F","S","S"]

    // ── Calendar math ─────────────────────────────────────────────────────────
    // Returns the Monday-based column index (0=Mon … 6=Sun) of the 1st.
    function _monthOffset(year, month) {
        return (new Date(year, month, 1).getDay() + 6) % 7
    }

    function _daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    readonly property int _offset:      _monthOffset(_currentYear, _currentMonth)
    readonly property int _dayCount:    _daysInMonth(_currentYear, _currentMonth)
    // Round up to full weeks
    readonly property int _totalCells:  Math.ceil((_offset + _dayCount) / 7) * 7
    readonly property int _weekRows:    _totalCells / 7

    // ── Today's date string for event matching ────────────────────────────────
    readonly property string _todayStr: {
        const m = String(_currentMonth + 1).padStart(2, '0')
        const d = String(_currentDay).padStart(2, '0')
        return `${_currentYear}-${m}-${d}`
    }

    // ── Events data — mirror CalendarState (single source of truth) ───────────
    readonly property var _events: CalendarState.events

    readonly property var _todayEvents: {
        return _events.filter(function(e) { return e.date === root._todayStr })
    }

    // ── Card background ───────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.cornerRadius
        color:  Colors.withAlpha(Colors.crust, 0.92)

        // Drag: left-button anywhere on card moves the widget
        MouseArea {
            anchors.fill: parent
            drag.target:  root
            drag.axis:    Drag.XAndYAxis
            drag.minimumX: root.dragMinX
            drag.minimumY: root.dragMinY
            drag.maximumX: root.dragMaxX
            drag.maximumY: root.dragMaxY
            acceptedButtons: Qt.LeftButton

            // Bring widget to front when pressing to avoid other widgets stealing pointer
            onPressed: function(mouse) {
                try {
                    root._prevZ = (typeof root.z !== 'undefined') ? root.z : 0
                    root.z = 10000
                } catch(e) { /* ignore */ }
            }

            // Persist final position when drag ends (if WidgetsState is available)
            onReleased: {
                // restore z-order
                try { root.z = root._prevZ } catch(e) { /* ignore */ }

                try {
                    console.log("CalendarWidget: persisting position for", root.instanceId, root.x, root.y)
                    if (typeof WidgetsState !== "undefined" && root.instanceId) {
                        if (typeof WidgetsState.setPosition === "function") {
                            WidgetsState.setPosition(root.instanceId, root.x, root.y)
                        } else if (WidgetsState.setPosition) {
                            WidgetsState.setPosition(root.instanceId, root.x, root.y)
                        } else if (typeof WidgetsState.setPositionProp === "function") {
                            WidgetsState.setPositionProp(root.instanceId, root.x, root.y)
                        }
                    }
                    console.log("CalendarWidget: requested position persist for", root.instanceId)
                } catch(e) {
                    console.warn("CalendarWidget: failed to persist position to WidgetsState", e)
                }
            }

            // restore z-order if drag/click canceled (e.g., compositor or input grab)
            onCanceled: function() {
                try { root.z = root._prevZ } catch(e) { /* ignore */ }
            }
        }

        // ── Two-column layout ─────────────────────────────────────────────────
        RowLayout {
            anchors.fill:    parent
            anchors.margins: 18
            spacing:         18

            // ── LEFT: mini calendar grid ──────────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: Math.floor(root.cardWidth * 0.56) - 18
                spacing: 0

                // Day-of-week header row  M T W T F S S
                Row {
                    id: headerRow
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: root._dayLabels
                        Text {
                            width: headerRow.width / 7
                            text:  modelData
                            color: index === 6 ? Colors.red
                                              : Colors.overlay0
                            font {
                                family:    Typography.bodyFamily
                                pixelSize: 12
                                weight:    Font.Medium
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Item { height: 4 }

                // Date grid
                Item {
                    id: calGrid
                    Layout.fillWidth:  true
                    Layout.fillHeight: true

                    readonly property real cellW: width  / 7
                    readonly property real cellH: height / Math.max(root._weekRows, 1)

                    Repeater {
                        model: root._totalCells

                        delegate: Item {
                            x:      (index % 7)            * calGrid.cellW
                            y:      Math.floor(index / 7)  * calGrid.cellH
                            width:  calGrid.cellW
                            height: calGrid.cellH

                            readonly property int  _d:        index - root._offset + 1
                            readonly property bool _valid:    _d >= 1 && _d <= root._dayCount
                            readonly property bool _isSunday: (index % 7) === 6
                            readonly property bool _isToday:  _valid && _d === root._currentDay

                            // White rounded-rect highlight for today
                            Rectangle {
                                visible:         _isToday
                                anchors.centerIn: parent
                                width:  Math.min(parent.width, parent.height) - 6
                                height: width
                                radius: width * 0.22
                                color:  "white"
                            }

                            Text {
                                anchors.centerIn: parent
                                text:  _valid ? _d : ""
                                color: {
                                    if (_isToday)  return Colors.crust
                                    if (_isSunday) return Colors.red
                                    return Colors.textPrimary
                                }
                                font {
                                    family:    Typography.bodyFamily
                                    pixelSize: 13
                                    weight:    _isToday ? Font.Bold : Font.Normal
                                }
                            }
                        }
                    }
                }
            }

            // ── RIGHT: date header + events ───────────────────────────────────
            ColumnLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                spacing: 10

                // Top row: "MON DD" + "+" button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: root._monthNames[root._currentMonth] + " " + root._currentDay
                        color: Colors.textPrimary
                        font {
                            family:    Typography.bodyFamily
                            pixelSize: 24
                            weight:    Font.Bold
                        }
                        Layout.fillWidth: true
                    }

                    // "+" add event button
                    Rectangle {
                        width:  30
                        height: 30
                        radius: 15
                        color:  addBtnHover.containsMouse
                                ? Colors.bgHover
                                : Colors.bgElevated

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text:  "+"
                            color: Colors.textMuted
                            font { pixelSize: 20; weight: Font.Light }
                        }

                        MouseArea {
                            id: addBtnHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor

                            onClicked: {
                                CalendarState.addEventDefaultDate = root._todayStr
                                CalendarState.addEventOpen = true
                            }
                        }
                    }
                }

                // Event list
                ColumnLayout {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    spacing: 4

                    Repeater {
                        model: root._todayEvents

                        delegate: Item {
                            required property var  modelData
                            required property int  index
                            Layout.fillWidth: true
                            implicitHeight:   eventRow.implicitHeight + 4

                            // Hover background
                            Rectangle {
                                anchors {
                                    fill:         parent
                                    leftMargin:   -4
                                    rightMargin:  -4
                                    topMargin:    2
                                    bottomMargin: 2
                                }
                                radius: 6
                                color:  eventHoverMA.containsMouse
                                        ? Colors.withAlpha(Colors.surface0, 0.55) : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            RowLayout {
                                id: eventRow
                                anchors {
                                    left:  parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: 8

                                // Colour indicator bar
                                Rectangle {
                                    width:  4
                                    height: 34
                                    radius: 2
                                    color:  modelData.color || Colors.green
                                }

                                // Time + title
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text:  modelData.time || ""
                                            color: Colors.textPrimary
                                            font {
                                                family:    Typography.bodyFamily
                                                pixelSize: 14
                                                weight:    Font.DemiBold
                                            }
                                        }

                                        Text {
                                            text:  modelData.title || ""
                                            color: Colors.textSecondary
                                            font {
                                                family:    Typography.bodyFamily
                                                pixelSize: 13
                                            }
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                // Edit pencil icon (visible on hover)
                                Item {
                                    width:  20
                                    height: 20
                                    opacity: eventHoverMA.containsMouse ? 1.0 : 0.0
                                    Layout.alignment: Qt.AlignVCenter

                                    Behavior on opacity {
                                        NumberAnimation { duration: 120 }
                                    }

                                    // pencil body
                                    Rectangle {
                                        x: 7; y: 2
                                        width: 6; height: 12; radius: 1
                                        rotation: -45
                                        transformOrigin: Item.Center
                                        color: "transparent"
                                        border.color: Colors.overlay2
                                        border.width: 1.5
                                    }
                                    // pencil tip
                                    Rectangle {
                                        x: 3; y: 14
                                        width: 4; height: 4; radius: 1
                                        rotation: -45
                                        transformOrigin: Item.Center
                                        color: Colors.overlay2
                                    }
                                }
                            }

                            // Click handler — find real index in CalendarState.events
                            MouseArea {
                                id: eventHoverMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor

                                onClicked: {
                                    // Find the index in the full events array
                                    // (not the filtered todayEvents array)
                                    const ev   = modelData
                                    const all  = CalendarState.events
                                    let realIdx = -1
                                    for (let i = 0; i < all.length; i++) {
                                        if (all[i].date  === ev.date &&
                                            all[i].time  === ev.time &&
                                            all[i].title === ev.title) {
                                            realIdx = i
                                            break
                                        }
                                    }
                                    if (realIdx >= 0) {
                                        CalendarState.editEventIndex = realIdx
                                        CalendarState.editEventOpen  = true
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Item {
                        visible:         root._todayEvents.length === 0
                        Layout.fillWidth:  true
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            text:  "No events today. Enjoy Your Day :)"
                            color: Colors.textDim
                            font {
                                family:    Typography.placeholderFamily
                                pixelSize: 12
                                italic:    true
                            }
                        }
                    }
                }
            }
        }

        // Subtle border on top of everything
        Rectangle {
            anchors.fill: parent
            radius:       root.cornerRadius
            color:        "transparent"
            border.color: Colors.withAlpha(Colors.text, 0.08)
            border.width: 1
            z: 20
        }
    }

    // ── Drop-shadow layers behind card ────────────────────────────────────────
    Rectangle {
        anchors { fill: card; margins: -1 }
        radius:       root.cornerRadius + 1
        color:        "transparent"
        border.color: Colors.withAlpha(Colors.crust, 0.55)
        border.width: 1
        z: -1
    }
    Rectangle {
        anchors { fill: card; margins: -4 }
        radius:       root.cornerRadius + 4
        color:        "transparent"
        border.color: Colors.withAlpha(Colors.crust, 0.25)
        border.width: 2
        z: -2
    }
}
