import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "root:/Data" as Data
import "root:/HotCorner/modules" as Modules

Item {
    required property var shell

    anchors.fill: parent

    // Recording state management
    property bool isRecording: false
    property var recordingProcess: null
    property string lastError: ""
    
    // Signal to communicate SlideBar visibility changes
    signal slideBarVisibilityChanged(bool visible)
    
    // Function to trigger hot corner (can be called externally)
    function triggerHotCorner() {
        slideBar.show()
    }

    // Hot corner trigger - always in the corner
    Modules.HotCornerTrigger {
        id: hotCorner
        onTriggered: triggerHotCorner()
    }

    // The main sliding bar - positioned relative to screen edge, not parent
    Modules.SlideBar {
        id: slideBar
        shell: parent.shell
        isRecording: parent.isRecording
        
        // Position relative to the parent (hot corner window)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8
        
        // Monitor visibility changes
        onVisibleChanged: {
            slideBarVisibilityChanged(visible)
        }
        
        onRecordingRequested: startRecording()
        onStopRecordingRequested: {
            stopRecording()
            slideBar.hide()
        }
        onSystemActionRequested: function(action) {
            performSystemAction(action)
            slideBar.hide()
        }
        onPerformanceActionRequested: function(action) {
            performPerformanceAction(action)
            slideBar.hide()
        }
    }

    // Recording management functions
    function startRecording() {
        var currentDate = new Date()
        var hours = String(currentDate.getHours()).padStart(2, '0')
        var minutes = String(currentDate.getMinutes()).padStart(2, '0')
        var day = String(currentDate.getDate()).padStart(2, '0')
        var month = String(currentDate.getMonth() + 1).padStart(2, '0')
        var year = currentDate.getFullYear()
        
        var filename = hours + "-" + minutes + "-" + day + "-" + month + "-" + year + ".mp4"
        var outputPath = Data.Settings.videoPath + filename
        var command = "gpu-screen-recorder -w portal -f 60 -a default_output -o " + outputPath
        
        var qmlString = 'import Quickshell.Io; Process { command: ["sh", "-c", "' + command + '"]; running: true; onExited: function(exitCode, exitStatus) { console.log("Recording process exited with code:", exitCode) } }'
        
        recordingProcess = Qt.createQmlObject(qmlString, parent)
        isRecording = true
    }
    
    function stopRecording() {
        if (recordingProcess && isRecording) {
            console.log("Stopping recording")
            
            var stopQmlString = 'import Quickshell.Io; Process { command: ["sh", "-c", "pkill -SIGINT -f \'gpu-screen-recorder.*portal\'"]; running: true; onExited: function(exitCode, exitStatus) { console.log("Stop signal sent, exit code:", exitCode); destroy() } }'
            
            var stopProcess = Qt.createQmlObject(stopQmlString, parent)
            
            var cleanupTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 3000; running: true; repeat: false }', parent)
            cleanupTimer.triggered.connect(function() {
                console.log("Cleaning up recording process")
                if (recordingProcess) {
                    recordingProcess.running = false
                    recordingProcess.destroy()
                    recordingProcess = null
                }
                
                var forceKillQml = 'import Quickshell.Io; Process { command: ["sh", "-c", "pkill -9 -f \'gpu-screen-recorder.*portal\' 2>/dev/null || true"]; running: true; onExited: function() { destroy() } }'
                var forceKillProcess = Qt.createQmlObject(forceKillQml, parent)
                
                cleanupTimer.destroy()
            })
        }
        isRecording = false
    }

    function performSystemAction(action) {
        switch(action) {
            case "lock":
                Data.ProcessManager.lock()
                break
            case "reboot":
                Data.ProcessManager.reboot()
                break
            case "shutdown":
                Data.ProcessManager.shutdown()
                break
        }
    }
    
    function performPerformanceAction(action) {
        // Add performance action handling here if needed
        console.log("Performance action requested:", action)
    }
}