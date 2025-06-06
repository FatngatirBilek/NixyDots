import QtQuick

Rectangle {
    id: root
    width: 48
    height: 48
    color: "transparent"
    anchors.right: parent.right
    anchors.top: parent.top
    z: 999

    signal triggered()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -8
        hoverEnabled: true
        
        property bool isHovered: containsMouse
        
        onIsHoveredChanged: {
            if (isHovered) {
                showTimer.start()
                hideTimer.stop()
            } else {
                hideTimer.start()
                showTimer.stop()
            }
        }
        
        onEntered: hideTimer.stop()
    }

    // Smooth show/hide timers
    Timer {
        id: showTimer
        interval: 200
        onTriggered: root.triggered()
    }

    Timer {
        id: hideTimer
        interval: 500
        // Note: This timer is managed by the parent SlideBar component
    }

    // Expose properties and functions for parent components
    readonly property alias containsMouse: mouseArea.containsMouse
    function stopHideTimer() { hideTimer.stop() }
    function startHideTimer() { hideTimer.start() }
}