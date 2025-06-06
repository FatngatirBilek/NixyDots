import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

Item {
    id: root
    required property var shell
    property string selectedWidget: "cliphist"
    
    property bool isVisible: true
    
    function show() { showAnimation.start() }
    function hide() { hideAnimation.start() }
    function toggle() { isVisible ? hide() : show() }

    SequentialAnimation {
        id: showAnimation
        PropertyAction { target: root; property: "isVisible"; value: true }
        ParallelAnimation {
            PropertyAnimation { target: root; property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
            PropertyAnimation { target: root; property: "scale"; from: 0.9; to: 1.0; duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
            PropertyAnimation { target: contentColumn; property: "y"; from: -15; to: 0; duration: 200; easing.type: Easing.OutQuart }
        }
    }
    
    SequentialAnimation {
        id: hideAnimation
        ParallelAnimation {
            PropertyAnimation { target: root; property: "opacity"; to: 0.0; duration: 150; easing.type: Easing.InCubic }
            PropertyAnimation { target: root; property: "scale"; to: 0.95; duration: 150; easing.type: Easing.InQuart }
            PropertyAnimation { target: contentColumn; property: "y"; to: -10; duration: 150; easing.type: Easing.InQuart }
        }
        PropertyAction { target: root; property: "isVisible"; value: false }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 12
        
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            
            Label {
                text: "Clipboard History"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: shell.fgColor
                Layout.fillWidth: true
            }
            
            Button {
                id: clearButton
                text: "Clear"
                implicitWidth: 60
                implicitHeight: 25
                background: Rectangle {
                    radius: 12
                    color: parent.down ? Qt.darker(shell.errorColor, 1.2) :
                           parent.hovered ? Qt.lighter(shell.errorColor, 1.1) : 
                           Qt.rgba(shell.errorColor.r, shell.errorColor.g, shell.errorColor.b, 0.8)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Label {
                    text: parent.text
                    font.pixelSize: 11
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    clearClipboardHistory()
                    clickScale.target = clearButton
                    clickScale.start()
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ScrollView {
                anchors.fill: parent
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                ListView {
                    id: cliphistList
                    model: cliphistModel
                    spacing: 6
                    Behavior on contentY { PropertyAnimation { duration: 200; easing.type: Easing.OutQuart } }
                    
                    delegate: Rectangle {
                        width: cliphistList.width
                        height: Math.max(50, contentText.contentHeight + 20)
                        radius: 8
                        color: mouseArea.containsMouse ? Qt.lighter(shell.highlightBg, 1.1) : shell.highlightBg
                        border.color: shell.borderColor
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Label {
                                text: model.type === "image" ? "🖼️" : model.type === "url" ? "🔗" : "📝"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignTop
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4
                                
                                Label {
                                    id: contentText
                                    text: model.type === "image" ? "[Image Data]" : 
                                          (model.content.length > 100 ? model.content.substring(0, 100) + "..." : model.content)
                                    font.pixelSize: 12
                                    color: shell.fgColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true

                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: model.type === "image" ? "Image" : (model.content.length + " chars")
                                        font.pixelSize: 10
                                        color: Qt.darker(shell.fgColor, 1.5)
                                    }
                                }
                            }
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) {
                                    copyToClipboard(model.id, model.type)
                                    clickScale.target = parent
                                    clickScale.start()
                                }
                            }
                            onDoubleClicked: console.log("Full content:", model.content)
                        }
                    }
                    
                    Label {
                        anchors.centerIn: parent
                        text: "No clipboard history\nCopy something to get started"
                        font.pixelSize: 14
                        color: Qt.darker(shell.fgColor, 1.5)
                        horizontalAlignment: Text.AlignHCenter
                        visible: cliphistList.count === 0
                        opacity: 0.7
                    }
                }
            }
        }
    }
    
    SequentialAnimation {
        id: clickScale
        property var target
       
    }
    
    ListModel { id: cliphistModel }

    // Store the current state to compare for changes
    property var currentEntries: []

    Process {
        id: cliphistProcess
        command: ["cliphist", "list"]
        running: false
        
        property var tempEntries: []
        
        onRunningChanged: {
            if (running) {
                tempEntries = []
            } else {
                // Process completed, now update the model intelligently
                updateModelIfChanged(tempEntries)
            }
        }
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    const line = data.toString().trim()
                    
                    // Skip empty lines
                    if (line === "") return
                    
                    // Skip error messages and warnings that might appear in stdout
                    if (line.includes("ERROR") || line.includes("WARN") || line.includes("error:") || line.includes("warning:")) {
                        return
                    }
                    
                    // Parse the line: ID + spaces + content
                    const match = line.match(/^(\d+)\s+(.+)$/)
                    if (match) {
                        const id = match[1]
                        const content = match[2]
                        
                        // Add to temporary array instead of directly to model
                        cliphistProcess.tempEntries.push({
                            id: id,
                            content: content,
                            type: detectContentType(content),
                        })
                    } else {
                        console.log("Failed to parse line:", line)
                    }
                } catch (e) {
                    console.error("Error parsing cliphist line:", e)
                }
            }
        }
    }

    Process {
        id: clearCliphistProcess
        command: ["cliphist", "wipe"]
        running: false
        
        onRunningChanged: {
            if (!running) {
                // Clear completed, update our model and state
                cliphistModel.clear()
                currentEntries = []
                console.log("Clipboard history cleared")
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                console.error("Clear clipboard error:", data.toString())
            }
        }
    }

    Process {
        id: deleteEntryProcess
        property string entryId: ""
        command: ["cliphist", "delete-query", entryId]
        running: false
        
        onRunningChanged: {
            if (!running && entryId !== "") {
                // Delete completed, remove from model
                for (let i = 0; i < cliphistModel.count; i++) {
                    if (cliphistModel.get(i).id === entryId) {
                        cliphistModel.remove(i)
                        // Also remove from currentEntries
                        currentEntries = currentEntries.filter(entry => entry.id !== entryId)
                        break
                    }
                }
                console.log("Deleted entry:", entryId)
                entryId = ""
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                console.error("Delete entry error:", data.toString())
            }
        }
    }

    Process {
        id: copyTextProcess
        property string textToCopy: ""
        command: ["wl-copy", textToCopy]
        running: false
        
        stderr: SplitParser {
            onRead: data => {
                console.error("wl-copy error:", data.toString())
            }
        }
    }

    Process {
        id: copyHistoryProcess
        property string entryId: ""
        command: ["sh", "-c", "printf '%s' '" + entryId + "' | cliphist decode | wl-copy"]
        running: false
        
        stderr: SplitParser {
            onRead: data => {
                console.error("Copy history error:", data.toString())
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 5000
        running: root.isVisible
        repeat: true
        onTriggered: {
            // Only refresh if not currently processing
            if (!cliphistProcess.running) {
                refreshClipboardHistory()
            }
        }
    }

    function updateModelIfChanged(newEntries) {
        if (newEntries.length !== currentEntries.length) {
            updateModel(newEntries)
            return
        }
        
        let hasChanges = false
        for (let i = 0; i < newEntries.length; i++) {
            if (i >= currentEntries.length || 
                newEntries[i].id !== currentEntries[i].id ||
                newEntries[i].content !== currentEntries[i].content) {
                hasChanges = true
                break
            }
        }
        
        // Only update if there are actual changes
        if (hasChanges) {
            updateModel(newEntries)
        }
    }
    
    function updateModel(newEntries) {
        const scrollPos = cliphistList.contentY
        
        for (let i = cliphistModel.count - 1; i >= 0; i--) {
            const modelItem = cliphistModel.get(i)
            const found = newEntries.some(entry => entry.id === modelItem.id)
            if (!found) {
                cliphistModel.remove(i)
            }
        }
        
        // Add or update items
        for (let i = 0; i < newEntries.length; i++) {
            const newEntry = newEntries[i]
            let found = false
            
            // Check if item already exists in model
            for (let j = 0; j < cliphistModel.count; j++) {
                const modelItem = cliphistModel.get(j)
                if (modelItem.id === newEntry.id) {
                    // Update if content changed
                    if (modelItem.content !== newEntry.content) {
                        cliphistModel.set(j, newEntry)
                    }
                    // Move to correct position if needed
                    if (j !== i && i < cliphistModel.count) {
                        cliphistModel.move(j, i, 1)
                    }
                    found = true
                    break
                }
            }
            
            // Add new item if not found
            if (!found) {
                if (i < cliphistModel.count) {
                    cliphistModel.insert(i, newEntry)
                } else {
                    cliphistModel.append(newEntry)
                }
            }
        }
        
        // Restore scroll position
        cliphistList.contentY = scrollPos
        
        // Update our reference
        currentEntries = newEntries.slice()
    }

    function detectContentType(content) {
        // Check for binary/image data patterns
        if (content.includes('\x00') || content.startsWith('\x89PNG') || content.startsWith('\xFF\xD8\xFF')) {
            return "image"
        }
        if (content.includes('[[ binary data ') || content.includes('<selection>')) {
            return "image"
        }
        if (/^https?:\/\/\S+$/.test(content.trim())) return "url"
        if (content.includes('\n') && (content.includes('{') || content.includes('function') || content.includes('=>'))) return "code"
        if (content.startsWith('sudo ') || content.startsWith('pacman ') || content.startsWith('apt ')) return "command"
        return "text"
    }

    function formatTimestamp(timestamp) {
        const now = new Date()
        const entryDate = new Date(parseInt(timestamp))
        const diff = (now - entryDate) / 1000 // difference in seconds
        
        if (diff < 60) return "Just now"
        if (diff < 3600) return Math.floor(diff / 60) + " min ago"
        if (diff < 86400) return Math.floor(diff / 3600) + " hour" + (Math.floor(diff / 3600) === 1 ? "" : "s") + " ago"
        return Qt.formatDateTime(entryDate, "MMM d h:mm AP")
    }

    function clearClipboardHistory() {
        clearCliphistProcess.running = true
    }

    function deleteClipboardEntry(entryId) {
        deleteEntryProcess.entryId = entryId
        deleteEntryProcess.running = true
    }

    function refreshClipboardHistory() {
        // Don't clear the model immediately - let the smart update handle it
        cliphistProcess.running = true
    }

    function copyToClipboard(entryIdOrText, contentType) {
        if (contentType === "image" || typeof entryIdOrText === "string" && entryIdOrText.match(/^\d+$/)) {
            // This is an entry ID from clipboard history - use cliphist decode
            copyHistoryProcess.entryId = entryIdOrText
            copyHistoryProcess.running = true
        } else {
            // This is plain text content
            copyTextProcess.textToCopy = entryIdOrText
            copyTextProcess.running = true
        }
    }

    // Cleanup function
    Component.onDestruction: {
        cliphistProcess.running = false
        clearCliphistProcess.running = false
        deleteEntryProcess.running = false
        copyTextProcess.running = false
        copyHistoryProcess.running = false
    }

    Component.onCompleted: {
        refreshClipboardHistory()
    }
}