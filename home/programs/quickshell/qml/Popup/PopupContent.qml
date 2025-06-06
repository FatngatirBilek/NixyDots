import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import "./modules" as PopupModules

Item {
    required property var shell
    property string selectedWidget: "calendar"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            StackLayout {
                anchors.fill: parent
                currentIndex: {
                    switch(selectedWidget) {
                    case "calendar": return 0
                    case "weather": return 1
                    case "system": return 2
                    default: return 0
                    }
                }
                
                // Use the component files directly
                PopupModules.CalendarView { 
                    readonly property var shell: parent.shell
                }
                PopupModules.WeatherView { 
                    readonly property var shell: parent.shell
                }
                PopupModules.SystemView { 
                    readonly property var shell: parent.shell
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.alignment: Qt.AlignHCenter
            
            Repeater {
                model: ["calendar", "weather", "system"]
                delegate: Button {
                    checkable: true
                    checked: selectedWidget === modelData
                    onClicked: selectedWidget = modelData
                    implicitWidth: 30
                    implicitHeight: 30
                    
                    background: Rectangle {
                        radius: 20
                        color: parent.down ? Qt.darker(shell.accentColor, 1.2) :
                               parent.hovered ? Qt.lighter(shell.highlightBg, 1.1) : shell.highlightBg
                    }
                    
                    contentItem: Label {
                        text: parent.checked ? "●" : "○"
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: parent.checked ? 14 : 18
                        color: parent.checked ? shell.accentColor : shell.fgColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}