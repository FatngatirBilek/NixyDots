import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Column {
    required property var shell
    
    width: 80
    spacing: 2
    Layout.alignment: Qt.AlignVCenter

    Label {
        id: timeLabel
        width: parent.width
        text: shell.time
        color: shell.accentColor
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        // Subtle pulse animation every minute
        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation {
                to: 1.02
                duration: 60000 // 1 minute
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
            PauseAnimation { duration: 59800 }
        }
    }

    Label {
        width: parent.width
        text: shell.date
        color: Qt.lighter(shell.fgColor, 1.2)
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        // Fade in animation
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutCubic
            }
        }
    }
}