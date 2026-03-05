import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.theme
import qs.core
import qs.services
import qs.features.bar
import qs.features.panels.home
import qs.features.panels.dashboard
import qs.features.panels.launcher
import qs.features.panels.notifications
import qs.features.frame
import qs.features.osd
import qs.features.toasts
import qs.features.lockscreen
import qs.features.screenshot
import qs.features.widgets.photo
import qs.features.widgets.calendar
import qs.config

ShellRoot {
    id: root

    Process {
        id: devModeCheck
        command: ["sh", "-c", "test -z \"$INVOCATION_ID\" && echo dev"]

        stdout: SplitParser {
            onRead: function(data) {
                console.log({data: data.trim()})
                if (data.trim() === "dev") {
                    Quickshell.watchFiles = true
                }
            }
        }
    }

    Component.onCompleted: {
        // nix symlinks to the store cause spurious inotify events,
        // so disable file watching by default and only enable it
        // when running outside of a systemd service (i.e. development)
        Quickshell.watchFiles = false
        devModeCheck.running = true
        console.log("Shell loaded")
    }

    GlobalShortcut {
        name: "dashboard"
        description: "Open dashboard panel"

        onPressed: {
            Dispatcher.dispatch(Actions.togglePanel("dashboard"))
        }
    }

    GlobalShortcut {
        name: "launcher"
        description: "Open application launcher"

        onPressed: {
            Dispatcher.dispatch(Actions.togglePanel("launcher"))
        }
    }

    GlobalShortcut {
        name: "notifications"
        description: "Open notifications panel"

        onPressed: {
            Dispatcher.dispatch(Actions.togglePanel("notifications"))
        }
    }

    GlobalShortcut {
        name: "lock"
        description: "Lock the session"

        onPressed: {
            lock.locked = true
        }
    }

    Connections {
        target: Dispatcher

        function onLockRequested() {
            lock.locked = true
        }
    }

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false
            lockContext.clearPassword()
        }
    }

    WlSessionLock {
        id: lock

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    ScreenshotOverlay {}

    Variants {
        model: Quickshell.screens

        delegate: Item {
            id: screenRoot

            required property var modelData
            property var screen: modelData

            readonly property int monitorId: {
                const mon = Hyprland.monitorFor(screenRoot.screen)
                if (mon === null || mon === undefined) return -1
                return mon.id
            }

            readonly property bool panelActiveHere: Dispatcher.isPanelOnMonitor(screenRoot.monitorId)

            PanelWindow {
                id: barWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Normal
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "quickshell-bar"

                anchors {
                    top: true
                    left: true
                    right: true
                }

                exclusiveZone: Spacing.barHeight + Spacing.frameWidth - 5
                height: Spacing.barHeight

                Bar {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Spacing.barHeight
                    screen: screenRoot.screen
                }
            }

            PanelWindow {
                id: frameWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-frame"

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                ScreenFrame {
                    anchors.fill: parent
                    screen: screenRoot.screen
                }
            }

            PanelWindow {
                id: photoWidgetWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-photo-widget"

                visible: Config.showPhotoWidget

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {
                    item: photoWidgetMask
                }

                Item {
                    id: photoWidgetMask
                    visible: false

                    x: photoDesktopWidget.x
                    y: photoDesktopWidget.y
                    width:  photoDesktopWidget.width
                    height: photoDesktopWidget.height
                }

                PhotoWidget {
                    id: photoDesktopWidget

                    cardWidth:         Config.photoWidgetWidth
                    cardHeight:        Config.photoWidgetHeight

                    // Initial position: top-left corner, set once the
                    // window has been fully sized (avoids binding fight with drag).
                    Component.onCompleted: {
                        Qt.callLater(function() {
                            x = Config.widgetClusterMarginLeft
                            y = Spacing.barHeight + Config.widgetClusterMarginTop
                        })
                    }

                    // Drag bounds — keeps the widget inside the usable screen area.
                    // These are plain property bindings (not changed-signal handlers),
                    // so they can never cause a recursion loop.
                    dragMinX: 0
                    dragMinY: Spacing.barHeight
                    dragMaxX: photoWidgetWindow.width  - Config.photoWidgetWidth
                    dragMaxY: photoWidgetWindow.height - Config.photoWidgetHeight
                }
            }

            PanelWindow {
                id: calendarWidgetWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-calendar-widget"

                visible: Config.showCalendarWidget

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {
                    item: calendarWidgetMask
                }

                Item {
                    id: calendarWidgetMask
                    visible: false
                    x: calendarDesktopWidget.x
                    y: calendarDesktopWidget.y
                    width:  calendarDesktopWidget.width
                    height: calendarDesktopWidget.height
                }

                CalendarWidget {
                    id: calendarDesktopWidget

                    cardWidth:  Config.calendarWidgetWidth
                    cardHeight: Config.calendarWidgetHeight

                    // Below the photo+reminders row
                    Component.onCompleted: {
                        Qt.callLater(function() {
                            x = Config.widgetClusterMarginLeft
                            y = Spacing.barHeight + Config.widgetClusterMarginTop + Config.photoWidgetHeight + Config.widgetGap
                        })
                    }

                    dragMinX: 0
                    dragMinY: Spacing.barHeight
                    dragMaxX: calendarWidgetWindow.width  - Config.calendarWidgetWidth
                    dragMaxY: calendarWidgetWindow.height - Config.calendarWidgetHeight
                }
            }

            PanelWindow {
                id: remindersWidgetWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-reminders-widget"

                visible: Config.showRemindersWidget

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {
                    item: remindersWidgetMask
                }

                Item {
                    id: remindersWidgetMask
                    visible: false
                    x: remindersDesktopWidget.x
                    y: remindersDesktopWidget.y
                    width:  remindersDesktopWidget.width
                    height: remindersDesktopWidget.height
                }

                RemindersWidget {
                    id: remindersDesktopWidget

                    cardWidth:  Config.remindersWidgetWidth
                    cardHeight: Config.remindersWidgetHeight

                    // To the right of the photo widget, same top edge
                    Component.onCompleted: {
                        Qt.callLater(function() {
                            x = Config.widgetClusterMarginLeft + Config.photoWidgetWidth + Config.widgetGap
                            y = Spacing.barHeight + Config.widgetClusterMarginTop
                        })
                    }

                    dragMinX: 0
                    dragMinY: Spacing.barHeight
                    dragMaxX: remindersWidgetWindow.width  - Config.remindersWidgetWidth
                    dragMaxY: remindersWidgetWindow.height - Config.remindersWidgetHeight
                }
            }

            // ── Add Event overlay ─────────────────────────────────────────────
            PanelWindow {
                id: addEventOverlay

                screen:           screenRoot.screen
                color:            "transparent"
                exclusionMode:    ExclusionMode.Ignore
                WlrLayershell.layer:         WlrLayer.Overlay
                WlrLayershell.namespace:     "quickshell-add-event"
                WlrLayershell.keyboardFocus: CalendarState.addEventOpen
                                             ? WlrKeyboardFocus.Exclusive
                                             : WlrKeyboardFocus.None

                visible: CalendarState.addEventOpen

                anchors {
                    top:    true
                    left:   true
                    right:  true
                    bottom: true
                }

                mask: Region {
                    item: CalendarState.addEventOpen ? addEventFullMask : null
                }

                Item {
                    id: addEventFullMask
                    anchors.fill: parent
                    visible: false
                    Rectangle { anchors.fill: parent; color: "black" }
                }

                HyprlandFocusGrab {
                    active:  CalendarState.addEventOpen
                    windows: [addEventOverlay]
                    onCleared: { CalendarState.addEventOpen = false }
                }

                // Dim scrim
                Rectangle {
                    anchors.fill: parent
                    color:        Colors.withAlpha(Colors.crust, 0.55)
                    opacity:      CalendarState.addEventOpen ? 1 : 0
                    visible:      opacity > 0.01
                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                }

                // Click outside to close
                MouseArea {
                    anchors.fill: parent
                    visible:      CalendarState.addEventOpen
                    onClicked:    CalendarState.addEventOpen = false
                }

                // Centered panel card
                Item {
                    anchors.centerIn: parent
                    width:  addEventForm.width
                    height: addEventForm.height
                    z:      1

                    // Absorb clicks so they don't reach the close MouseArea
                    MouseArea { anchors.fill: parent }

                    AddEventPanel {
                        id: addEventForm
                    }
                }

                Item {
                    anchors.fill: parent
                    focus: CalendarState.addEventOpen
                    Keys.onEscapePressed: { CalendarState.addEventOpen = false }
                }
            }

            // ── Edit Event overlay ────────────────────────────────────────────
            PanelWindow {
                id: editEventOverlay

                screen:           screenRoot.screen
                color:            "transparent"
                exclusionMode:    ExclusionMode.Ignore
                WlrLayershell.layer:         WlrLayer.Overlay
                WlrLayershell.namespace:     "quickshell-edit-event"
                WlrLayershell.keyboardFocus: CalendarState.editEventOpen
                                             ? WlrKeyboardFocus.Exclusive
                                             : WlrKeyboardFocus.None

                visible: CalendarState.editEventOpen

                anchors {
                    top:    true
                    left:   true
                    right:  true
                    bottom: true
                }

                mask: Region {
                    item: CalendarState.editEventOpen ? editEventFullMask : null
                }

                Item {
                    id: editEventFullMask
                    anchors.fill: parent
                    visible: false
                    Rectangle { anchors.fill: parent; color: "black" }
                }

                HyprlandFocusGrab {
                    active:  CalendarState.editEventOpen
                    windows: [editEventOverlay]
                    onCleared: {
                        CalendarState.editEventOpen  = false
                        CalendarState.editEventIndex = -1
                    }
                }

                // Dim scrim
                Rectangle {
                    anchors.fill: parent
                    color:        Colors.withAlpha(Colors.crust, 0.55)
                    opacity:      CalendarState.editEventOpen ? 1 : 0
                    visible:      opacity > 0.01
                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                }

                // Click outside to close
                MouseArea {
                    anchors.fill: parent
                    visible:      CalendarState.editEventOpen
                    onClicked: {
                        CalendarState.editEventOpen  = false
                        CalendarState.editEventIndex = -1
                    }
                }

                // Centered panel card
                Item {
                    anchors.centerIn: parent
                    width:  editEventForm.width
                    height: editEventForm.height
                    z:      1

                    // Absorb clicks so they don't reach the close MouseArea
                    MouseArea { anchors.fill: parent }

                    EditEventPanel {
                        id: editEventForm
                    }
                }

                Item {
                    anchors.fill: parent
                    focus: CalendarState.editEventOpen
                    Keys.onEscapePressed: {
                        CalendarState.editEventOpen  = false
                        CalendarState.editEventIndex = -1
                    }
                }
            }

            // ── Add Reminder overlay ──────────────────────────────────────────
            PanelWindow {
                id: addReminderOverlay

                screen:           screenRoot.screen
                color:            "transparent"
                exclusionMode:    ExclusionMode.Ignore
                WlrLayershell.layer:         WlrLayer.Overlay
                WlrLayershell.namespace:     "quickshell-add-reminder"
                WlrLayershell.keyboardFocus: CalendarState.addReminderOpen
                                             ? WlrKeyboardFocus.Exclusive
                                             : WlrKeyboardFocus.None

                visible: CalendarState.addReminderOpen

                anchors {
                    top:    true
                    left:   true
                    right:  true
                    bottom: true
                }

                mask: Region {
                    item: CalendarState.addReminderOpen ? addReminderFullMask : null
                }

                Item {
                    id: addReminderFullMask
                    anchors.fill: parent
                    visible: false
                    Rectangle { anchors.fill: parent; color: "black" }
                }

                HyprlandFocusGrab {
                    active:  CalendarState.addReminderOpen
                    windows: [addReminderOverlay]
                    onCleared: { CalendarState.addReminderOpen = false }
                }

                // Dim scrim
                Rectangle {
                    anchors.fill: parent
                    color:        Colors.withAlpha(Colors.crust, 0.55)
                    opacity:      CalendarState.addReminderOpen ? 1 : 0
                    visible:      opacity > 0.01
                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                }

                // Click outside to close
                MouseArea {
                    anchors.fill: parent
                    visible:      CalendarState.addReminderOpen
                    onClicked:    CalendarState.addReminderOpen = false
                }

                // Centered panel card
                Item {
                    anchors.centerIn: parent
                    width:  addReminderForm.width
                    height: addReminderForm.height
                    z:      1

                    // Absorb clicks so they don't reach the close MouseArea
                    MouseArea { anchors.fill: parent }

                    AddReminderPanel {
                        id: addReminderForm
                    }
                }

                Item {
                    anchors.fill: parent
                    focus: CalendarState.addReminderOpen
                    Keys.onEscapePressed: { CalendarState.addReminderOpen = false }
                }
            }

            PanelWindow {
                id: osdWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell-osd"

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {}

                OsdPopup {
                    anchors.fill: parent
                    screen: screenRoot.screen
                }
            }

            PanelWindow {
                id: toastsWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell-toasts"

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                ToastContainer {
                    id: toastContainer
                    anchors.fill: parent
                    screen: screenRoot.screen
                }

                mask: Region {
                    item: toastContainer.inputMaskItem
                }
            }

            PanelWindow {
                id: panelsWindow

                screen: screenRoot.screen
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell-panels"
                WlrLayershell.keyboardFocus: screenRoot.panelActiveHere ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {
                    item: screenRoot.panelActiveHere ? fullMaskItem : null
                }

                Item {
                    id: fullMaskItem
                    anchors.fill: parent
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                    }
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    active: screenRoot.panelActiveHere
                    windows: [panelsWindow]
                    onCleared: {
                        Dispatcher.dispatch(Actions.closePanel())
                    }
                }

                // dim scrim behind panels
                Rectangle {
                    anchors.fill: parent
                    color: Colors.withAlpha(Colors.crust, 0.25)
                    opacity: screenRoot.panelActiveHere ? 1 : 0
                    visible: opacity > 0.01

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Motion.durationNormal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Motion.curveEnter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    visible: screenRoot.panelActiveHere
                    onClicked: {
                        Dispatcher.dispatch(Actions.closePanel())
                    }
                }

                // unified outline drawn behind all panel content
                PanelOutline {
                    id: panelOutline

                    property var _subMenuRects: {
                        var result = []
                        var count = traySubMenuRepeater.count
                        for (var i = 0; i < count; i++) {
                            var item = traySubMenuRepeater.itemAt(i)
                            if (item !== null && item !== undefined && item.width > 0 && item.height > 0) {
                                result.push(item.panelRect)
                            }
                        }
                        var closingCount = closingSubMenuRepeater.count
                        for (var j = 0; j < closingCount; j++) {
                            var ci = closingSubMenuRepeater.itemAt(j)
                            if (ci !== null && ci !== undefined && ci.width > 0 && ci.height > 0) {
                                result.push(ci.panelRect)
                            }
                        }
                        return result
                    }

                    panels: [
                        homePanel.panelRect,
                        trayFlyout.panelRect,
                        dashboardPanel.panelRect,
                        launcherPanel.panelRect,
                        notifPanel.panelRect
                    ].concat(_subMenuRects)
                    frameTop: Spacing.panelTopInset
                    frameLeft: Spacing.panelSideInset
                    frameRight: panelsWindow.width - Spacing.panelSideInset
                    frameBottom: panelsWindow.height - Spacing.panelSideInset
                    gapThreshold: 0
                }

                HomePanel {
                    id: homePanel
                    screenActive: screenRoot.panelActiveHere
                    anchors.left: parent.left
                    anchors.leftMargin: Spacing.panelSideInset
                    anchors.top: parent.top
                    anchors.topMargin: Spacing.panelTopInset
                }

                TrayFlyout {
                    id: trayFlyout
                    panelOpen: homePanel.isOpen
                    x: homePanel.x + homePanel.width
                    anchors.top: parent.top
                    anchors.topMargin: Spacing.panelTopInset
                }

                Repeater {
                    id: traySubMenuRepeater
                    model: Tray.subMenuStack

                    delegate: TraySubMenu {
                        required property var modelData
                        required property int index

                        x: modelData.x
                        y: modelData.y
                        menuEntry: modelData.entry
                        level: index
                    }
                }

                Repeater {
                    id: closingSubMenuRepeater
                    model: Tray.closingSubMenus

                    delegate: TraySubMenu {
                        required property var modelData
                        required property int index

                        x: modelData.x
                        y: modelData.y
                        menuEntry: modelData.entry
                        level: index
                        closing: true
                    }
                }

                DashboardPanel {
                    id: dashboardPanel
                    screenActive: screenRoot.panelActiveHere
                    anchors.right: parent.right
                    anchors.rightMargin: Spacing.panelSideInset
                    anchors.top: parent.top
                    anchors.topMargin: Spacing.panelTopInset
                }

                LauncherPanel {
                    id: launcherPanel
                    screenActive: screenRoot.panelActiveHere
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Spacing.panelTopInset
                }

                NotifPanel {
                    id: notifPanel
                    screenActive: screenRoot.panelActiveHere
                    anchors.right: parent.right
                    anchors.rightMargin: Spacing.panelSideInset
                    anchors.top: parent.top
                    anchors.topMargin: Spacing.panelTopInset
                }

                Item {
                    focus: screenRoot.panelActiveHere

                    Keys.onEscapePressed: {
                        Dispatcher.handleEscape()
                    }
                }
            }
        }
    }
}
