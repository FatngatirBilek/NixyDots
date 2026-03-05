import QtQuick
import QtQuick.Layouts
import qs.theme

// TimePicker — compact HH:MM spinner.
//
// Usage:
//   TimePicker {
//     hour:   9
//     minute: 30
//     onTimePicked: function(h, m) { ... }
//   }
//
// • Up/down arrow buttons increment/decrement hour and minute.
// • Mouse wheel also works on each column.
// • hour wraps 0–23, minute wraps 0–59.

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property int hour:   12
    property int minute: 0

    signal timePicked(int hour, int minute)

    // ── Helpers ───────────────────────────────────────────────────────────────
    function _pad(n) { return String(n).padStart(2, '0') }

    function _emit() { root.timePicked(root.hour, root.minute) }

    // ── Size ──────────────────────────────────────────────────────────────────
    implicitWidth:  160
    implicitHeight: 100

    // ── Layout ────────────────────────────────────────────────────────────────
    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        // ── Hour column ───────────────────────────────────────────────────────
        ColumnLayout {
            spacing: 4

            // Up
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 36; height: 26; radius: Spacing.radiusSm
                color: hourUpArea.containsMouse
                       ? Colors.bgHover : Colors.bgElevated
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:  "▲"
                    color: Colors.textMuted
                    font { pixelSize: 10 }
                }

                MouseArea {
                    id: hourUpArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.hour = (root.hour + 1) % 24
                        root._emit()
                    }
                }
            }

            // Value
            Text {
                Layout.alignment: Qt.AlignHCenter
                text:  root._pad(root.hour)
                color: Colors.textPrimary
                font {
                    family:    Typography.monoTextFamily
                    pixelSize: 26
                    weight:    Font.Medium
                }

                // Wheel support
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y > 0) {
                            root.hour = (root.hour + 1) % 24
                        } else {
                            root.hour = (root.hour + 23) % 24
                        }
                        root._emit()
                    }
                }
            }

            // Down
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 36; height: 26; radius: Spacing.radiusSm
                color: hourDownArea.containsMouse
                       ? Colors.bgHover : Colors.bgElevated
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:  "▼"
                    color: Colors.textMuted
                    font { pixelSize: 10 }
                }

                MouseArea {
                    id: hourDownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.hour = (root.hour + 23) % 24
                        root._emit()
                    }
                }
            }
        }

        // Colon separator
        Text {
            text:  ":"
            color: Colors.textSecondary
            font {
                family:    Typography.monoTextFamily
                pixelSize: 28
                weight:    Font.Bold
            }
            Layout.alignment: Qt.AlignVCenter
            // nudge the colon up slightly so it sits between the digits
            bottomPadding: 4
        }

        // ── Minute column ─────────────────────────────────────────────────────
        ColumnLayout {
            spacing: 4

            // Up
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 36; height: 26; radius: Spacing.radiusSm
                color: minUpArea.containsMouse
                       ? Colors.bgHover : Colors.bgElevated
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:  "▲"
                    color: Colors.textMuted
                    font { pixelSize: 10 }
                }

                MouseArea {
                    id: minUpArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.minute = (root.minute + 1) % 60
                        root._emit()
                    }
                }
            }

            // Value
            Text {
                Layout.alignment: Qt.AlignHCenter
                text:  root._pad(root.minute)
                color: Colors.textPrimary
                font {
                    family:    Typography.monoTextFamily
                    pixelSize: 26
                    weight:    Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y > 0) {
                            root.minute = (root.minute + 1) % 60
                        } else {
                            root.minute = (root.minute + 59) % 60
                        }
                        root._emit()
                    }
                }
            }

            // Down
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 36; height: 26; radius: Spacing.radiusSm
                color: minDownArea.containsMouse
                       ? Colors.bgHover : Colors.bgElevated
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:  "▼"
                    color: Colors.textMuted
                    font { pixelSize: 10 }
                }

                MouseArea {
                    id: minDownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.minute = (root.minute + 59) % 60
                        root._emit()
                    }
                }
            }
        }
    }
}
