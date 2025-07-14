//
//  WeatherService.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import Foundation
import CoreLocation
import SwiftUI

class WeatherService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completionHandler: ((Result<ProcessedWeatherData, Error>) -> Void)?
    
    private let weatherAPIKey = "e45ff1b7c7bda231216c7ab7c33509b8"
    
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let displayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let hourlyTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter
    }()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    public func fetchWeather(completion: @escaping (Result<ProcessedWeatherData, Error>) -> Void) {
        self.completionHandler = completion
        
        if !CLLocationManager.locationServicesEnabled() {
            let error = NSError(domain: "WeatherService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled system-wide."])
            completionHandler?(.failure(error))
            return
        }

        switch locationManager.authorizationStatus {
        case .authorized, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            let error = NSError(domain: "WeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Location access was denied. Please enable it in System Settings."])
            completionHandler?(.failure(error))
        case .notDetermined:
            locationManager.requestLocation()
        @unknown default:
            let error = NSError(domain: "WeatherService", code: 99, userInfo: [NSLocalizedDescriptionKey: "Unknown location authorization status."])
            completionHandler?(.failure(error))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        fetchAPIs(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionHandler?(.failure(error))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        fetchWeather(completion: self.completionHandler ?? { _ in })
    }
    
    private func fetchAPIs(for location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let urlString = "https://api.weather.com/v1/geocode/\(lat)/\(lon)/aggregate.json?apiKey=\(weatherAPIKey)&products=conditionsshort,fcstdaily10short,fcsthourly24short,nowlinks"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "WeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completionHandler?(.failure(error))
            return
        }
        
        Task {
            do {
                let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
                let locationName = placemarks.first?.locality ?? placemarks.first?.name ?? "Unknown Location"
                
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(WeatherApiResponse.self, from: data)
                
                let processedData = self.process(response: apiResponse, locationName: locationName)
                self.completionHandler?(.success(processedData))
                
            } catch {
                self.completionHandler?(.failure(error))
            }
        }
    }
    
    private func process(response: WeatherApiResponse, locationName: String) -> ProcessedWeatherData {
        let observation = response.conditionsshort?.observation
        let todayForecast = response.fcstdaily10short?.forecasts?.first

        let uiDailyForecasts: [DailyForecastUIData] = response.fcstdaily10short?.forecasts?.prefix(7).compactMap { forecast in
            guard let dow = forecast.dow,
                  let maxTemp = forecast.imperial?.max_temp, let minTemp = forecast.imperial?.min_temp,
                  let maxTempMetric = forecast.metric?.max_temp, let minTempMetric = forecast.metric?.min_temp else {
                return nil
            }
            return DailyForecastUIData(
                dayOfWeek: String(dow.prefix(3)).uppercased(),
                iconName: WeatherIconMapper.map(from: forecast.day?.icon_cd ?? 44),
                highTemp: maxTemp,
                lowTemp: minTemp,
                highTempMetric: maxTempMetric,
                lowTempMetric: minTempMetric
            )
        } ?? []
        
        let uiHourlyForecasts: [HourlyForecastUIData] = response.fcsthourly24short?.forecasts?.prefix(8).compactMap { forecast in
            guard let gmt = forecast.fcst_valid, let icon = forecast.icon_cd,
                  let tempImperial = forecast.imperial?.temp,
                  let tempMetric = forecast.metric?.temp else {
                return nil
            }
            let date = Date(timeIntervalSince1970: TimeInterval(gmt))
            return HourlyForecastUIData(
                time: Self.hourlyTimeFormatter.string(from: date).uppercased(),
                iconName: WeatherIconMapper.map(from: icon),
                temperature: "\(tempImperial)°",
                temperatureMetric: "\(tempMetric)°"
            )
        } ?? []

        return ProcessedWeatherData(
            locationName: locationName,
            temperature: observation?.imperial?.temp ?? 0,
            temperatureMetric: observation?.metric?.temp ?? 0,
            highTemp: todayForecast?.imperial?.max_temp ?? 0,
            highTempMetric: todayForecast?.metric?.max_temp ?? 0,
            lowTemp: todayForecast?.imperial?.min_temp ?? 0,
            lowTempMetric: todayForecast?.metric?.min_temp ?? 0,
            conditionDescription: observation?.wx_phrase ?? "Unavailable",
            iconCode: observation?.wx_icon ?? 44,
            feelsLike: observation?.imperial?.feels_like ?? 0,
            feelsLikeMetric: observation?.metric?.feels_like ?? 0,
            windInfo: "\(observation?.imperial?.wspd ?? 0) mph",
            humidity: "\(observation?.rh ?? 0)%",
            precipChance: todayForecast?.day?.pop ?? 0,
            uvIndex: "\(observation?.uv_index ?? 0) (\(observation?.uv_desc ?? "N/A"))",
            sunriseTime: formatTime(from: todayForecast?.sunrise),
            sunsetTime: formatTime(from: todayForecast?.sunset),
            visibility: observation?.vis != nil ? "\(Int(observation!.vis!)) mi" : "-- mi",
            pressure: observation?.pressure != nil ? "\(String(format: "%.2f", observation!.pressure! * 0.02953)) in" : "-- in",
            dailyForecasts: uiDailyForecasts,
            hourlyForecasts: uiHourlyForecasts
        )
    }
    
    private func formatTime(from dateString: String?) -> String {
        guard let dateString = dateString, let date = Self.apiDateFormatter.date(from: dateString) else { return "--:--" }
        return Self.displayTimeFormatter.string(from: date)
    }
}
