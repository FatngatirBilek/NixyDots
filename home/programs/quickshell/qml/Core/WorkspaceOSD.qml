import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import "root:/Data/" as Data

PanelWindow {
    id: workspaceOsd
    property var shell

    anchors.left: true
    width: 45
    implicitHeight: Math.max(100, activeWorkspaceCount * 32 + 32)
    visible: true
    color: "transparent"
    exclusiveZone: 0
    exclusionMode: None

    property int activeWorkspaceCount: 1
    property int lastWorkspace: -1
    property bool isAnimating: false

    Behavior on height {
        enabled: !isAnimating
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    function updateWorkspaceCount() {
        if (!shell?.workspaces) {
            activeWorkspaceCount = 1
            return
        }

        let count = 0
        if (typeof shell.workspaces.rowCount === 'function') {
            count = shell.workspaces.rowCount()
        } else if (workspaceRepeater.count > 0) {
            count = workspaceRepeater.count
        }
        
        const newCount = Math.max(1, count)
        if (newCount !== activeWorkspaceCount) {
            activeWorkspaceCount = newCount
        }
    }

    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: hideOsd()
    }

    Timer {
        id: hoverTimer
        interval: 200
        onTriggered: showOsd()
    }

    Timer {
        id: checkTimer
        interval: 2000
        repeat: true
        running: shell && shell.workspaces
        onTriggered: updateWorkspaceCount()
    }

    Connections {
        target: shell
        enabled: shell !== null

        function onFocusedWorkspaceChanged() {
            if (!shell.focusedWorkspace) return
            
            const currentId = shell.focusedWorkspace.id
            if (currentId !== lastWorkspace && lastWorkspace !== -1) {
                showOsd()
            }
            lastWorkspace = currentId
        }
    }

    Connections {
        target: shell?.workspaces ?? null
        enabled: target !== null

        function onCountChanged() { Qt.callLater(updateWorkspaceCount) }
        function onModelReset() { Qt.callLater(updateWorkspaceCount) }
        function onRowsInserted() { Qt.callLater(updateWorkspaceCount) }
        function onRowsRemoved() { Qt.callLater(updateWorkspaceCount) }
        function onDataChanged() { Qt.callLater(updateWorkspaceCount) }
    }

    Component.onCompleted: {
        if (shell?.focusedWorkspace?.id !== undefined) {
            lastWorkspace = shell.focusedWorkspace.id
        }
        Qt.callLater(updateWorkspaceCount)
    }

    function showOsd() {
        if (osdContent.visible) {
            hideTimer.restart()
            return
        }
        
        isAnimating = true
        osdContent.visible = true
        slideInAnimation.start()
        hideTimer.restart()
    }

    function hideOsd() {
        if (!osdContent.visible) return
        isAnimating = true
        slideOutAnimation.start()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hoverTimer.start()
        onExited: hoverTimer.stop()
    }

    NumberAnimation {
        id: slideInAnimation
        target: osdContent
        property: "x"
        from: -workspaceOsd.width
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
        onFinished: isAnimating = false
    }

    NumberAnimation {
        id: slideOutAnimation
        target: osdContent
        property: "x"
        from: 0
        to: -workspaceOsd.width
        duration: 250
        easing.type: Easing.InCubic
        onFinished: {
            osdContent.visible = false
            osdContent.x = 0
            isAnimating = false
        }
    }

    Rectangle {
        id: osdContent
        width: parent.width
        height: parent.height
        color: Data.Colors.accentColor
        topRightRadius: 20
        bottomRightRadius: 20
        visible: false

        Column {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                id: workspaceRepeater
                model: shell?.workspaces ?? []

                delegate: Rectangle {
                    id: workspaceIndicator
                    width: 24
                    height: 24
                    radius: 20
                    
                    property bool isActive: shell?.focusedWorkspace && 
                                          modelData && 
                                          modelData.id === shell.focusedWorkspace.id

                    color: isActive ? Data.Colors.bgColor : Qt.darker(Data.Colors.accentColor, 1.5)
                    scale: isActive ? 1.2 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Text {
                        text: modelData?.id ?? "?"
                        anchors.centerIn: parent
                        color: parent.isActive ? Data.Colors.accentColor : Data.Colors.bgColor
                        font.pixelSize: 10
                        font.weight: Font.Bold

                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}