import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.features.widgets.calendar
import qs.features.widgets

// RemindersWidget — macOS-style desktop reminders card
//
// Shows a list of reminders read from:
//   ~/.config/quickshell/reminders.json
// Format: [{"id": 1, "text": "...", "done": false}, ...]
//
// Clicking a reminder row toggles its done state (persisted immediately).
// "+" button adds a new reminder via zenity --entry.
// Drag the card to reposition it on the desktop.

Item {
    id: root

    // ── Public configuration (wired from shell.qml / Config.qml) ─────────────
    property int  cardWidth:    440
    property int  cardHeight:   200
    property real cornerRadius: 20

    // unique instance id for central persistence (used by WidgetsState)
    property string instanceId: "reminders"

    property int dragMinX: 0
    property int dragMinY: 0
    property int dragMaxX: 9999
    property int dragMaxY: 9999

    implicitWidth:  cardWidth
    implicitHeight: cardHeight

    Component.onCompleted: {
        // If WidgetsState has a saved position for this instance, restore it.
        Qt.callLater(function() {
            if (typeof WidgetsState !== "undefined" && root.instanceId) {
                var pos = WidgetsState.positions[root.instanceId]
                if (pos && pos.x !== undefined && pos.y !== undefined) {
                    root.x = pos.x
                    root.y = pos.y
                }
            }
        })
    }

    // ── Mirror CalendarState data into this widget ────────────────────────────
    // We read directly from CalendarState so there is a single source of truth.
    readonly property var _reminders: CalendarState.reminders

    // Number of undone (pending) reminders
    readonly property int _undoneCount: {
        var n = 0
        for (var i = 0; i < _reminders.length; i++) {
            if (!_reminders[i].done) n++
        }
        return n
    }

    // ── Delegate toggle / delete to CalendarState ─────────────────────────────
    function _toggleDone(idx) {
        CalendarState.toggleReminder(idx)
    }

    function _deleteReminder(idx) {
        CalendarState.deleteReminder(idx)
    }

    // ── Card ──────────────────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.cornerRadius
        color:  Colors.withAlpha(Colors.crust, 0.92)

        // Drag: left-button on background moves the widget
        MouseArea {
            anchors.fill:    parent
            drag.target:     root
            drag.axis:       Drag.XAndYAxis
            drag.minimumX:   root.dragMinX
            drag.minimumY:   root.dragMinY
            drag.maximumX:   root.dragMaxX
            drag.maximumY:   root.dragMaxY
            acceptedButtons: Qt.LeftButton
            // Allow interactive children to receive their own clicks
            propagateComposedEvents: true
            onClicked: (mouse) => { mouse.accepted = false }

            // When drag ends (mouse released), persist final position to WidgetsState
            onReleased: {
                if (root.instanceId) {
                    try {
                        console.log("RemindersWidget: persisting position for", root.instanceId, root.x, root.y)
                        if (typeof WidgetsState !== "undefined") {
                            if (typeof WidgetsState.setPosition === "function") {
                                WidgetsState.setPosition(root.instanceId, root.x, root.y)
                            } else if (WidgetsState.setPosition) {
                                WidgetsState.setPosition(root.instanceId, root.x, root.y)
                            } else if (typeof WidgetsState.setPositionProp === "function") {
                                WidgetsState.setPositionProp(root.instanceId, root.x, root.y)
                            }
                        }
                        console.log("RemindersWidget: requested position persist for", root.instanceId)
                    } catch(e) {
                        console.warn("RemindersWidget: failed to persist position to WidgetsState", e)
                    }
                }
            }
        }

        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: 20
            spacing: 12

            // ── Header row ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text:  "All reminders"
                    color: Colors.textPrimary
                    font {
                        family:    Typography.bodyFamily
                        pixelSize: 18
                        weight:    Font.Bold
                    }
                    Layout.fillWidth: true
                }

                // "+" add-reminder button
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
                            CalendarState.addReminderOpen = true
                        }
                    }
                }
            }

            // ── List area ─────────────────────────────────────────────────────
            Item {
                Layout.fillWidth:  true
                Layout.fillHeight: true

                // "All done" empty-state text
                Text {
                    anchors.centerIn: parent
                    visible: root._undoneCount === 0
                    text:  "All done"
                    color: Colors.textDim
                    font {
                        family:    Typography.placeholderFamily
                        pixelSize: 14
                        italic:    true
                    }
                }

                // Reminder rows (only shown when there are undone items)
                ColumnLayout {
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    spacing: 2
                    visible: root._undoneCount > 0

                    Repeater {
                        model: root._reminders

                        delegate: Item {
                            required property var modelData
                            required property int index

                            // Collapse completed items — Layout reads preferredHeight, not height
                            readonly property bool _isDone: modelData.done

                            Layout.fillWidth:      true
                            Layout.preferredHeight: _isDone ? 0 : 36
                            Layout.maximumHeight:   _isDone ? 0 : 36
                            visible:               !_isDone
                            clip:                   true

                            // Hover highlight background
                            Rectangle {
                                anchors.fill: parent
                                radius:       Spacing.radiusSm
                                color:        rowHover.containsMouse
                                              ? Colors.withAlpha(Colors.surface0, 0.60)
                                              : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            RowLayout {
                                anchors {
                                    fill:        parent
                                    leftMargin:  4
                                    rightMargin: 4
                                }
                                spacing: 10

                                // Circular checkbox
                                Rectangle {
                                    width:        20
                                    height:       20
                                    radius:       10
                                    color:        "transparent"
                                    border.color: Colors.overlay1
                                    border.width: 1.5
                                }

                                // Reminder text
                                Text {
                                    Layout.fillWidth: true
                                    text:             modelData.text || ""
                                    color:            Colors.textPrimary
                                    font {
                                        family:    Typography.bodyFamily
                                        pixelSize: 13
                                    }
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // Delete button (visible on row hover)
                                Rectangle {
                                    width:   22
                                    height:  22
                                    radius:  11
                                    visible: rowHover.containsMouse
                                    color:   deleteHover.containsMouse
                                             ? Colors.withAlpha(Colors.red, 0.20)
                                             : "transparent"

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text:  "✕"
                                        color: deleteHover.containsMouse
                                               ? Colors.red
                                               : Colors.overlay1
                                        font { pixelSize: 10 }
                                    }

                                    MouseArea {
                                        id: deleteHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked:    root._deleteReminder(index)
                                    }
                                }
                            }

                            // Row click → mark as done
                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    root._toggleDone(index)
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
