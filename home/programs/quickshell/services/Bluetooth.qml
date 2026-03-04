pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

// Bluetooth service singleton.
// Wraps Quickshell.Bluetooth (BlueZ D-Bus backend) and exposes a stable
// API used by QuickToggles and BluetoothList in the dashboard.
Singleton {
    id: root

    // ── Adapter ───────────────────────────────────────────────────────────────
    readonly property var adapter: Bluetooth.defaultAdapter

    // True once a default adapter is present.
    readonly property bool ready: adapter !== null && adapter !== undefined

    // Whether the adapter is powered on.
    readonly property bool enabled: ready && adapter.enabled === true

    // Whether the adapter is currently scanning for nearby devices.
    readonly property bool discovering: ready && adapter.discovering === true

    // ── Devices ───────────────────────────────────────────────────────────────
    // All known devices (paired + recently discovered).
    readonly property var devices: {
        if (Bluetooth.devices === null || Bluetooth.devices === undefined) return []
        return Bluetooth.devices.values
    }

    // Convenience: only the currently connected devices.
    readonly property var connectedDevices: {
        var result = []
        var devs = root.devices
        for (var i = 0; i < devs.length; i++) {
            if (devs[i] !== null && devs[i] !== undefined && devs[i].connected === true) {
                result.push(devs[i])
            }
        }
        return result
    }

    // ── State string (for OSD / tooltips) ────────────────────────────────────
    readonly property string statusText: {
        if (!ready) return "No adapter"
        if (!enabled) return "Off"
        if (connectedDevices.length === 1) return connectedDevices[0].name || "Connected"
        if (connectedDevices.length > 1) return connectedDevices.length + " connected"
        if (discovering) return "Scanning…"
        return "On"
    }

    reloadableId: "bluetooth"

    // ── Actions ───────────────────────────────────────────────────────────────

    function toggleBluetooth(): void {
        if (ready) {
            adapter.enabled = !adapter.enabled
        }
    }

    function setBluetooth(enable: bool): void {
        if (ready) {
            adapter.enabled = enable
        }
    }

    function startDiscovery(): void {
        if (ready && enabled) {
            adapter.discovering = true
        }
    }

    function stopDiscovery(): void {
        if (ready && enabled) {
            adapter.discovering = false
        }
    }
}
