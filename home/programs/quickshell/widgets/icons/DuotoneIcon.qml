import QtQuick
import QtQuick.Effects
import qs.theme

Item {
    id: root

    property string name: ""
    property int size: Spacing.iconMd
    property string iconState: "default"  // default, hover, active, disabled

    // Allow direct color override; if not set, derives from iconState
    property color color: {
        switch (iconState) {
            case "hover":    return Colors.iconHoverPrimary
            case "active":   return Colors.iconActivePrimary
            case "disabled": return Colors.iconDisabledPrimary
            default:         return Colors.iconPrimary
        }
    }

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    // ── Icon name → resolved SVG paths ───────────────────────────────────────
    readonly property string _duotoneSrc: {
        if (name === null || name === undefined || name === "") return ""
        return Qt.resolvedUrl("../../assets/phosphor-icons/duotone/" + name + "-duotone.svg")
    }

    readonly property string _regularSrc: {
        if (name === null || name === undefined || name === "") return ""
        return Qt.resolvedUrl("../../assets/phosphor-icons/regular/" + name + ".svg")
    }

    // ── Primary (duotone) image ───────────────────────────────────────────────
    Image {
        id: iconImage
        anchors.fill: parent
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        asynchronous: false
        cache: false
        visible: false
        source: root._duotoneSrc

        // Force MultiEffect to re-render when the image source changes:
        // briefly clear the source so Qt's scene graph invalidates the cached
        // texture, then restore it on the next frame.
        onSourceChanged: {
            multiEffectPrimary.visible = false
            resetTimer.restart()
        }
    }

    Timer {
        id: resetTimer
        interval: 16   // one frame @ 60 Hz
        repeat: false
        onTriggered: multiEffectPrimary.visible = (iconImage.status === Image.Ready)
    }

    MultiEffect {
        id: multiEffectPrimary
        anchors.fill: parent
        source: iconImage
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
        visible: iconImage.status === Image.Ready
    }

    // ── Fallback (regular / outline) image ───────────────────────────────────
    Image {
        id: fallbackImage
        anchors.fill: parent
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        asynchronous: false
        cache: false
        visible: false
        source: root._regularSrc

        onSourceChanged: {
            multiEffectFallback.visible = false
            resetTimerFallback.restart()
        }
    }

    Timer {
        id: resetTimerFallback
        interval: 16
        repeat: false
        onTriggered: multiEffectFallback.visible =
            (iconImage.status !== Image.Ready && fallbackImage.status === Image.Ready)
    }

    MultiEffect {
        id: multiEffectFallback
        anchors.fill: parent
        source: fallbackImage
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
        visible: iconImage.status !== Image.Ready && fallbackImage.status === Image.Ready
    }

    // ── "?" placeholder when both images fail to load ─────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: root.size * 0.7
        height: root.size * 0.7
        radius: Spacing.radiusSm
        color: "transparent"
        border.width: 1
        border.color: Colors.textDim
        visible: iconImage.status !== Image.Ready && fallbackImage.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: "?"
            font.pixelSize: root.size * 0.4
            font.family: Typography.bodyFamily
            color: Colors.textDim
        }
    }

    Behavior on color {
        ColorAnimation { duration: Motion.hoverDuration }
    }
}
