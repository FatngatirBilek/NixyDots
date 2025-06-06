pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Rosé Pine Colors
    id: colors
    readonly property color bgColor: "#1f1d2e"          // Base background
    readonly property color fgColor: "#e0def4"          // Base foreground (text)
    readonly property color accentColor: "#eb6f92"      // Pink accent ("love")
    readonly property color highlightBg: "#26233a"      // Highlight background
}
