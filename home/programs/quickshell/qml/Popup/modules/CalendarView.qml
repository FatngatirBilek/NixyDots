import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/Data" as Data

Rectangle {
    property var shell
    
    radius: 20
    color: Qt.lighter(Data.Colors.bgColor, 1.2)

    readonly property date currentDate: new Date()
    readonly property int currentMonth: currentDate.getMonth()
    readonly property int currentYear: currentDate.getFullYear()
    readonly property int currentDay: currentDate.getDate()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            component NavButton: AbstractButton {
                property alias buttonText: buttonLabel.text
                implicitWidth: 30
                implicitHeight: 30
                
                background: Rectangle {
                    radius: 15
                    color: parent.down ? Qt.darker(Data.Colors.accentColor, 1.2) :
                           parent.hovered ? Qt.lighter(Data.Colors.highlightBg, 1.1) : Data.Colors.highlightBg
                }
                
                Text {
                    id: buttonLabel
                    anchors.centerIn: parent
                    color: Data.Colors.fgColor
                }
            }

            NavButton {
                buttonText: "‹"
                onClicked: {
                    if (calendar.month === 0) {
                        calendar.month = 11
                        calendar.year -= 1
                    } else {
                        calendar.month -= 1
                    }
                }
            }

            Text {
                text: Qt.locale("en_US").monthName(calendar.month) + " " + calendar.year
                color: Data.Colors.accentColor
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            NavButton {
                buttonText: "›"
                onClicked: {
                    if (calendar.month === 11) {
                        calendar.month = 0
                        calendar.year += 1
                    } else {
                        calendar.month += 1
                    }
                }
            }
        }

        Grid {
            columns: 7
            rowSpacing: 4
            columnSpacing: 0
            Layout.leftMargin: 2
            Layout.fillWidth: true

            Text { text: "M"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "T"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "W"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "T"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "F"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "S"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
            Text { text: "S"; color: Data.Colors.fgColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; width: parent.width / 7 }
        }

        MonthGrid {
            id: calendar
            month: currentMonth
            year: currentYear
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            leftPadding: 0
            rightPadding: 0
            locale: Qt.locale("de_DE")
            implicitHeight: 400

            delegate: Rectangle {
                width: 30
                height: 30
                radius: 15
                
                readonly property bool isCurrentMonth: model.month === calendar.month
                readonly property bool isToday: model.day === currentDay
                                              && model.month === currentMonth
                                              && calendar.year === currentYear
                                              && isCurrentMonth
                
                color: isToday ? Data.Colors.accentColor :
                      isCurrentMonth ? Data.Colors.highlightBg : Qt.darker(Data.Colors.highlightBg, 1.2)

                Text {
                    text: model.day
                    anchors.centerIn: parent
                    color: parent.isToday ? Data.Colors.bgColor :
                          parent.isCurrentMonth ? Data.Colors.fgColor : Qt.darker(Data.Colors.fgColor, 1.5)
                    font.bold: parent.isToday
                }
            }
        }

        AbstractButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            
            onClicked: {
                calendar.month = currentMonth
                calendar.year = currentYear
            }
            
            background: Rectangle {
                radius: 18
                color: parent.down ? Qt.darker(Data.Colors.accentColor, 1.2) :
                      parent.hovered ? Qt.lighter(Data.Colors.highlightBg, 1.1) : Data.Colors.highlightBg
            }
            
            Text {
                text: "Today"
                anchors.centerIn: parent
                color: Data.Colors.fgColor
            }
        }
    }
}