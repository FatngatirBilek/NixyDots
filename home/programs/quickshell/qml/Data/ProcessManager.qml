pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    
    // System monitoring properties
    property real cpuUsage: 0
    property real ramUsage: 0
    property real totalRam: 0
    property real usedRam: 0
    
    // Individual process objects as properties
    property Process shutdownProcess: Process {
        command: ["shutdown", "-h", "now"]
    }
    
    property Process rebootProcess: Process {
        command: ["reboot"]
    }
    
    property Process lockProcess: Process {
        command: ["hyprlock"]
    }
    
    property Process logoutProcess: Process {
        command: ["loginctl", "terminate-user", "$USER"]
    }
    
    property Process pavucontrolProcess: Process {
        command: ["pavucontrol"]
    }
    
    // System monitoring processes
    property Process cpuProcess: Process {
        command: ["sh", "-c", "grep '^cpu ' /proc/stat | awk '{usage=($2+$3+$4)*100/($2+$3+$4+$5)} END {print usage}'"]
        stdout: SplitParser {
            onRead: data => {
                root.cpuUsage = parseFloat(data)
            }
        }
    }
    
    property Process ramProcess: Process {
        command: ["sh", "-c", "free -b | awk '/Mem:/ {print $2\" \"$3\" \"$3/$2*100}'"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                if (parts.length >= 3) {
                    root.totalRam = parseFloat(parts[0]) / (1024 * 1024 * 1024)
                    root.usedRam = parseFloat(parts[1]) / (1024 * 1024 * 1024)
                    root.ramUsage = parseFloat(parts[2])
                }
            }
        }
    }
    
    // Monitoring timers
    property Timer cpuTimer: Timer {
        interval: 2000 // 2 seconds default, can be overridden
        running: true
        repeat: true
        onTriggered: {
            // Restart the process to get fresh data
            cpuProcess.running = false
            cpuProcess.running = true
        }
    }
    
    property Timer ramTimer: Timer {
        interval: 2000 // 2 seconds default, can be overridden
        running: true
        repeat: true
        onTriggered: {
            // Restart the process to get fresh data
            ramProcess.running = false
            ramProcess.running = true
        }
    }
    
    // Convenience methods for common system commands
    function shutdown() {
        console.log("Executing shutdown command")
        shutdownProcess.running = true
    }
    
    function reboot() {
        console.log("Executing reboot command")
        rebootProcess.running = true
    }
    
    function lock() {
        console.log("Executing lock command")
        lockProcess.running = true
    }
    
    function logout() {
        console.log("Executing logout command")
        logoutProcess.running = true
    }
    
    function openPavuControl() {
        console.log("Opening PavuControl")
        pavucontrolProcess.running = true
    }
    
    // System monitoring control methods
    function startMonitoring() {
        console.log("Starting system monitoring")
        cpuTimer.running = true
        ramTimer.running = true
    }
    
    function stopMonitoring() {
        console.log("Stopping system monitoring")
        cpuTimer.running = false
        ramTimer.running = false
    }
    
    function setMonitoringInterval(intervalMs) {
        console.log("Setting monitoring interval to", intervalMs, "ms")
        cpuTimer.interval = intervalMs
        ramTimer.interval = intervalMs
    }
    
    function refreshSystemStats() {
        console.log("Manually refreshing system stats")
        // Restart processes to get fresh data
        cpuProcess.running = false
        cpuProcess.running = true
        ramProcess.running = false
        ramProcess.running = true
    }
    
    // Check if a process is running
    function isShutdownRunning() { return shutdownProcess.running }
    function isRebootRunning() { return rebootProcess.running }
    function isLockRunning() { return lockProcess.running }
    function isLogoutRunning() { return logoutProcess.running }
    function isPavuControlRunning() { return pavucontrolProcess.running }
    function isMonitoringActive() { return cpuTimer.running && ramTimer.running }
    
    // Stop processes (mainly useful for long-running ones)
    function stopPavuControl() {
        pavucontrolProcess.running = false
    }
    
    // System stats getters with formatted output
    function getCpuUsageFormatted() {
        return Math.round(cpuUsage) + "%"
    }
    
    function getRamUsageFormatted() {
        return Math.round(ramUsage) + "% (" + usedRam.toFixed(1) + "GB/" + totalRam.toFixed(1) + "GB)"
    }
    
    function getRamUsageSimple() {
        return Math.round(ramUsage) + "%"
    }
}