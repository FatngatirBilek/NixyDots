import QtQuick

Item {
    id: service
    
    property var shell
    
    property int activeRequests: 0
    property int maxConcurrentRequests: 2
    
    property var cachedWeatherData: null
    property var lastFetchTime: 0
    property int cacheTimeoutMs: 600000 // 10 minutes
    
    function mapWeatherCode(code) {
        const weatherCodes = {
            0: "Clear sky",
            1: "Mainly clear", 
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog", 
            48: "Depositing rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            56: "Light freezing drizzle",
            57: "Dense freezing drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            66: "Light freezing rain",
            67: "Heavy freezing rain",
            71: "Slight snow fall",
            73: "Moderate snow fall",
            75: "Heavy snow fall",
            77: "Snow grains",
            80: "Slight rain showers",
            81: "Moderate rain showers",
            82: "Violent rain showers",
            85: "Slight snow showers",
            86: "Heavy snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail"
        }
        
        return weatherCodes[code] || "Unknown"
    }

    function loadWeather() {
        // Check cache first
        const now = Date.now()
        if (cachedWeatherData && (now - lastFetchTime) < cacheTimeoutMs) {
            console.log("Using cached weather data")
            shell.weatherData = cachedWeatherData
            shell.weatherLoading = false
            return
        }
        
        // Prevent too many concurrent requests
        if (activeRequests >= maxConcurrentRequests) {
            console.log("Too many active weather requests, skipping")
            return
        }
        
        shell.weatherLoading = true
        activeRequests++

        const geocodeXhr = new XMLHttpRequest()
        const geocodeUrl = "https://nominatim.openstreetmap.org/search?format=json&limit=1&q=" + encodeURIComponent(shell.weatherLocation)

        // Set timeout to prevent hanging requests
        geocodeXhr.timeout = 10000 // 10 seconds

        geocodeXhr.onreadystatechange = function() {
            if (geocodeXhr.readyState === XMLHttpRequest.DONE) {
                activeRequests--
                
                if (geocodeXhr.status === 200) {
                    try {
                        const geoData = JSON.parse(geocodeXhr.responseText)
                        
                        if (geoData.length > 0) {
                            const latitude = parseFloat(geoData[0].lat)
                            const longitude = parseFloat(geoData[0].lon)
                            fetchWeather(latitude, longitude)
                        } else {
                            fallbackWeatherData("City not found")
                        }
                    } catch (e) {
                        console.error("Geocoding JSON parse error:", e)
                        fallbackWeatherData("Geocode parse error")
                    }
                } else {
                    console.error("Geocoding API error:", geocodeXhr.status)
                    fallbackWeatherData("Geocode service unavailable")
                }
            }
        }

        geocodeXhr.ontimeout = function() {
            activeRequests--
            fallbackWeatherData("Request timeout")
        }

        geocodeXhr.onerror = function() {
            activeRequests--
            fallbackWeatherData("Network error")
        }

        geocodeXhr.open("GET", geocodeUrl)
        geocodeXhr.setRequestHeader("User-Agent", "StatusBar_Ly-sec/1.0")
        geocodeXhr.send()
    }

    function fetchWeather(latitude, longitude) {
        if (activeRequests >= maxConcurrentRequests) {
            fallbackWeatherData("Too many requests")
            return
        }
        
        activeRequests++
        
        const xhr = new XMLHttpRequest()
        const url = "https://api.open-meteo.com/v1/forecast?" +
                  "latitude=" + latitude +
                  "&longitude=" + longitude +
                  "&current_weather=true" +
                  "&daily=temperature_2m_max,temperature_2m_min,weathercode" +
                  "&forecast_days=3" +
                  "&timezone=auto"

        xhr.timeout = 15000 // 15 seconds

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                activeRequests--
                shell.weatherLoading = false
                
                if (xhr.status === 200) {
                    try {
                        const data = JSON.parse(xhr.responseText)
                        const current = data.current_weather
                        const daily = data.daily

                        const currentTempFormatted = Math.round(parseFloat(current.temperature)) + "°C"

                        // Pre-allocate array for better performance
                        const forecast = new Array(3)
                        const today = new Date()
                        
                        for (let i = 0; i < 3; i++) {
                            let dayName
                            if (i === 0) {
                                dayName = "Today"
                            } else if (i === 1) {
                                dayName = "Tomorrow"  
                            } else {
                                const futureDate = new Date(today)
                                futureDate.setDate(today.getDate() + i)
                                dayName = Qt.formatDate(futureDate, "ddd MMM d")
                            }
                            
                            forecast[i] = {
                                dayName: dayName,
                                condition: mapWeatherCode(daily.weathercode[i]),
                                minTemp: Math.round(parseFloat(daily.temperature_2m_min[i])),
                                maxTemp: Math.round(parseFloat(daily.temperature_2m_max[i]))
                            }
                        }

                        const weatherData = {
                            location: shell.weatherLocation || "Current Location",
                            currentTemp: currentTempFormatted,
                            currentCondition: mapWeatherCode(current.weathercode),
                            details: [
                                "Wind: " + current.windspeed + " km/h",
                                "Direction: " + current.winddirection + "°"
                            ],
                            forecast: forecast
                        }
                        
                        // Cache the data
                        cachedWeatherData = weatherData
                        lastFetchTime = Date.now()
                        shell.weatherData = weatherData
                        
                    } catch (e) {
                        console.error("Weather JSON parse error:", e)
                        fallbackWeatherData("Weather data error")
                    }
                } else {
                    console.error("Weather API error:", xhr.status)
                    fallbackWeatherData("Weather service unavailable")
                }
            }
        }

        xhr.ontimeout = function() {
            activeRequests--
            shell.weatherLoading = false
            fallbackWeatherData("Request timeout")
        }

        xhr.onerror = function() {
            activeRequests--
            shell.weatherLoading = false
            fallbackWeatherData("Network error")
        }

        xhr.open("GET", url)
        xhr.setRequestHeader("User-Agent", "StatusBar_Ly-sec/1.0")
        xhr.send()
    }

    function fallbackWeatherData(message) {
        shell.weatherLoading = false
        
        const fallbackData = {
            location: message,
            currentTemp: "?",
            currentCondition: "?",
            details: [],
            forecast: [
                {dayName: "Today", condition: "?", minTemp: "?", maxTemp: "?"},
                {dayName: "Tomorrow", condition: "?", minTemp: "?", maxTemp: "?"},
                {dayName: "?", condition: "?", minTemp: "?", maxTemp: "?"}
            ]
        }
        
        shell.weatherData = fallbackData
    }
    
    // Cleanup on destruction
    Component.onDestruction: {
        cachedWeatherData = null
    }
}