//
//  NotchWidgetView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import SwiftUI

enum NotchWidgetMode {
    case defaultWidgets
    case musicPlayer
    case nearDrop
    case weatherPlayer
}

struct NotchWidgetView: View {
    @Binding var mode: NotchWidgetMode
    
    @StateObject private var settings = SettingsModel()
    
    @State private var showContent = false

    private var enabledAndOrderedWidgets: [WidgetType] {
        let orderedTypes = settings.settings.widgetOrder
        
        return orderedTypes.filter { widgetType in
            switch widgetType {
            case .music:
                return settings.settings.musicWidgetEnabled
            case .weather:
                return settings.settings.weatherWidgetEnabled
            case .calendar:
                return settings.settings.calendarWidgetEnabled
            case .shortcuts:
                return settings.settings.shortcutsWidgetEnabled
            }
        }
    }

    var body: some View {
        Group {
            switch mode {
            case .defaultWidgets:
                AnyView(
                    HStack(spacing: 0) {
                        ForEach(enabledAndOrderedWidgets) { widgetType in
                            widgetView(for: widgetType)
                        }
                    }
                )
                .blur(radius: showContent ? 0 : 8)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.98)

            case .musicPlayer:
                AnyView(
                    
                    MusicPlayerView(mode: $mode)
                        .environmentObject(settings)
                )
                .blur(radius: showContent ? 0 : 8)
                .opacity(showContent ? 1 : 0)

            case .nearDrop:
                AnyView(NearDropProgressView())
                    .blur(radius: showContent ? 0 : 8)
                    .opacity(showContent ? 1 : 0)
            
            case .weatherPlayer:
                AnyView(
                    
                    WeatherPlayerView(mode: $mode)
                        .environmentObject(settings)
                )
                .blur(radius: showContent ? 0 : 8)
                .opacity(showContent ? 1 : 0)
            }
        }
        .padding(.top, NotchConfiguration.universalHeight - 10)
        .padding(.horizontal, 10)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }
    
    @ViewBuilder
    private func widgetView(for widgetType: WidgetType) -> some View {
        switch widgetType {
        case .music:
            MusicWidgetView(mode: $mode)
        case .weather:
            WeatherWidgetView(mode: $mode)
        case .calendar:
            CalendarWidgetView()
        case .shortcuts:
            
            EmptyView()
        }
    }
}
