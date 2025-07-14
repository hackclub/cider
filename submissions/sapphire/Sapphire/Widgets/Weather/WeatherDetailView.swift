//
//  WeatherDetailView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI



struct WeatherPlayerView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @Binding var mode: NotchWidgetMode

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                VStack(spacing: 0) { 
                    
                    currentWeatherAndDetailsSection
                        .padding(.horizontal, 24) 
                        .padding(.top, 20) 
                        .padding(.bottom, 10) 

                    
                    hourlyForecastSection
                        .padding(.horizontal, 24) 
                        .padding(.bottom, 30) 
                }
            }
            .frame(width: 560, height: 240)
            .onAppear { 
                viewModel.fetch()
            }
            .animation(.spring(response: 0.6, dampingFraction: 1, blendDuration: 0.2), value: viewModel.temperature)
            .animation(.easeInOut(duration: 0.8), value: viewModel.gradientColors.first)
    
        }
    }

    private var currentWeatherAndDetailsSection: some View {
        HStack(alignment: .top, spacing: 20) {
            
            Image(systemName: viewModel.iconName)
                .font(.system(size: 88, weight: .thin)) 
                .symbolRenderingMode(.multicolor)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .frame(width: 100, height: 100) 
                .padding(10)

            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.locationName)
                    .font(.title2.weight(.semibold)) 
                    .lineLimit(1)

                Text(viewModel.temperature)
                    .font(.system(size: 72, weight: .heavy, design: .rounded)) 
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(viewModel.conditionDescription.capitalized)
                    .font(.title3).fontWeight(.medium)
                    .lineLimit(1)

                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(viewModel.highLowTemp)
                    }
                    .font(.callout).fontWeight(.medium)
                    .opacity(0.8)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "thermometer.medium")
                                .font(.caption)
                            Text("Feels: \(viewModel.feelsLike)")
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption)
                            Text("Wind: \(viewModel.windInfo)")
                        }
                    }
                    .font(.subheadline).fontWeight(.regular)
                    .opacity(0.7)
                }
                .padding(.top, 8) 
            }
            Spacer() 
        }
        .frame(maxHeight: .infinity, alignment: .topLeading) 
    }

    private var hourlyForecastSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HOURLY FORECAST")
                .font(.caption2.weight(.bold))
                .opacity(0.6)
                .kerning(0.5) 
                .padding(.horizontal, 12)
            
            HStack(spacing: 18) { 
                ForEach(viewModel.hourlyForecasts) { forecast in
                    HourlyForecastCell(forecast: forecast)
                }
            }
        }
        .frame(height: 80) 
    }
}



private struct HourlyForecastCell: View {
    let forecast: HourlyForecastUIData
    @EnvironmentObject private var settings: SettingsModel

    var body: some View {
        VStack(spacing: 4) { 
            Text(forecast.time)
                .font(.caption2).fontWeight(.medium)
                .opacity(0.8)
            Image(systemName: forecast.iconName)
                .font(.title2).symbolRenderingMode(.multicolor) 
                .frame(height: 28) 
            Text(settings.settings.weatherUseCelsius ? forecast.temperatureMetric : forecast.temperature)
                .font(.subheadline).fontWeight(.semibold)
        }
        .frame(width: 50) 
    }
}
