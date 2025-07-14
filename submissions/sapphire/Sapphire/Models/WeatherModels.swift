//
//  WeatherModels.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import Foundation


struct WeatherApiResponse: Codable {
    var conditionsshort: ConditionsShort?
    var fcstdaily10short: FcstDaily10Short?
    var fcsthourly24short: FcstHourly24Short?
    var nowlinks: Nowlinks?
}

struct ConditionsShort: Codable {
    var observation: Observation?
}

struct Observation: Codable {
    var imperial: ImperialObservation?
    var metric: ImperialObservation?
    var wx_phrase: String?
    var wx_icon: Int?
    var rh: Int?
    var uv_index: Int?
    var uv_desc: String?
    var vis: Double?
    var pressure: Double?
}

struct ImperialObservation: Codable {
    var temp: Int?
    var feels_like: Int?
    var wspd: Int?
}

struct FcstDaily10Short: Codable {
    var forecasts: [DailyForecast]?
}

struct DailyForecast: Codable {
    var dow: String?
    var imperial: ImperialForecast?
    var metric: ImperialForecast?
    var day: DayPart?
    var night: DayPart?
    var sunrise: String?
    var sunset: String?
}

struct ImperialForecast: Codable {
    var max_temp: Int?
    var min_temp: Int?
}

struct DayPart: Codable {
    var icon_cd: Int?
    var pop: Int?
}

struct FcstHourly24Short: Codable {
    var forecasts: [HourlyForecast]?
}

struct HourlyForecast: Codable {
    var fcst_valid: Int?
    var icon_cd: Int?
    var imperial: ImperialHourlyForecast?
    var metric: ImperialHourlyForecast?
}

struct ImperialHourlyForecast: Codable {
    var temp: Int?
}

struct Nowlinks: Codable {
    var nowlink: [Nowlink]?
}

struct Nowlink: Codable {
    var url: String?
}


struct ProcessedWeatherData: Hashable {
    let locationName: String
    let temperature: Int
    let temperatureMetric: Int
    let highTemp: Int
    let highTempMetric: Int
    let lowTemp: Int
    let lowTempMetric: Int
    let conditionDescription: String
    let iconCode: Int
    let feelsLike: Int
    let feelsLikeMetric: Int
    let windInfo: String
    let humidity: String
    let precipChance: Int
    let uvIndex: String
    let sunriseTime: String
    let sunsetTime: String
    let visibility: String
    let pressure: String
    let dailyForecasts: [DailyForecastUIData]
    let hourlyForecasts: [HourlyForecastUIData]

    static func empty() -> ProcessedWeatherData {
        .init(locationName: "N/A", temperature: 0, temperatureMetric: 0, highTemp: 0, highTempMetric: 0, lowTemp: 0, lowTempMetric: 0, conditionDescription: "N/A", iconCode: 44, feelsLike: 0, feelsLikeMetric: 0, windInfo: "N/A", humidity: "N/A", precipChance: 0, uvIndex: "N/A", sunriseTime: "N/A", sunsetTime: "N/A", visibility: "N/A", pressure: "N/A", dailyForecasts: [], hourlyForecasts: [])
    }
}

struct DailyForecastUIData: Identifiable, Hashable {
    let id = UUID()
    let dayOfWeek: String
    let iconName: String
    let highTemp: Int
    let lowTemp: Int
    let highTempMetric: Int
    let lowTempMetric: Int

    static func == (lhs: DailyForecastUIData, rhs: DailyForecastUIData) -> Bool {
        lhs.dayOfWeek == rhs.dayOfWeek
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dayOfWeek)
    }
}

struct HourlyForecastUIData: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let iconName: String
    let temperature: String
    let temperatureMetric: String

    static func == (lhs: HourlyForecastUIData, rhs: HourlyForecastUIData) -> Bool {
        lhs.time == rhs.time
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(time)
    }
}
