//
//  SettingsModel.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI
import AppKit
import IOBluetooth
import Combine


class SettingsModel: ObservableObject {
    let settingsPublisher = PassthroughSubject<Settings, Never>()
    @UserDefault(key: "appSettings", defaultValue: Settings())
    var settings: Settings {
        willSet { settingsPublisher.send(newValue); objectWillChange.send() }
    }
}


struct Settings: Codable, Equatable {
    var liveActivityOrder: [LiveActivityType] = LiveActivityType.allCases
    var musicLiveActivityEnabled: Bool = true, weatherLiveActivityEnabled: Bool = true, calendarLiveActivityEnabled: Bool = true, timersLiveActivityEnabled: Bool = true, batteryLiveActivityEnabled: Bool = true, eyeBreakLiveActivityEnabled: Bool = true, desktopLiveActivityEnabled: Bool = true, focusLiveActivityEnabled: Bool = true
    var musicWaveformIsVolumeSensitive: Bool = true, dropboxIconEnabled: Bool = true, batteryEstimatorEnabled: Bool = true, geminiEnabled: Bool = true, pinEnabled: Bool = true
    var widgetOrder: [WidgetType] = [.music, .weather, .calendar, .shortcuts]
    var musicWidgetEnabled: Bool = true, weatherWidgetEnabled: Bool = true, calendarWidgetEnabled: Bool = true, shortcutsWidgetEnabled: Bool = true
    var bluetoothNotifyLowBattery: Bool = true, bluetoothNotifySound: Bool = true, masterNotificationsEnabled: Bool = true, iMessageNotificationsEnabled: Bool = true, airDropNotificationsEnabled: Bool = true, faceTimeNotificationsEnabled: Bool = true, systemNotificationsEnabled: Bool = true
    var appNotificationStates: [String: Bool] = [:]
    var neardropEnabled: Bool = true, neardropDeviceDisplayName: String = "My Mac", neardropDownloadLocationPath: String = FileManager.default.urls(
        for: .downloadsDirectory,
        in: .userDomainMask
    ).first!.path, neardropOpenOnClick: Bool = true
    var showNowPlayingInMenuBar: Bool = true, spotifyClientId: String = "", spotifyClientSecret: String = "", defaultMusicPlayer: DefaultMusicPlayer = .appleMusic, showLyricsInLiveActivity: Bool = false
    var musicAppStates: [String: Bool] = [:]
    var musicOpenOnClick: Bool = true, weatherDefaultLocation: String = "New York, NY", weatherUseCelsius: Bool = false, weatherOpenOnClick: Bool = false
    var calendarShowAllDayEvents: Bool = true, calendarStartOfWeek: Day = .sunday
    var eyeBreakWorkInterval: Double = 20, eyeBreakBreakDuration: Double = 20, eyeBreakSoundAlerts: Bool = true
    var enableVolumeHUD: Bool = true, volumeHUDStyle: HUDStyle = .default, volumeHUDSoundEnabled: Bool = true
    var enableBrightnessHUD: Bool = true, brightnessHUDStyle: HUDStyle = .default
    var batteryNotifyForLowBattery: Bool = true, batteryNotifyWithSound: Bool = true, batteryNotifyChargingState: Bool = true
    var geminiApiKey: String = ""
}


enum WidgetType: String, Codable, CaseIterable, Identifiable, Equatable {
    case weather,
         calendar,
         shortcuts,
         music; var id: String { self.rawValue }; var displayName: String {
             self.rawValue.prefix(1).uppercased() + self.rawValue.dropFirst()
         }
}
enum LiveActivityType: String, Codable, CaseIterable, Identifiable, Equatable {
    case eyeBreak,
         focus,
         desktop,
         battery,
         timers,
         calendar,
         weather,
         music; var id: String { self.rawValue }; var displayName: String {
             switch self {
             case .music: "Music"; case .weather: "Weather"; case .calendar: "Calendar"; case .timers: "Timers"; case .battery: "Battery"; case .eyeBreak: "Eye Break"; case .desktop: "Desktop"; case .focus: "Focus"
             }
         }
}
enum NotificationSource: String, CaseIterable, Identifiable {
    case iMessage,
         faceTime,
         airDrop; var id: String { rawValue }; var displayName: String { switch self { case .iMessage: "iMessage"; case .faceTime: "FaceTime"; case .airDrop: "AirDrop" } }; var systemImage: String { switch self { case .iMessage: "message.fill"; case .faceTime: "video.fill"; case .airDrop: "shareplay" } }; var iconColor: Color {
             switch self {
             case .iMessage,
                     .faceTime: .green; case .airDrop: .blue
             }
         }
}
enum GeneralSettingType: String, CaseIterable, Identifiable, Equatable {
    case dropboxIcon,
         batteryEstimator,
         gemini,
         pin; var id: String { self.rawValue }; var displayName: String { switch self { case .dropboxIcon: "Dropbox Icon"; case .batteryEstimator: "Battery Estimator"; case .gemini: "Gemini Integration"; case .pin: "Pin Widgets" } }; var systemImage: String { switch self { case .dropboxIcon: "cloud.fill"; case .batteryEstimator: "gauge.high"; case .gemini: "sparkles"; case .pin: "pin.fill" } }; var iconColor: Color {
             switch self {
             case .dropboxIcon: .blue; case .batteryEstimator: .green; case .gemini: .purple; case .pin: .gray
             }
         }
}
struct SystemApp: Identifiable, Equatable {
    let id: String,
        name: String,
        icon: NSImage,
        isBrowser: Bool
}
enum Day: String, Codable, CaseIterable, Identifiable {
    case sunday,
         monday; var id: String { self.rawValue.capitalized }
}
enum DefaultMusicPlayer: String, Codable, CaseIterable, Identifiable {
    case appleMusic,
         spotify; var id: String { self.rawValue }; var displayName: String {
             switch self {
             case .appleMusic: "Apple Music"; case .spotify: "Spotify"
             }
         }
}
enum HUDStyle: String, Codable, CaseIterable, Identifiable {
    case `default`,
         thin; var id: String { self.rawValue.capitalized }
}
enum SettingsSection: String, CaseIterable, Identifiable {
    case general,
         widgets,
         liveActivities,
         battery,
         bluetooth,
         hud,
         notifications,
         neardrop,
         music,
         weather,
         calendar,
         eyeBreak,
         gemini,
         about; var id: String { self.rawValue }; var label: String { switch self { case .general: "General"; case .widgets: "Widgets"; case .liveActivities: "Live Activities"; case .battery: "Battery"; case .bluetooth: "Bluetooth"; case .hud: "HUD"; case .notifications: "Notifications"; case .neardrop: "Nearby Share"; case .music: "Music"; case .weather: "Weather"; case .calendar: "Calendar"; case .eyeBreak: "Eye Break"; case .gemini: "Gemini"; case .about: "About" } }; var systemImage: String { switch self { case .general: "gear"; case .widgets: "square.grid.2x2.fill"; case .liveActivities: "bolt.badge.a.fill"; case .battery: "battery.100"; case .bluetooth: "bolt.horizontal.circle.fill"; case .hud: "macwindow.on.rectangle"; case .notifications: "bell"; case .neardrop: "shareplay"; case .music: "music.note"; case .weather: "cloud.sun.fill"; case .calendar: "calendar"; case .eyeBreak: "eye.fill"; case .gemini: "sparkles"; case .about: "info.circle" } }; var iconBackgroundColor: Color {
             switch self {
             case .general: .gray; case .widgets: .purple; case .liveActivities: .cyan; case .battery: .green; case .bluetooth: .blue; case .hud: .indigo; case .notifications: .red; case .neardrop: .blue; case .music: .pink; case .weather: .blue; case .calendar: .red; case .eyeBreak: .teal; case .gemini: .purple; case .about: .blue
             }
         }
}

@MainActor
class SystemAppFetcher: ObservableObject {
    @Published var apps: [SystemApp] = []
    @Published var foundBundleIDs: Set<String> = []
    
    func fetchApps() {
        DispatchQueue.global(qos: .userInitiated).async {
            var fetchedApps: [SystemApp] = []
            
            var seenBundleIDs = Set<String>()
            
            let fileManager = FileManager.default
            let searchPaths = ["/System/Applications", "/Applications", NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first].compactMap {
                $0
            }
            
            for path in searchPaths {
                do {
                    let appURLs = try fileManager.contentsOfDirectory(
                        at: URL(fileURLWithPath: path),
                        includingPropertiesForKeys: [.isApplicationKey],
                        options: .skipsHiddenFiles
                    )
                    for url in appURLs where url.pathExtension == "app" {
                        guard let bundle = Bundle(url: url), let bundleId = bundle.bundleIdentifier else {
                            continue
                        }
                        
                        
                        
                        if !seenBundleIDs.contains(bundleId) {
                            let name = fileManager.displayName(atPath: url.path)
                            let icon = NSWorkspace.shared.icon(
                                forFile: url.path
                            )
                            let isBrowser = self.isBrowser(bundle: bundle)
                            let app = SystemApp(
                                id: bundleId,
                                name: name,
                                icon: icon,
                                isBrowser: isBrowser
                            )
                            
                            fetchedApps.append(app)
                            
                            seenBundleIDs.insert(bundleId)
                        }
                    }
                } catch {
                    
                }
            }
            
            DispatchQueue.main.async {
                self.apps = fetchedApps
                    .sorted {
                        $0.name
                            .localizedCaseInsensitiveCompare(
                                $1.name
                            ) == .orderedAscending
                    }
                self.foundBundleIDs = seenBundleIDs
            }
        }
    }
    
    private func isBrowser(bundle: Bundle?) -> Bool {
        guard let bundle = bundle, let urlTypes = bundle.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return false
        }
        for type in urlTypes {
            if let schemes = type["CFBundleURLSchemes"] as? [String], schemes
                .contains("http") || schemes
                .contains("https") {
                return true
            }
        }
        return false
    }
}
