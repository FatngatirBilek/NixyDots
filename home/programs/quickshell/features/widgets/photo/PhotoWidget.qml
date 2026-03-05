import QtQuick
import QtQuick.Effects
import Quickshell.Io
import qs.theme

// PhotoWidget — single-photo desktop widget
//
// • Shows one chosen photo, cropped to fill the card.
// • Right-click → context menu → "Change Photo" → zenity file picker.
// • Selected path is persisted to ~/.config/quickshell/photo-widget-photo.txt
//   and reloaded on next shell start.
// • Drag anywhere on the card to reposition it on the desktop.

Item {
    id: root

    // ── Public configuration ──────────────────────────────────────────────────
    property int  cardWidth:   260
    property int  cardHeight:  300
    property real cornerRadius: 20

    // Drag bounds — wired from shell.qml
    property int dragMinX: 0
    property int dragMinY: 0
    property int dragMaxX: 9999
    property int dragMaxY: 9999

    implicitWidth:  cardWidth
    implicitHeight: cardHeight

    // ── Internal state ────────────────────────────────────────────────────────
    property string _photoPath:    ""
    property string _savedFile:    "/home/fathirbimashabri/.config/quickshell/photo-widget-photo.txt"
    property bool   _menuOpen:     false
    property bool   _picking:      false

    // ── Load persisted path on startup ────────────────────────────────────────
    Process {
        id: loadProc
        command: ["bash", "-c", "cat \"$1\" 2>/dev/null || true", "_", root._savedFile]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                const p = line.trim()
                if (p !== "") root._photoPath = p
            }
        }
    }

    // ── Zenity file picker ────────────────────────────────────────────────────
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
                    saveProc.running = true
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root._picking = false
        }
    }

    // ── Persist selected path ─────────────────────────────────────────────────
    Process {
        id: saveProc
        // Pass path as a positional arg so spaces/special chars are safe
        command: ["bash", "-c", "printf '%s\\n' \"$1\" > \"$2\"", "_", root._photoPath, root._savedFile]
        running: false
    }

    // ── Card ──────────────────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius:       root.cornerRadius
        color:        Colors.bgSecondary
        clip:         true

        // ── Photo (clipped to rounded corners via MultiEffect mask) ───────────
        // The mask Rectangle must be invisible but layer-enabled so MultiEffect
        // can sample its alpha channel as the clip shape.
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
