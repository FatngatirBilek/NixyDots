pragma Singleton

import Quickshell
import QtQuick
import qs.services

Singleton {
    id: root

    property bool loaded: false
    property string location: ""
    property string temperature: ""
    property string condition: ""
    property string icon: "sun"

    property var cc: null
    property var forecast: null

    property real cachedLat: 0
    property real cachedLon: 0
    property bool locationFetched: false

    property bool fetching: false
    property int retryCount: 0
    readonly property int maxRetries: 3
    readonly property int baseRetryDelayMs: 30000

    // WMO weather code → phosphor icon name
    readonly property var weatherIcons: ({
        0:  "sun",
        1:  "sun",
        2:  "cloud-sun",
        3:  "cloud",
        45: "cloud-fog",
        48: "cloud-fog",
        51: "cloud-rain",
        53: "cloud-rain",
        55: "cloud-rain",
        56: "cloud-snow",
        57: "cloud-snow",
        61: "cloud-rain",
        63: "cloud-rain",
        65: "cloud-rain",
        66: "cloud-snow",
        67: "cloud-snow",
        71: "cloud-snow",
        73: "cloud-snow",
        75: "cloud-snow",
        77: "cloud-snow",
        80: "cloud-rain",
        81: "cloud-rain",
        82: "cloud-rain",
        85: "cloud-snow",
        86: "cloud-snow",
        95: "cloud-lightning",
        96: "cloud-lightning",
        99: "cloud-lightning"
    })

    // WMO weather code → human-readable description
    readonly property var weatherDescriptions: ({
        0:  "Clear sky",
        1:  "Mainly clear",
        2:  "Partly cloudy",
        3:  "Overcast",
        45: "Fog",
        48: "Icy fog",
        51: "Light drizzle",
        53: "Drizzle",
        55: "Heavy drizzle",
        56: "Light freezing drizzle",
        57: "Freezing drizzle",
        61: "Light rain",
        63: "Rain",
        65: "Heavy rain",
        66: "Light freezing rain",
        67: "Freezing rain",
        71: "Light snow",
        73: "Snow",
        75: "Heavy snow",
        77: "Snow grains",
        80: "Light showers",
        81: "Showers",
        82: "Heavy showers",
        85: "Light snow showers",
        86: "Snow showers",
        95: "Thunderstorm",
        96: "Thunderstorm w/ hail",
        99: "Thunderstorm w/ heavy hail"
    })

    function getWeatherIcon(code) {
        if (code === null || code === undefined) return "sun"
        const icon = root.weatherIcons[code]
        return icon !== undefined ? icon : "sun"
    }

    function getWeatherDescription(code) {
        if (code === null || code === undefined) return "Unknown"
        const desc = root.weatherDescriptions[code]
        return desc !== undefined ? desc : "Unknown"
    }

    function scheduleRetry(): void {
        if (root.retryCount >= root.maxRetries) {
            console.warn("[WEATHER] giving up after " + root.maxRetries + " retries")
            root.fetching = false
            root.retryCount = 0
            return
        }

        const delay = root.baseRetryDelayMs * Math.pow(2, root.retryCount)
        root.retryCount += 1
        console.log("[WEATHER] retry " + root.retryCount + "/" + root.maxRetries + " in " + (delay / 1000) + "s")
        retryTimer.interval = delay
        retryTimer.restart()
    }

    function reload(): void {
        if (root.fetching) return

        root.fetching = true
        root.retryCount = 0

        if (root.locationFetched) {
            fetchWeather(root.cachedLat, root.cachedLon)
            return
        }

        // Step 1: resolve lat/lon + city name via ipinfo.io (no API key needed)
        Requests.get("https://ipinfo.io/json", function(text) {
            try {
                const parsed = JSON.parse(text)
                if (parsed === null || parsed === undefined) {
                    console.warn("[WEATHER] ipinfo.io returned null")
                    root.scheduleRetry()
                    return
                }

                if (parsed.city !== null && parsed.city !== undefined)
                    root.location = parsed.city

                // "loc" field is "lat,lon"
                const locStr = parsed.loc
                if (locStr === null || locStr === undefined || locStr === "") {
                    console.warn("[WEATHER] ipinfo.io returned no loc field")
                    root.scheduleRetry()
                    return
                }

                const parts = locStr.split(",")
                if (parts.length < 2) {
                    console.warn("[WEATHER] could not parse loc: " + locStr)
                    root.scheduleRetry()
                    return
                }

                root.cachedLat = parseFloat(parts[0])
                root.cachedLon = parseFloat(parts[1])
                root.locationFetched = true

                fetchWeather(root.cachedLat, root.cachedLon)
            } catch (e) {
                console.warn("[WEATHER] failed to parse ipinfo.io response: " + e)
                root.fetching = false
                root.scheduleRetry()
            }
        }, function(_reason) {
            console.warn("[WEATHER] ipinfo.io request failed: " + _reason)
            root.scheduleRetry()
        })
    }

    function fetchWeather(lat: real, lon: real): void {
        // Open-Meteo: free, no API key, reliable
        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + lat
            + "&longitude=" + lon
            + "&current=temperature_2m,weather_code"
            + "&temperature_unit=celsius"
            + "&forecast_days=1"

        Requests.get(url, function(text) {
            root.fetching = false
            root.retryCount = 0

            try {
                const json = JSON.parse(text)
                if (json === null || json === undefined) {
                    console.warn("[WEATHER] Open-Meteo returned null")
                    return
                }

                const current = json.current
                if (current === null || current === undefined) {
                    console.warn("[WEATHER] Open-Meteo response has no 'current' field")
                    return
                }

                const tempRaw = current.temperature_2m
                root.temperature = tempRaw !== null && tempRaw !== undefined
                    ? Math.round(tempRaw).toString()
                    : "0"

                const code = current.weather_code
                root.condition = root.getWeatherDescription(code)
                root.icon      = root.getWeatherIcon(code)

                root.cc       = current
                root.forecast = json.daily !== undefined ? json.daily : null
                root.loaded   = true

                console.log("[WEATHER] loaded — " + root.temperature + "° " + root.condition + " @ " + root.location)
            } catch (e) {
                console.warn("[WEATHER] failed to parse Open-Meteo response: " + e)
            }
        }, function(_reason) {
            console.warn("[WEATHER] Open-Meteo request failed: " + _reason)
            root.fetching = false
            root.scheduleRetry()
        })
    }

    // Delay initial fetch so the network stack has time to come up
    Timer {
        id: startupTimer
        interval: 5000
        running: true
        repeat: false
        onTriggered: root.reload()
    }

    Timer {
        id: retryTimer
        running: false
        repeat: false
        onTriggered: {
            root.fetching = false
            root.reload()
        }
    }

    // Refresh every 15 minutes
    Timer {
        interval: 900000
        running: true
        repeat: true
        onTriggered: root.reload()
    }
}
