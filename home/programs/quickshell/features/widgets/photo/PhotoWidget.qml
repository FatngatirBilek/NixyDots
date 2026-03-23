import QtQuick
import QtQuick.Effects
import Quickshell.Io
import qs.theme
import qs.features.widgets

// PhotoWidget — single-photo desktop widget
//
// • Shows one chosen photo, cropped to fill the card.
// • Right-click → context menu → "Change Photo" → zenity file picker.
// • Selected path is persisted to centralized WidgetsState (~/.config/quickshell/widgets.json).
// • Drag anywhere on the card to reposition it on the desktop.

Item {
    id: root

    // ── Public configuration ──────────────────────────────────────────────────
    property int  cardWidth:   260
    property int  cardHeight:  300
    property real cornerRadius: 20

    // Unique instance id (set by shell.qml when instantiating multiple widgets)
    property string instanceId: "photo-top"

    // Drag bounds — wired from shell.qml
    property int dragMinX: 0
    property int dragMinY: 0
    property int dragMaxX: 9999
    property int dragMaxY: 9999

    implicitWidth:  cardWidth
    implicitHeight: cardHeight

    // ── Internal state ────────────────────────────────────────────────────────
    property string _photoPath: ""
    property bool   _menuOpen:  false
    property bool   _picking:   false

    // ── Helpers ───────────────────────────────────────────────────────────────
    function _applyStoredState() {
        if (!root.instanceId) return
        try {
            var storedPhoto = ""
            if (typeof WidgetsState !== "undefined") {
                if (typeof WidgetsState.getPhotoPath === "function") {
                    storedPhoto = WidgetsState.getPhotoPath(root.instanceId)
                } else if (WidgetsState.getPhotoPath) {
                    storedPhoto = WidgetsState.getPhotoPath(root.instanceId)
                } else if (WidgetsState.photos) {
                    storedPhoto = WidgetsState.photos[root.instanceId] || ""
                }
            }
            if (storedPhoto && storedPhoto !== "") root._photoPath = storedPhoto
        } catch(e) {
            console.warn("PhotoWidget: error reading photo from WidgetsState", e)
        }

        try {
            var pos = null
            if (typeof WidgetsState !== "undefined") {
                if (typeof WidgetsState.getPosition === "function") pos = WidgetsState.getPosition(root.instanceId)
                else if (WidgetsState.getPosition) pos = WidgetsState.getPosition(root.instanceId)
                else if (WidgetsState.positions) pos = WidgetsState.positions[root.instanceId]
            }
            if (pos && pos.x !== undefined && pos.y !== undefined) { root.x = pos.x; root.y = pos.y }
        } catch(e) {
            console.warn("PhotoWidget: error reading position from WidgetsState", e)
        }
    }

    function _persistPhoto(path) {
        if (!root.instanceId) return
        try {
            if (typeof WidgetsState !== "undefined") {
                if (typeof WidgetsState.setPhotoPath === "function") {
                    WidgetsState.setPhotoPath(root.instanceId, path)
                } else if (WidgetsState.setPhotoPath) {
                    WidgetsState.setPhotoPath(root.instanceId, path)
                } else if (typeof WidgetsState.setPhotoPathProp === "function") {
                    WidgetsState.setPhotoPathProp(root.instanceId, path)
                } else {
                    console.warn("PhotoWidget: no writable setPhotoPath API on WidgetsState")
                }
            }
        } catch(e) {
            console.warn("PhotoWidget: _persistPhoto failed", e)
        }
    }

    function _persistPosition(x, y) {
        if (!root.instanceId) return
        try {
            if (typeof WidgetsState !== "undefined") {
                if (typeof WidgetsState.setPosition === "function") {
                    WidgetsState.setPosition(root.instanceId, x, y)
                } else if (WidgetsState.setPosition) {
                    WidgetsState.setPosition(root.instanceId, x, y)
                } else if (typeof WidgetsState.setPositionProp === "function") {
                    WidgetsState.setPositionProp(root.instanceId, x, y)
                } else {
                    console.warn("PhotoWidget: no writable setPosition API on WidgetsState")
                }
            }
        } catch(e) {
            console.warn("PhotoWidget: _persistPosition failed", e)
        }
    }

    // ── Zenity file picker ───────────────────────────────────────────────────
    Process {
        id: pickerProc
        command: [
            "zenity",
            "--file-selection",
            "--title=Choose Photo",
            "--file-filter=Images (jpg png webp gif) | *.jpg *.jpeg *.JPG *.JPEG *.png *.PNG *.webp *.WEBP *.gif *.GIF *.avif *.AVIF",
            "--file-filter=All files | *"
        ]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const p = line.trim()
                if (p !== "") {
                    root._photoPath = p
                    try {
                        console.log("PhotoWidget: persist photo request for", root.instanceId, p)
                        _persistPhoto(p)
                    } catch(e) {
                        console.warn("PhotoWidget: picker persist failed", e)
                    }
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root._picking = false
        }
    }

    // ── Apply stored state after WidgetsState has finished loading ────────────
    Component.onCompleted: {
        // If WidgetsState is available and already loaded, apply immediately.
        if (typeof WidgetsState !== "undefined" && WidgetsState.loaded === true) {
            Qt.callLater(_applyStoredState)
        } else if (typeof WidgetsState !== "undefined" && WidgetsState.loaded === false) {
            // wait for loaded -> true via Connections (below)
        } else {
            // If WidgetsState not present for some reason, still try once later.
            // Also kick off a direct fallback loader that reads the JSON file
            // directly and applies photo/position if present. This helps when
            // the centralized WidgetsState singleton isn't available at startup
            // (for example due to QML load ordering or a different environment).
            Qt.callLater(_applyStoredState)
            try { fallbackLoadProc.running = true } catch(e) { /* ignore */ }
        }
    }

    // ── Fallback loader: read widgets.json directly if WidgetsState is missing ──
    Process {
        id: fallbackLoadProc
        running: false
        property string _buf: ""

        // Read the per-user widgets.json directly. Use absolute path to avoid
        // shell roots differing between environments.
        command: ["bash", "-c", "cat '/home/fathirbimashabri/.config/quickshell/widgets.json' 2>/dev/null || true"]

        stdout: SplitParser {
            onRead: function(line) {
                fallbackLoadProc._buf += line + "\n"
            }
        }

        onExited: function(code) {
            var trimmed = fallbackLoadProc._buf.trim()
            if (trimmed !== "") {
                try {
                    var parsed = JSON.parse(trimmed)
                    // Photo path for this instance
                    var photo = ""
                    if (parsed && parsed.photos && parsed.photos[root.instanceId]) {
                        photo = parsed.photos[root.instanceId]
                    }
                    if (photo && photo !== "") {
                        root._photoPath = photo
                    }
                    // Position for this instance
                    var pos = null
                    if (parsed && parsed.positions && parsed.positions[root.instanceId]) {
                        pos = parsed.positions[root.instanceId]
                    }
                    if (pos && pos.x !== undefined && pos.y !== undefined) {
                        root.x = pos.x
                        root.y = pos.y
                    }
                } catch(e) {
                    console.warn("PhotoWidget: fallback parse failed", e)
                }
            }
            fallbackLoadProc._buf = ""
        }
    }

    // Listen for WidgetsState.loaded changes and apply when ready.
    Connections {
        // Use a defensive target expression so we don't error if WidgetsState undefined.
        target: typeof WidgetsState !== 'undefined' ? WidgetsState : null
        onLoadedChanged: {
            if (typeof WidgetsState === 'undefined') return
            if (!WidgetsState.loaded) return
            Qt.callLater(_applyStoredState)
        }
    }

    // ── Card ──────────────────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius:       root.cornerRadius
        color:        Colors.bgSecondary
        clip:         true

        // ── Photo (clipped to rounded corners via MultiEffect mask) ───────────
        Rectangle {
            id: photoMask
            anchors.fill: parent
            radius:       root.cornerRadius
            visible:      false
            layer.enabled: true
        }

        Image {
            id: photo
            anchors.fill: parent
            source:       root._photoPath !== "" ? "file://" + root._photoPath : ""
            fillMode:     Image.PreserveAspectCrop
            smooth:       true
            mipmap:       true
            asynchronous: true

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource:       photoMask
                maskEnabled:      true
                maskThresholdMin: 0.5
                maskSpreadAtMin:  1.0
            }
        }

        // ── Empty / error state ───────────────────────────────────────────────
        Column {
            anchors.centerIn: parent
            spacing: Spacing.spacingSm
            visible: root._photoPath === "" || photo.status === Image.Error

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:          root._photoPath !== "" && photo.status === Image.Error
                               ? "⚠" : "🖼"
                font.pixelSize: 44
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:          root._photoPath !== "" && photo.status === Image.Error
                               ? "Could not load photo" : "No photo selected"
                color:         Colors.textMuted
                font.pixelSize: 12
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "Right-click to choose"
                color: Colors.textDim
                font.pixelSize: 11
            }
        }

        // ── Loading spinner hint ──────────────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            color:        Colors.bgTertiary
            visible:      root._photoPath !== ""
                          && photo.status === Image.Loading
        }

        // ── Subtle border (always on top) ─────────────────────────────────────
        Rectangle {
            anchors.fill:  parent
            radius:        root.cornerRadius
            color:         "transparent"
            border.color:  Colors.withAlpha(Colors.text, 0.10)
            border.width:  1
            z: 20
        }

        // ── Main interaction: drag (left) + context menu (right) ──────────────
        MouseArea {
            id: mainArea
            anchors.fill:    parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            drag.target:     root
            drag.axis:       Drag.XAndYAxis
            drag.minimumX:   root.dragMinX
            drag.minimumY:   root.dragMinY
            drag.maximumX:   root.dragMaxX
            drag.maximumY:   root.dragMaxY
            // only start drag on left button
            drag.filterChildren: true

            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    // position menu at click, clamped inside card
                    const mx = Math.min(mouse.x, card.width  - contextMenu.menuWidth  - 4)
                    const my = Math.min(mouse.y, card.height - contextMenu.menuHeight - 4)
                    contextMenu.x    = Math.max(4, mx)
                    contextMenu.y    = Math.max(4, my)
                    root._menuOpen   = true
                }
            }

            // close menu on left-click anywhere on card
            onPressed: function(mouse) {
                if (mouse.button === Qt.LeftButton && root._menuOpen) {
                    root._menuOpen = false
                }
                // Bring widget to front for dragging so other widgets don't intercept
                if (mouse.button === Qt.LeftButton) {
                    try {
                        root._prevZ = (typeof root.z !== 'undefined') ? root.z : 0
                        root.z = 10000
                    } catch(e) { /* ignore */ }
                }
            }

            // when user releases left-button after dragging, persist final position
            onReleased: function(mouse) {
                if (mouse.button === Qt.LeftButton && root.instanceId) {
                    try {
                        // persist via centralized widget state
                        _persistPosition(root.x, root.y)
                    } catch(e) {
                        console.warn("PhotoWidget: failed to persist position", e)
                    }
                }
                // restore z-order when drag finishes
                try {
                    root.z = root._prevZ
                } catch(e) { /* ignore */ }
            }

            // restore z-order if drag/click canceled (e.g., pointer moved off or drag cancelled)
            onCanceled: function() {
                try {
                    root.z = root._prevZ
                } catch(e) { /* ignore */ }
            }
        }

        // ── Context menu ──────────────────────────────────────────────────────
        Rectangle {
            id: contextMenu

            readonly property int menuWidth:  148
            readonly property int menuHeight: 36

            width:   menuWidth
            height:  menuHeight
            radius:  Spacing.radiusMd
            color:   Colors.bgElevated
            z:       50
            visible: root._menuOpen
            clip:    false

            // shadow ring
            Rectangle {
                anchors.fill:    parent
                anchors.margins: -1
                radius:          parent.radius + 1
                color:           "transparent"
                border.color:    Colors.withAlpha(Colors.crust, 0.55)
                border.width:    1
                z: -1
            }
            Rectangle {
                anchors.fill:    parent
                anchors.margins: -3
                radius:          parent.radius + 3
                color:           "transparent"
                border.color:    Colors.withAlpha(Colors.crust, 0.25)
                border.width:    2
                z: -2
            }

            // border
            Rectangle {
                anchors.fill:  parent
                radius:        parent.radius
                color:         "transparent"
                border.color:  Colors.withAlpha(Colors.text, 0.12)
                border.width:  1
                z: 1
            }

            // ── "Change Photo" row ────────────────────────────────────────────
            Rectangle {
                id: changeRow
                anchors.fill:    parent
                radius:          parent.radius
                color:           changeHover.containsMouse
                                 ? Colors.bgHover : "transparent"

                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:           parent.left
                    anchors.leftMargin:     Spacing.paddingSm
                    spacing:                Spacing.spacingSm

                    // small image icon (drawn manually — no import needed)
                    Rectangle {
                        width:  14
                        height: 14
                        radius: 3
                        color:  "transparent"
                        border.color: Colors.iconPrimary
                        border.width: 1.5
                        anchors.verticalCenter: parent.verticalCenter

                        // mountain shape
                        Rectangle {
                            width:  4; height: 4; radius: 2
                            color:  Colors.iconPrimary
                            anchors.top: parent.top
                            anchors.topMargin: 3
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                        }
                    }

                    Text {
                        text:           root._picking ? "Opening…" : "Change Photo"
                        color:          Colors.textPrimary
                        font.pixelSize: 12
                        font.weight:    Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: changeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor

                    onClicked: {
                        if (root._picking) return
                        root._menuOpen = false
                        root._picking  = true
                        pickerProc.running = true
                    }
                }
            }

            // close when clicking outside the menu (overlay)
            MouseArea {
                parent:       card
                anchors.fill: parent
                z:            49
                visible:      root._menuOpen
                onClicked: {
                    root._menuOpen = false
                }
            }
        }
    }

    // ── Drop shadow layers (behind card) ──────────────────────────────────────
    Rectangle {
        anchors.fill:    card
        anchors.margins: -1
        radius:          root.cornerRadius + 1
        color:           "transparent"
        border.color:    Colors.withAlpha(Colors.crust, 0.50)
        border.width:    1
        z: -1
    }
    Rectangle {
        anchors.fill:    card
        anchors.margins: -3
        radius:          root.cornerRadius + 3
        color:           "transparent"
        border.color:    Colors.withAlpha(Colors.crust, 0.25)
        border.width:    2
        z: -2
    }
}
