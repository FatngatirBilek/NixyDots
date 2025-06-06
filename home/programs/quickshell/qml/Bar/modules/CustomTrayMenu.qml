pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "root:/Data/" as Data

Rectangle {
    id: trayMenu
    width: 180
    height: Math.max(40, listView.contentHeight + 12)
    clip: true
    color: Data.Colors.bgColor
    border.color: Data.Colors.accentColor
    border.width: 3
    radius: 20
    visible: false
    z: 9999

    enabled: visible
    scale: 1.0
    rotation: 0
    transform: []
    parent: null

    property QsMenuHandle menu
    property point triggerPoint: Qt.point(0, 0)
    property Item originalParent

    function toggle() {
        if (visible) {
            hide()
        } else {
            show(triggerPoint, originalParent)
        }
    }

    function closeOnRightClick() {
        if (visible) hide()
    }

    QsMenuOpener {
        id: opener
        menu: trayMenu.menu
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2
        interactive: false
        enabled: trayMenu.enabled

        model: ScriptModel {
            values: opener.children ? [...opener.children.values] : []
        }

        delegate: Rectangle {
            id: entry
            required property var modelData

            width: listView.width
            height: (modelData?.isSeparator) ? 8 : 28
            color: "transparent"
            radius: 4

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 20
                height: 1
                color: Qt.darker(Data.Colors.bgColor, 1.4)
                visible: modelData?.isSeparator ?? false
            }

            Rectangle {
                anchors.fill: parent
                color: mouseArea.containsMouse ? Data.Colors.highlightBg : "transparent"
                radius: 4
                visible: !(modelData?.isSeparator ?? false)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        color: (modelData?.enabled ?? true) ? Data.Colors.fgColor : Qt.darker(Data.Colors.fgColor, 1.8)
                        text: modelData?.text ?? ""
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: modelData?.icon ?? ""
                        visible: (modelData?.icon ?? "") !== ""
                        fillMode: Image.PreserveAspectFit
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && trayMenu.enabled

                    onClicked: {
                        if (modelData && !modelData.isSeparator) {
                            modelData.triggered()
                            trayMenu.hide()
                        }
                    }
                }
            }
        }
    }

    function show(point, parentItem) {
        if (parentItem) {
            originalParent = parent
            parent = parentItem
            x = point.x
            y = point.y

            const globalPos = mapToGlobal(0, 0)
            if (globalPos.x + width > Screen.width)
                x = point.x - width + 24
            if (globalPos.y + height > Screen.height)
                y = point.y - height - 5
        } else {
            parent = null
            x = point.x
            y = point.y
        }

        visible = true
        enabled = true
    }

    function hide() {
        visible = false
        enabled = false
    }

    Keys.onEscapePressed: hide()

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
            enabled = true
            Qt.callLater(() => forceActiveFocus())
        } else {
            enabled = false
        }
    }

    Component.onDestruction: {
        if (originalParent) parent = originalParent
    }
}
