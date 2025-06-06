import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/Data" as Data

Rectangle {
    color: Qt.lighter(Data.Colors.bgColor, 1.2)
    radius: 20

    readonly property var weatherEmojiMap: ({
        "clear": "☀️",
        "mainly clear": "🌤️", 
        "partly cloudy": "⛅",
        "cloud": "☁️",
        "overcast": "☁️",
        "fog": "🌫️",
        "mist": "🌫️",
        "drizzle": "🌦️",
        "rain": "🌧️",
        "showers": "🌧️",
        "freezing rain": "🌧️❄️",
        "snow": "❄️",
        "snow grains": "❄️",
        "snow showers": "❄️",
        "thunderstorm": "⛈️",
        "wind": "🌬️"
    })

    function getWeatherEmoji(condition) {
        if (!condition) return "❓"
        
        const lowerCondition = condition.toLowerCase()
        
        // Check for exact matches first (most efficient)
        if (weatherEmojiMap[lowerCondition]) {
            return weatherEmojiMap[lowerCondition]
        }
        
        // Check for partial matches
        for (const key in weatherEmojiMap) {
            if (lowerCondition.includes(key)) {
                return weatherEmojiMap[key]
            }
        }
        
        return "❓"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Location header
        Label {
            text: weatherLoading ? "Loading weather..." : "Weather"
            color: Data.Colors.accentColor
            font {
                pixelSize: 18
                bold: true
                family: "FiraCode Nerd Font"
            }
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Current weather
        ColumnLayout {
            spacing: 8
            Layout.alignment: Qt.AlignHCenter

            RowLayout {
                spacing: 16
                Layout.alignment: Qt.AlignHCenter

                Label {
                    text: weatherLoading ? "⏳" : getWeatherEmoji((weatherData && weatherData.currentCondition) || "?")
                    font.pixelSize: 48
                    color: Data.Colors.fgColor
                }

                Label {
                    text: weatherLoading ? "..." : ((weatherData && weatherData.currentTemp) || "?")
                    font {
                        pixelSize: 24
                        bold: true
                        family: "FiraCode Nerd Font"
                    }
                    color: Data.Colors.fgColor
                }
            }

            // Current weather details
            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 8
                Layout.alignment: Qt.AlignHCenter
                visible: !weatherLoading && weatherData && weatherData.details && weatherData.details.length > 0

                Repeater {
                    model: weatherLoading ? 0 : (weatherData && weatherData.details ? weatherData.details.length : 0)
                    delegate: RowLayout {
                        spacing: 8
                        
                        property var detailItem: weatherData && weatherData.details ? weatherData.details[index] : ""
                        property var detailParts: detailItem ? detailItem.split(":") : ["", ""]
                        
                        Label {
                            text: detailParts[0] + ":"
                            color: Qt.lighter(Data.Colors.fgColor, 1.2)
                            font {
                                pixelSize: 12
                                bold: true
                            }
                        }
                        Label {
                            text: detailParts[1] || ""
                            color: Data.Colors.fgColor
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // 3-Day Forecast
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            visible: !weatherLoading
     
            Label {
                text: "3-Day Forecast"
                color: Data.Colors.accentColor
                font {
                    pixelSize: 14
                    bold: true
                    family: "FiraCode Nerd Font"
                }
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
     
            // Forecast days
            GridLayout {
                columns: 3
                columnSpacing: 70
                Layout.alignment: Qt.AlignHCenter
     
                Repeater {
                    model: weatherLoading ? 0 : (weatherData && weatherData.forecast ? Math.min(3, weatherData.forecast.length) : 0)
                    delegate: ColumnLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignHCenter
                        
                        property var forecastItem: weatherData && weatherData.forecast ? weatherData.forecast[index] : null
     
                        // Day name
                        Label {
                            text: forecastItem ? forecastItem.dayName : "?"
                            color: Data.Colors.fgColor
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }
     
                        // Weather emoji
                        Label {
                            text: forecastItem ? getWeatherEmoji(forecastItem.condition) : "?"
                            font.pixelSize: 32
                            color: Data.Colors.fgColor
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }
     
                        // Temperature
                        Label {
                            text: {
                                if (!forecastItem) return "?"
                                
                                if (forecastItem.temp !== undefined) {
                                    return forecastItem.temp + "°C"
                                }
                                
                                if (forecastItem.minTemp !== undefined && forecastItem.maxTemp !== undefined) {
                                    return forecastItem.minTemp + "°C / " + forecastItem.maxTemp + "°C"
                                }
                                
                                return "?"
                            }
                            font.pixelSize: 12
                            color: Data.Colors.fgColor
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}