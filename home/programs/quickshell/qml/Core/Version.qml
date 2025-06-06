import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// System info watermark component
PanelWindow {
    id: systemVersion

    anchors {
        right: true
        bottom: true
    }

    margins {
        right: 60
        bottom: 60
    }
    visible: false
    
    implicitWidth: systemInfoContent.width
    implicitHeight: systemInfoContent.height

    color: "transparent"

    mask: Region {}

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer {
        id: startupTimer
        interval: 1500
        running: true
        onTriggered: {
            visible = true
            console.log("SystemVersion window now visible after delay")
        }
    }

    // System Info Data
    component Details: QtObject {
        property string version
        property string commit
    }

    property QtObject os: QtObject {
        property string name: "Loading..."
        property Details details: Details {
            property string generation: "?"
        }
    }

    property QtObject wm: QtObject {
        property string name: "Loading..."
        property Details details: Details {}
    }

    // Component initialization
    Component.onCompleted: {
        console.log("SystemVersion component loaded");
        osFile.reload();
        genProcess.running = true;
        wmProcess.running = true;
        hlProcess.running = true;
    }

    Timer {
        running: true
        interval: 60000
        repeat: true
        onTriggered: {
            osFile.reload();
            genProcess.running = true;
            wmProcess.running = true;
            hlProcess.running = true;
        }
    }

    FileView {
        id: osFile
        path: "/etc/os-release"

        onLoaded: {
            const data = text().trim().split("\n");
            
            const nameLine = data.find((str) => str.match(/^NAME=/));
            const versionLine = data.find((str) => str.match(/^VERSION_ID=/));
            const buildLine = data.find((str) => str.match(/^BUILD_ID=/));
            
            if (nameLine) {
                systemVersion.os.name = nameLine.split("=")[1].replace(/"/g, "");
            }
            if (versionLine) {
                systemVersion.os.details.version = versionLine.split("=")[1].replace(/"/g, "");
            }
            if (buildLine) {
                const commit = buildLine.split("=")[1].split(".")[3];
                if (commit) {
                    systemVersion.os.details.commit = commit.replace(/"/g, "").toUpperCase();
                }
            }
        }
    }

    Process {
        id: genProcess
        running: true
        command: ["sh", "-c", "nixos-rebuild list-generations"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: (data) => {
                const line = data.trim().split("\n").find((str) => str.match(/current/));
                if (line) {
                    const current = line.split(" ")[0];
                    systemVersion.os.details.generation = current;
                }
            }
        }
    }

    Process {
        id: wmProcess
        running: true
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: (data) => {
                const result = data.trim();
                if (result && result !== "") {
                    systemVersion.wm.name = result;
                }
            }
        }
    }

Process {
    id: hlProcess
    running: true
    command: ["sh", "-c", "hyprctl version"]

    stdout: SplitParser {
        splitMarker: ""
        onRead: (data) => {
            const output = data.trim();
            
            // Extract version
            const versionMatch = output.match(/Tag: (v\d+\.\d+\.\d+)/);
            if (versionMatch && versionMatch[1]) {
                systemVersion.wm.details.version = versionMatch[1];
            }
            
            // Extract commit hash
            const commitMatch = output.match(/at commit (\w+)/);
            if (commitMatch && commitMatch[1]) {
                systemVersion.wm.details.commit = commitMatch[1].slice(0, 7).toUpperCase();
            }
        }
    }
}

    ColumnLayout {
        id: systemInfoContent
        spacing: 6
        
        // Main system info row
        RowLayout {
            spacing: 16
            Layout.alignment: Qt.AlignRight
            
            // OS Section
            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight
                
                Text {
                    text: systemVersion.os.name
                    color: "#70ffffff"
                    font.family: "SF Pro Display, -apple-system, system-ui, sans-serif"
                    font.pointSize: 16
                    font.weight: Font.DemiBold
                    font.letterSpacing: -0.4
                    Layout.alignment: Qt.AlignRight
                }

                Text {
                    text: {
                        let details = [];
                        if (systemVersion.os.details.version) {
                            details.push(systemVersion.os.details.version);
                        }
                        if (systemVersion.os.details.commit) {
                            details.push("(" + systemVersion.os.details.commit + ")");
                        }
                        if (systemVersion.os.details.generation && systemVersion.os.details.generation !== "?") {
                            details.push("Gen " + systemVersion.os.details.generation);
                        }
                        return details.join(" ");
                    }
                    color: "#50ffffff"
                    font.family: "SF Mono, Consolas, Monaco, monospace"
                    font.pointSize: 10
                    font.weight: Font.Medium
                    visible: text.length > 0
                    Layout.alignment: Qt.AlignRight
                }
            }
            
            Text {
                text: "│"
                color: "#40ffffff"
                font.family: "SF Pro Display, -apple-system, system-ui, sans-serif"
                font.pointSize: 14
                font.weight: Font.Light
                Layout.alignment: Qt.AlignCenter
            }
            
            // WM Section
            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight
                
                Text {
                    text: systemVersion.wm.name
                    color: "#70ffffff"
                    font.family: "SF Pro Display, -apple-system, system-ui, sans-serif"
                    font.pointSize: 16
                    font.weight: Font.DemiBold
                    font.letterSpacing: -0.4
                    Layout.alignment: Qt.AlignRight
                }

                Text {
                    text: {
                        let details = [];
                        if (systemVersion.wm.details.version) {
                            details.push(systemVersion.wm.details.version);
                        }
                        if (systemVersion.wm.details.commit) {
                            details.push("(" + systemVersion.wm.details.commit + ")");
                        }
                        return details.join(" ");
                    }
                    color: "#50ffffff"
                    font.family: "SF Mono, Consolas, Monaco, monospace"
                    font.pointSize: 10
                    font.weight: Font.Medium
                    visible: text.length > 0
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}