import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import "root:/Data" as Data

Rectangle {
    required property var shell
    
    color: Qt.lighter(Data.Colors.bgColor, 1.2)
    radius: 20

    Component.onCompleted: {
        // Set monitoring intervals from settings
        Data.ProcessManager.setMonitoringInterval(Math.min(Data.Settings.cpuRefreshInterval, Data.Settings.ramRefreshInterval))
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Label {
            text: "Resource Monitor"
            color: Data.Colors.accentColor
            font {
                pixelSize: 18
                bold: true
                family: "FiraCode Nerd Font"
            }
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8
        }

        // CPU Usage Bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                
                Label {
                    text: "󰻠 CPU"
                    color: Data.Colors.fgColor
                    font {
                        pixelSize: 14
                        family: "FiraCode Nerd Font"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: Data.ProcessManager.getCpuUsageFormatted()
                    color: Data.Colors.fgColor
                    font {
                        pixelSize: 14
                        family: "FiraCode Nerd Font"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: Qt.darker(Data.Colors.highlightBg, 1.3)
                border.width: 1
                border.color: Qt.darker(Data.Colors.highlightBg, 1.5)

                Rectangle {
                    width: parent.width * (Data.ProcessManager.cpuUsage / 100)
                    height: parent.height
                    radius: 4
                    color: Data.ProcessManager.cpuUsage > 80 ? "#e74c3c" : Data.ProcessManager.cpuUsage > 60 ? "#f39c12" : "#27ae60"
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }

        // RAM Usage Bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                
                Label {
                    text: "󰍛 RAM"
                    color: Data.Colors.fgColor
                    font {
                        pixelSize: 14
                        family: "FiraCode Nerd Font"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: Data.ProcessManager.getRamUsageFormatted()
                    color: Data.Colors.fgColor
                    font {
                        pixelSize: 14
                        family: "FiraCode Nerd Font"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: Qt.darker(Data.Colors.highlightBg, 1.3)
                border.width: 1
                border.color: Qt.darker(Data.Colors.highlightBg, 1.5)

                Rectangle {
                    width: parent.width * (Data.ProcessManager.ramUsage / 100)
                    height: parent.height
                    radius: 4
                    color: Data.ProcessManager.ramUsage > 80 ? "#e74c3c" : Data.ProcessManager.ramUsage > 60 ? "#f39c12" : "#3498db"
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }

    }
}