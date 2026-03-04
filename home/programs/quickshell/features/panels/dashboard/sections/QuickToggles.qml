import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.theme
import qs.core
import qs.services
import qs.widgets.buttons

// QuickToggles — WiFi / Bluetooth / Night / DND toggle buttons.
//
// WiFi:
//   • Click = toggle WiFi on/off via NetworkManager
//   • When WiFi is enabled the network list expands automatically and a scan
//     is started.  The list collapses when WiFi is disabled.
//
// Bluetooth:
//   • Click = toggle the default adapter on/off via BlueZ
//   • When Bluetooth is enabled the device list expands and discovery starts.
//   • Collapses when Bluetooth is disabled.
//
// Night mode:
//   • Click = toggle wlsunset (4000K warm) on/off
//   • State is tracked by checking if wlsunset is running via pgrep
//
// DND:
//   • Click = toggle Notifs.doNotDisturb directly (no external process needed)
//   • State is a plain bool on the Notifs singleton — no swaync dependency
ColumnLayout {
    id: root

    spacing: Spacing.spacingMd

    // ── Runtime state ─────────────────────────────────────────────────────────
    property bool nightEnabled: false

    // ── Night mode: check if wlsunset is already running ─────────────────────
    Process {
        id: nightCheckProc
        command: ["sh", "-c", "pgrep -x wlsunset > /dev/null && echo true || echo false"]
        stdout: SplitParser {
            onRead: function(data) {
                root.nightEnabled = data.trim() === "true"
            }
        }
        Component.onCompleted: running = true
    }

    // ── Night mode ON: launch wlsunset at 4000 K ─────────────────────────────
    // -t = night (low) temperature, -T = day (high) temperature.
    // -T must be strictly greater than -t, so we use 4000/4001.
    // -l 90 sets latitude to 90° (polar) so wlsunset considers it "always night"
    // and holds the display at the low temperature permanently.
    Process {
        id: nightOnProc
        command: ["wlsunset", "-t", "4000", "-T", "4001", "-l", "90", "-L", "0"]
        onStarted: root.nightEnabled = true
    }

    // ── Night mode OFF: kill wlsunset (it auto-restores gamma on exit) ────────
    Process {
        id: nightOffProc
        command: ["pkill", "-x", "wlsunset"]
        onExited: function(code) {
            // pkill exits 0 if it killed something, 1 if nothing found —
            // either way night mode is now off
            root.nightEnabled = false
        }
    }

    // ── Toggle buttons ────────────────────────────────────────────────────────
    GridLayout {
        Layout.fillWidth: true
        columns: 4
        rowSpacing: Spacing.spacingSm
        columnSpacing: Spacing.spacingSm

        // WiFi
        ToggleButton {
            Layout.fillWidth: true
            icon: {
                var ic = Network.icon
                return (ic !== null && ic !== undefined && ic !== "") ? ic : "wifi-high"
            }
            label: "WiFi"
            isOn: Network.wifiEnabled === true
            onToggled: {
                var turningOn = !Network.wifiEnabled
                Dispatcher.dispatch(Actions.toggleWifi())
                if (turningOn) {
                    Qt.callLater(function() {
                        Network.startScan()
                        wifiScanStopTimer.restart()
                    })
                } else {
                    Network.stopScan()
                    wifiScanStopTimer.stop()
                }
            }
        }

        // Bluetooth
        ToggleButton {
            Layout.fillWidth: true
            icon: "bluetooth"
            label: "Bluetooth"
            isOn: Bluetooth.enabled === true
            onToggled: {
                var turningOn = !Bluetooth.enabled
                Bluetooth.toggleBluetooth()
                if (turningOn) {
                    Qt.callLater(function() {
                        Bluetooth.startDiscovery()
                        btDiscoveryStopTimer.restart()
                    })
                } else {
                    Bluetooth.stopDiscovery()
                    btDiscoveryStopTimer.stop()
                }
            }
        }

        // Night mode
        ToggleButton {
            Layout.fillWidth: true
            icon: "moon"
            label: "Night"
            isOn: root.nightEnabled
            enabled: true
            onToggled: {
                if (root.nightEnabled) {
                    nightOffProc.running = true
                } else {
                    nightOnProc.running = true
                }
            }
        }

        // Do Not Disturb — reads/writes Notifs.doNotDisturb directly.
        // No external process (swaync-client) needed; state is always in sync.
        ToggleButton {
            Layout.fillWidth: true
            icon: "bell-slash"
            label: "DND"
            isOn: Notifs.doNotDisturb === true
            enabled: true
            onToggled: {
                Notifs.doNotDisturb = !Notifs.doNotDisturb
            }
        }
    }

    // ── Scan / discovery auto-stop timers ─────────────────────────────────────
    // These ensure the spinning "Scanning…" indicator always clears after a
    // reasonable timeout even if the backend never emits a "done" signal.

    Timer {
        id: wifiScanStopTimer
        interval: 12000   // 12 s — WiFiList also has a 10 s timer; this is a fallback
        repeat: false
        onTriggered: Network.stopScan()
    }

    Timer {
        id: btDiscoveryStopTimer
        interval: 15000   // 15 s
        repeat: false
        onTriggered: Bluetooth.stopDiscovery()
    }

    // ── WiFi network list (expands when WiFi is on) ───────────────────────────
    WiFiList {
        Layout.fillWidth: true
        visible: Network.wifiEnabled === true

        clip: true
        opacity: Network.wifiEnabled === true ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationNormal
                easing.type: Easing.InOutQuad
            }
        }
    }

    // ── Bluetooth device list (expands when Bluetooth is on) ──────────────────
    BluetoothList {
        Layout.fillWidth: true
        visible: Bluetooth.enabled === true

        clip: true
        opacity: Bluetooth.enabled === true ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationNormal
                easing.type: Easing.InOutQuad
            }
        }
    }
}
