//
//  weatherActivityViewModel.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-28.
//

import Foundation
import SwiftUI 
import CoreLocation 

class WeatherActivityViewModel: ObservableObject {
    private let service = WeatherService()
    @Published var weatherData: ProcessedWeatherData?
    
    init() {
        fetch()
        
        Timer.scheduledTimer(withTimeInterval: 60 * 15, repeats: true) { [weak self] _ in
            self?.fetch()
        }
    }
    
    func fetch() {
        service.fetchWeather { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.weatherData = data 
                case .failure(let error):
                    self?.weatherData = nil 
                }
            }
        }
    }
}
