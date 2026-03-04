import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Quickshell
import Quickshell.Io
import Quickshell.Networking as QSNet
import qs.theme
import qs.core
import qs.services
import qs.widgets.text
import qs.widgets.icons
import qs.widgets.inputs

// WiFiList — scrollable list of available networks with connect / disconnect.
// For secured networks that are not yet saved, an inline password prompt
// appears so the user can enter credentials without leaving the panel.
// Connection is performed via `nmcli device wifi connect <ssid> password <pwd>`.
ColumnLayout {
    id: root

    spacing: Spacing.spacingXs

    // ── Auto-start scan when panel becomes visible ────────────────────────────
    onVisibleChanged: {
        if (visible) {
            Network.startScan()
            scanStopTimer.restart()
        }
    }

    // ── State ─────────────────────────────────────────────────────────────────
    property var    pendingNetwork:  null
    property string pendingPassword: ""
    property string statusMessage:   ""
    property bool   connecting:      false

    // ── Scan auto-stop: stop scanning after 10 s so the indicator clears ──────
    Timer {
        id: scanStopTimer
        interval: 10000
        repeat: false
        onTriggered: Network.stopScan()
    }

    // ── nmcli connect process ─────────────────────────────────────────────────
    Process {
        id: connectProc
        command: []
        stdout: SplitParser {
            onRead: function(data) {
                var line = data.trim()
                if (line !== "") root.statusMessage = line
            }
        }
        stderr: SplitParser {
            onRead: function(data) {
                var line = data.trim()
                if (line !== "") root.statusMessage = line
            }
        }
        onExited: function(exitCode) {
            root.connecting = false
            if (exitCode === 0) {
                root.pendingNetwork  = null
                root.pendingPassword = ""
                root.statusMessage   = ""
            }
            // On failure keep the dialog open so the user can retry.
        }
    }

    function connectWithPassword(network, password) {
        root.connecting    = true
        root.statusMessage = "Connecting…"
        connectProc.command = [
            "nmcli", "device", "wifi", "connect",
            network.name,
            "password", password
        ]
        connectProc.running = true
    }

    function connectDirect(network) {
        root.statusMessage = "Connecting…"
        network.connect()
        statusClearTimer.restart()
    }

    Timer {
        id: statusClearTimer
        interval: 3000
        repeat: false
        onTriggered: root.statusMessage = ""
    }

    // ── Context menu (right-click: Disconnect / Forget) ───────────────────────
    QQC2.Menu {
        id: contextMenu

        property var network: null

        background: Rectangle {
            implicitWidth: 150
            radius: Spacing.radiusMd
            color: Colors.bgElevated
            border.width: 1
            border.color: Colors.withAlpha(Colors.textMuted, 0.18)
        }

        // Disconnect — only when currently connected
        QQC2.MenuItem {
            visible: contextMenu.network !== null && contextMenu.network.connected === true
            height: visible ? implicitHeight : 0
            text: "Disconnect"
            contentItem: Label {
                leftPadding: Spacing.paddingSm
                text: parent.text
                font.pixelSize: Typography.sizeLabel
                color: Colors.error
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: Spacing.radiusSm
                color: parent.hovered
                    ? Colors.withAlpha(Colors.error, 0.15)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }
            }
            onTriggered: {
                var net = contextMenu.network
                if (net) {
                    net.disconnect()
                    root.statusMessage = ""
                }
                contextMenu.network = null
            }
        }

        // Forget — only for saved (known) networks
        QQC2.MenuItem {
            visible: contextMenu.network !== null && contextMenu.network.known === true
            height: visible ? implicitHeight : 0
            text: "Forget"
            contentItem: Label {
                leftPadding: Spacing.paddingSm
                text: parent.text
                font.pixelSize: Typography.sizeLabel
                color: Colors.textPrimary
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: Spacing.radiusSm
                color: parent.hovered
                    ? Colors.withAlpha(Colors.textMuted, 0.15)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }
            }
            onTriggered: {
                var net = contextMenu.network
                if (net) {
                    // WifiNetwork has a built-in forget() that removes the
                    // saved NetworkManager connection profile — no nmcli needed.
                    net.forget()
                    root.statusMessage = "Network forgotten."
                    statusClearTimer.restart()
                }
                contextMenu.network = null
            }
        }
    }

    // ── Section header ────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true

        Label {
            text: "Networks"
            font.pixelSize: Typography.sizeLabel
            font.weight: Typography.weightMedium
            color: Colors.textMuted
            font.letterSpacing: 0.6
        }

        Item { Layout.fillWidth: true }

        // Scan pill
        Rectangle {
            implicitWidth:  scanRow.implicitWidth + Spacing.paddingSm * 2
            implicitHeight: 22
            radius: Spacing.radiusFull
            color: Network.scanning
                ? Colors.withAlpha(Colors.accent, 0.15)
                : scanMa.containsMouse ? Colors.bgHover : Colors.bgElevated

            Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

            Row {
                id: scanRow
                anchors.centerIn: parent
                spacing: Spacing.spacingXs

                Rectangle {
                    width: 6; height: 6; radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.accent
                    visible: Network.scanning
                    SequentialAnimation on opacity {
                        running: Network.scanning; loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }

                Label {
                    text: Network.scanning ? "Scanning…" : "Scan"
                    font.pixelSize: Typography.sizeMicro
                    color: Network.scanning ? Colors.accent : Colors.textMuted
                }
            }

            MouseArea {
                id: scanMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Network.scanning ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (!Network.scanning) {
                        Network.startScan()
                        scanStopTimer.restart()
                    }
                }
            }
        }
    }

    // ── Active connection banner ──────────────────────────────────────────────
    // Always shows the currently connected network at the top, even before
    // the first scan result arrives.  This fixes the "connected network not
    // shown" problem that occurred when the scan list was still empty.
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: activeBanner.implicitHeight + Spacing.spacingXs * 2
        radius: Spacing.radiusMd
        visible: Network.activeNetwork !== null && Network.activeNetwork !== undefined
        color: Colors.withAlpha(Colors.accent, activeBannerMa.containsMouse ? 0.20 : 0.12)
        Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

        // Accent bar on left edge
        Rectangle {
            width: 3
            height: parent.height - 10
            radius: 2
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.accent
        }

        RowLayout {
            id: activeBanner
            anchors {
                left: parent.left; leftMargin: 14
                right: parent.right; rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: Spacing.spacingSm
            height: 40

            DuotoneIcon {
                Layout.alignment: Qt.AlignVCenter
                name: {
                    var s = Network.strength
                    if (s < 0.30) return "wifi-low"
                    if (s < 0.60) return "wifi-medium"
                    return "wifi-high"
                }
                size: Spacing.iconSm
                iconState: "active"
            }

            Label {
                Layout.fillWidth: true
                text: Network.ssid || "(connected)"
                font.pixelSize: Typography.sizeLabel
                color: Colors.accent
                elide: Text.ElideRight
            }

            Label {
                font.pixelSize: Typography.sizeMicro
                color: Colors.accent
                text: "Connected"
            }
        }

        MouseArea {
            id: activeBannerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    var net = Network.activeNetwork
                    if (net) {
                        contextMenu.network = net
                        contextMenu.popup()
                    }
                } else {
                    // Left-click on the banner disconnects
                    var net = Network.activeNetwork
                    if (net) net.disconnect()
                }
            }
        }
    }

    // ── Inline password dialog ────────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: pwCol.implicitHeight + Spacing.paddingMd * 2
        radius: Spacing.radiusMd
        visible: root.pendingNetwork !== null
        color: Colors.withAlpha(Colors.accent, 0.08)
        border.width: 1
        border.color: Colors.withAlpha(Colors.accent, 0.3)

        ColumnLayout {
            id: pwCol
            anchors {
                left:   parent.left;  leftMargin:  Spacing.paddingMd
                right:  parent.right; rightMargin: Spacing.paddingMd
                top:    parent.top;   topMargin:   Spacing.paddingMd
            }
            spacing: Spacing.spacingSm

            // Network name row
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.spacingSm

                DuotoneIcon {
                    name: "lock"
                    size: Spacing.iconSm
                    iconState: "active"
                }

                Label {
                    Layout.fillWidth: true
                    text: root.pendingNetwork ? (root.pendingNetwork.name || "Network") : ""
                    font.pixelSize: Typography.sizeLabel
                    font.weight: Typography.weightMedium
                    color: Colors.accent
                    elide: Text.ElideRight
                }

                // Cancel button
                Rectangle {
                    implicitWidth:  cancelLabel.implicitWidth + Spacing.paddingSm * 2
                    implicitHeight: 22
                    radius: Spacing.radiusFull
                    color: cancelMa.containsMouse
                        ? Colors.withAlpha(Colors.error, 0.25)
                        : Colors.withAlpha(Colors.error, 0.12)
                    Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

                    Label {
                        id: cancelLabel
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: Typography.sizeMicro
                        color: Colors.error
                    }

                    MouseArea {
                        id: cancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.pendingNetwork  = null
                            root.pendingPassword = ""
                            root.statusMessage   = ""
                            root.connecting      = false
                        }
                    }
                }
            }

            // Password input row
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.spacingSm

                TextField {
                    id: pwField
                    Layout.fillWidth: true
                    placeholderText: "Password"
                    Component.onCompleted: {
                        for (var i = 0; i < children.length; i++) {
                            if (children[i].hasOwnProperty("echoMode")) {
                                children[i].echoMode = TextInput.Password
                                break
                            }
                        }
                    }
                    onInputTextChanged: function(t) { root.pendingPassword = t }
                    onInputAccepted: {
                        if (!root.connecting && root.pendingPassword.length > 0)
                            root.connectWithPassword(root.pendingNetwork, root.pendingPassword)
                    }
                }

                // Connect button
                Rectangle {
                    implicitWidth:  connectBtnLabel.implicitWidth + Spacing.paddingSm * 2
                    implicitHeight: 32
                    radius: Spacing.radiusSm
                    enabled: root.pendingPassword.length > 0 && !root.connecting
                    opacity: enabled ? 1.0 : 0.5
                    color: connectBtnMa.containsMouse
                        ? Colors.withAlpha(Colors.accent, 0.35)
                        : Colors.withAlpha(Colors.accent, 0.22)
                    Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

                    Label {
                        id: connectBtnLabel
                        anchors.centerIn: parent
                        text: root.connecting ? "…" : "Connect"
                        font.pixelSize: Typography.sizeMicro
                        font.weight: Typography.weightMedium
                        color: Colors.accent
                    }

                    MouseArea {
                        id: connectBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.connecting && root.pendingPassword.length > 0)
                                root.connectWithPassword(root.pendingNetwork, root.pendingPassword)
                        }
                    }
                }
            }

            // Status / error message
            Label {
                Layout.fillWidth: true
                visible: root.statusMessage !== ""
                text: root.statusMessage
                font.pixelSize: Typography.sizeMicro
                color: root.statusMessage.toLowerCase().indexOf("error") !== -1
                    || root.statusMessage.toLowerCase().indexOf("fail")  !== -1
                    ? Colors.error
                    : Colors.textMuted
                wrapMode: Text.WordWrap
            }
        }
    }

    // ── Network list ──────────────────────────────────────────────────────────
    Item {
        Layout.fillWidth: true
        implicitHeight: Math.min(networkCol.implicitHeight, 220)
        clip: true

        Flickable {
            id: flick
            anchors.fill: parent
            contentHeight: networkCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            clip: true

            Column {
                id: networkCol
                width: parent.width
                spacing: Spacing.spacingXs

                Repeater {
                    // Sort: connected first, then known (saved), then by signal.
                    // Filter out the currently connected network since it is
                    // already displayed in the banner above.
                    model: {
                        var nets = Network.networks
                        if (!nets || nets.length === 0) return []
                        var activeSSID = (Network.activeNetwork !== null
                                         && Network.activeNetwork !== undefined)
                                        ? Network.activeNetwork.name : null
                        var copy = nets.slice().filter(function(n) {
                            // hide the already-shown active network
                            return !n.connected
                        })
                        copy.sort(function(a, b) {
                            // saved first
                            if (a.known && !b.known) return -1
                            if (!a.known && b.known) return 1
                            // then by signal strength descending
                            var sa = (a.signalStrength != null) ? a.signalStrength : 0
                            var sb = (b.signalStrength != null) ? b.signalStrength : 0
                            return sb - sa
                        })
                        return copy
                    }

                    delegate: Rectangle {
                        id: netItem
                        required property var modelData

                        // ── Security check ────────────────────────────────────
                        // WifiSecurityType enum (from Quickshell.Networking):
                        //   Open    = open network, no password needed
                        //   Owe     = Opportunistic Wireless Encryption, no password
                        //   Unknown = we don't know; treat as open to avoid false prompts
                        // Everything else (WpaPsk, Wpa2Psk, Sae, …) requires a password.
                        readonly property bool isSecured: {
                            var sec = modelData.security
                            if (sec === null || sec === undefined) return false
                            return sec !== QSNet.WifiSecurityType.Open
                                && sec !== QSNet.WifiSecurityType.Owe
                                && sec !== QSNet.WifiSecurityType.Unknown
                        }

                        width: networkCol.width
                        implicitHeight: 40
                        radius: Spacing.radiusMd
                        color: netMa.containsMouse ? Colors.bgHover : Colors.bgElevated
                        Behavior on color { ColorAnimation { duration: Motion.hoverDuration } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin:  10
                            anchors.rightMargin: 10
                            spacing: Spacing.spacingSm

                            DuotoneIcon {
                                Layout.alignment: Qt.AlignVCenter
                                name: {
                                    var s = modelData.signalStrength != null
                                            ? modelData.signalStrength : 0
                                    if (s < 0.30) return "wifi-low"
                                    if (s < 0.60) return "wifi-medium"
                                    return "wifi-high"
                                }
                                size: Spacing.iconSm
                                iconState: "default"
                            }

                            // SSID
                            Label {
                                Layout.fillWidth: true
                                text: modelData.name || "(hidden)"
                                font.pixelSize: Typography.sizeLabel
                                color: Colors.textPrimary
                                elide: Text.ElideRight
                            }

                            // Lock icon for secured networks
                            DuotoneIcon {
                                Layout.alignment: Qt.AlignVCenter
                                name: "lock"
                                size: Spacing.iconXs
                                iconState: "default"
                                visible: isSecured
                            }

                            // State chip (Saved / connecting indicator)
                            Label {
                                font.pixelSize: Typography.sizeMicro
                                color: Colors.textMuted
                                text: {
                                    if (modelData.stateChanging) return "…"
                                    if (modelData.known)         return "Saved"
                                    return ""
                                }
                            }
                        }

                        MouseArea {
                            id: netMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: function(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    var hasDisconnect = modelData.connected === true
                                    var hasForget     = modelData.known     === true
                                    if (hasDisconnect || hasForget) {
                                        contextMenu.network = modelData
                                        contextMenu.popup()
                                    }
                                    return
                                }

                                // ── Left click ──────────────────────────────
                                if (!isSecured || modelData.known) {
                                    // Open network or already-saved secured network:
                                    // let NM connect directly (no password needed).
                                    root.connectDirect(modelData)
                                } else {
                                    // Unknown secured network — show inline password dialog.
                                    root.pendingNetwork  = modelData
                                    root.pendingPassword = ""
                                    root.statusMessage   = ""
                                    root.connecting      = false
                                    Qt.callLater(function() { pwField.forceActiveFocus() })
                                }
                            }
                        }
                    }
                }
            }
        }

        // Fade at the bottom when the list overflows
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:  28
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
        visible: !Network.networks || Network.networks.length === 0
        text: Network.scanning ? "Scanning for networks…" : "No networks found — tap Scan"
        color: Colors.textMuted
        font.pixelSize: Typography.sizeLabel
        horizontalAlignment: Text.AlignHCenter
        topPadding:    Spacing.spacingSm
        bottomPadding: Spacing.spacingSm
    }
}
