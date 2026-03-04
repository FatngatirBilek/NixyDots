import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.core
import qs.services
import qs.widgets.text
import qs.widgets.icons

// BluetoothList — shows known/nearby Bluetooth devices and lets the user
// connect, disconnect, or pair them.  Embedded in the dashboard via
// QuickToggles when Bluetooth is enabled.
ColumnLayout {
    id: root

    spacing: Spacing.spacingXs

    // ── Section header ────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true

        Label {
            text: "Devices"
            font.pixelSize: Typography.sizeLabel
            font.weight: Typography.weightMedium
            color: Colors.textMuted
            font.letterSpacing: 0.6
        }

        Item { Layout.fillWidth: true }

        // Discovery (scan) button / indicator
        Rectangle {
            implicitWidth: discRow.implicitWidth + Spacing.paddingSm * 2
            implicitHeight: 22
            radius: Spacing.radiusFull
            color: Bluetooth.discovering
                ? Colors.withAlpha(Colors.accent, 0.15)
                : discMa.containsMouse
                    ? Colors.bgHover
                    : Colors.bgElevated

            Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

            Row {
                id: discRow
                anchors.centerIn: parent
                spacing: Spacing.spacingXs

                // Pulsing dot while discovering
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.accent
                    visible: Bluetooth.discovering

                    SequentialAnimation on opacity {
                        running: Bluetooth.discovering
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }

                Label {
                    text: Bluetooth.discovering ? "Scanning…" : "Scan"
                    font.pixelSize: Typography.sizeMicro
                    color: Bluetooth.discovering ? Colors.accent : Colors.textMuted
                }
            }

            MouseArea {
                id: discMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Bluetooth.discovering ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (!Bluetooth.discovering) {
                        Bluetooth.startDiscovery()
                    } else {
                        Bluetooth.stopDiscovery()
                    }
                }
            }
        }
    }

    // ── Device list ───────────────────────────────────────────────────────────
    // Clipped to a max height so the dashboard doesn't grow unboundedly.
    Item {
        Layout.fillWidth: true
        implicitHeight: Math.min(deviceCol.implicitHeight, 220)
        clip: true

        Flickable {
            id: flick
            anchors.fill: parent
            contentHeight: deviceCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            clip: true

            Column {
                id: deviceCol
                width: parent.width
                spacing: Spacing.spacingXs

                Repeater {
                    // Sort: connected first, then paired, then alphabetically.
                    model: {
                        var devs = Bluetooth.devices
                        if (devs === null || devs === undefined || devs.length === 0) return []
                        var copy = devs.slice()
                        copy.sort(function(a, b) {
                            if (a.connected && !b.connected) return -1
                            if (!a.connected && b.connected) return 1
                            if (a.paired && !b.paired) return -1
                            if (!a.paired && b.paired) return 1
                            var na = (a.name || "").toLowerCase()
                            var nb = (b.name || "").toLowerCase()
                            if (na < nb) return -1
                            if (na > nb) return 1
                            return 0
                        })
                        return copy
                    }

                    delegate: Rectangle {
                        id: devItem

                        required property var modelData

                        // Convenience aliases
                        readonly property bool isConnected: modelData.connected === true
                        readonly property bool isPaired:    modelData.paired    === true
                        readonly property bool isConnecting: {
                            // BluetoothDeviceState: 0=Disconnected 1=Connected 2=Disconnecting 3=Connecting
                            var s = modelData.state
                            return s !== null && s !== undefined && (s === 3 || s === 2)
                        }

                        width: deviceCol.width
                        implicitHeight: 44
                        radius: Spacing.radiusMd
                        color: isConnected
                            ? Colors.withAlpha(Colors.accent, devMa.containsMouse ? 0.20 : 0.12)
                            : devMa.containsMouse
                                ? Colors.bgHover
                                : Colors.bgElevated

                        Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

                        // Left accent bar for connected device
                        Rectangle {
                            width: 3
                            height: parent.height - 10
                            radius: 2
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: Colors.accent
                            visible: isConnected
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: isConnected ? 14 : 10
                            anchors.rightMargin: 10
                            spacing: Spacing.spacingSm

                            // Device icon (bluetooth / headphones / phone, etc.)
                            DuotoneIcon {
                                name: {
                                    // Map BlueZ icon names to available Phosphor icon names.
                                    var ic = modelData.icon || ""
                                    if (ic.indexOf("headphones") !== -1 || ic.indexOf("headset") !== -1) return "headphones"
                                    if (ic.indexOf("phone") !== -1)    return "phone"
                                    if (ic.indexOf("keyboard") !== -1) return "keyboard"
                                    if (ic.indexOf("mouse") !== -1)    return "mouse"
                                    if (ic.indexOf("joystick") !== -1 || ic.indexOf("gamepad") !== -1) return "game-controller"
                                    if (ic.indexOf("computer") !== -1 || ic.indexOf("laptop") !== -1)  return "laptop"
                                    if (ic.indexOf("speaker") !== -1)  return "speaker-high"
                                    return "bluetooth"
                                }
                                size: Spacing.iconSm
                                iconState: isConnected ? "active" : "default"
                            }

                            // Device name + sub-label column
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: modelData.name || modelData.deviceName || modelData.address || "Unknown"
                                    font.pixelSize: Typography.sizeLabel
                                    color: isConnected ? Colors.accent : Colors.textPrimary
                                    elide: Text.ElideRight
                                }

                                Label {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: {
                                        if (isConnecting) return "Connecting…"
                                        if (isConnected && modelData.batteryAvailable === true) {
                                            return "Battery: " + Math.round(modelData.battery * 100) + "%"
                                        }
                                        if (isPaired && !isConnected) return "Paired"
                                        return ""
                                    }
                                    font.pixelSize: Typography.sizeMicro
                                    color: Colors.textMuted
                                    elide: Text.ElideRight
                                }
                            }

                            // Action button (Connect / Disconnect)
                            Rectangle {
                                implicitWidth: actionLabel.implicitWidth + Spacing.paddingSm * 2
                                implicitHeight: 22
                                radius: Spacing.radiusFull
                                visible: !isConnecting
                                color: isConnected
                                    ? Colors.withAlpha(Colors.error, actionMa.containsMouse ? 0.25 : 0.15)
                                    : actionMa.containsMouse
                                        ? Colors.withAlpha(Colors.accent, 0.25)
                                        : Colors.withAlpha(Colors.accent, 0.15)

                                Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

                                Label {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: isConnected ? "Disconnect" : (isPaired ? "Connect" : "Pair")
                                    font.pixelSize: Typography.sizeMicro
                                    color: isConnected ? Colors.error : Colors.accent
                                }

                                MouseArea {
                                    id: actionMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (isConnected) {
                                            modelData.disconnect()
                                        } else if (isPaired) {
                                            modelData.connect()
                                        } else {
                                            modelData.pair()
                                        }
                                    }
                                }
                            }

                            // Spinner while connecting / disconnecting
                            Item {
                                implicitWidth: 22
                                implicitHeight: 22
                                visible: isConnecting

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: "transparent"
                                    border.width: 2
                                    border.color: Colors.accent

                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: Colors.accent
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.topMargin: -1
                                    }

                                    RotationAnimation on rotation {
                                        running: isConnecting
                                        loops: Animation.Infinite
                                        from: 0
                                        to: 360
                                        duration: 900
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: devMa
                            anchors.fill: parent
                            hoverEnabled: true
                            // Clicks are handled by the action button above;
                            // this area only provides the hover highlight.
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
        }

        // Scroll fade at the bottom when list overflows
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28
            visible: flick.contentHeight > flick.height
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Colors.panelBg }
            }
        }
    }

    // ── Empty state ───────────────────────────────────────────────────────────
    Label {
        Layout.fillWidth: true
        visible: Bluetooth.devices === null
            || Bluetooth.devices === undefined
            || Bluetooth.devices.length === 0
        text: Bluetooth.discovering
            ? "Scanning for devices…"
            : "No devices found — tap Scan"
        color: Colors.textMuted
        font.pixelSize: Typography.sizeLabel
        horizontalAlignment: Text.AlignHCenter
        topPadding: Spacing.spacingSm
        bottomPadding: Spacing.spacingSm
    }
}
