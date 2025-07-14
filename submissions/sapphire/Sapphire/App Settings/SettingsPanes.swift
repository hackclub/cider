//
//  SettingsPanes.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI


struct SettingsDetailView: View {
    var selectedSection: SettingsSection?
    var body: some View {
        ZStack {
            GeneralSettingsView().opacity(selectedSection == .general ? 1 : 0)
            WidgetsSettingsView().opacity(selectedSection == .widgets ? 1 : 0)
            LiveActivitiesSettingsView().opacity(selectedSection == .liveActivities ? 1 : 0)
            BatterySettingsView().opacity(selectedSection == .battery ? 1 : 0)
            BluetoothSettingsView().opacity(selectedSection == .bluetooth ? 1 : 0)
            HUDSettingsView().opacity(selectedSection == .hud ? 1 : 0)
            NotificationsSettingsView().opacity(selectedSection == .notifications ? 1 : 0)
            NeardropSettingsView().opacity(selectedSection == .neardrop ? 1 : 0)
            MusicSettingsView().opacity(selectedSection == .music ? 1 : 0)
            WeatherSettingsView().opacity(selectedSection == .weather ? 1 : 0)
            CalendarSettingsView().opacity(selectedSection == .calendar ? 1 : 0)
            EyeBreakSettingsView().opacity(selectedSection == .eyeBreak ? 1 : 0)
            GeminiSettingsView().opacity(selectedSection == .gemini ? 1 : 0)
            AboutSettingsView().opacity(selectedSection == .about ? 1 : 0)
            
            if selectedSection == nil {
                VStack { Image(systemName: "sidebar.left").font(.system(size: 50)).foregroundStyle(.tertiary); Text("Select a category").font(.title).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.animation(.easeOut(duration: 0.15), value: selectedSection)
    }
}



struct GeneralSettingsView: View {
    @EnvironmentObject var settings: SettingsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("General")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                VStack(spacing: 0) {
                    ForEach(GeneralSettingType.allCases) { setting in
                        GeneralSettingToggleRowView(setting: setting, isEnabled: binding(for: setting))
                        if setting != GeneralSettingType.allCases.last {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                                .padding(.leading, 60)
                        }
                    }
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func binding(for setting: GeneralSettingType) -> Binding<Bool> {
        switch setting {
        case .dropboxIcon: return $settings.settings.dropboxIconEnabled
        case .batteryEstimator: return $settings.settings.batteryEstimatorEnabled
        case .gemini: return $settings.settings.geminiEnabled
        case .pin: return $settings.settings.pinEnabled
        }
    }
}

struct WidgetsSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Widgets").font(.largeTitle.bold()).padding(.bottom)
                
                ReorderableVStack(items: $settings.settings.widgetOrder) { widget in
                    WidgetRowView(widgetType: widget)
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
        }
    }
}

struct LiveActivitiesSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live Activities").font(.largeTitle.bold()).padding(.bottom)
                
                ReorderableVStack(items: $settings.settings.liveActivityOrder) { activity in
                    LiveActivityRowView(activityType: activity)
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
        }
    }
}

struct NotificationsSettingsView: View {
    @StateObject private var appFetcher = SystemAppFetcher()
    @EnvironmentObject var settings: SettingsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Notifications")
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Enable Notifications")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Toggle("", isOn: $settings.settings.masterNotificationsEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .animation(.default, value: settings.settings.masterNotificationsEnabled)
                    }
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                }
                .modifier(SettingsContainerModifier())
                
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        ForEach(NotificationSource.allCases) { source in
                            NotificationToggleRowView(source: source)
                            if source != NotificationSource.allCases.last {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 1)
                                    .padding(.leading, 60)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("System Notifications")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Toggle("", isOn: $settings.settings.systemNotificationsEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .animation(.default, value: settings.settings.systemNotificationsEnabled)
                        }
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                        
                        Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 60)

                        Text("Allow Notifications From:")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(appFetcher.apps) { app in
                                    SystemAppRowView(app: app, isEnabled: binding(for: app))
                                    if app.id != appFetcher.apps.last?.id {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 1)
                                            .padding(.leading, 50)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 360)
                    }
                    .disabled(!settings.settings.systemNotificationsEnabled)
                    .opacity(settings.settings.systemNotificationsEnabled ? 1.0 : 0.5)
                }
                .modifier(SettingsContainerModifier())
                .disabled(!settings.settings.masterNotificationsEnabled)
                .opacity(settings.settings.masterNotificationsEnabled ? 1.0 : 0.5)
                .animation(.easeInOut, value: settings.settings.masterNotificationsEnabled)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                appFetcher.fetchApps()
            }
        }
    }

    private func binding(for app: SystemApp) -> Binding<Bool> {
        return .init(
            get: { settings.settings.appNotificationStates[app.id, default: true] },
            set: { settings.settings.appNotificationStates[app.id] = $0 }
        )
    }
}


struct BatterySettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    @State private var batteryLimit: Double = 80.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Battery")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Notify on Charging State Change")
                        Spacer()
                        Toggle("", isOn: $settings.settings.batteryNotifyChargingState)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Notify for Low Battery")
                        Spacer()
                        Toggle("", isOn: $settings.settings.batteryNotifyForLowBattery)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Notify with Sound")
                        Spacer()
                        Toggle("", isOn: $settings.settings.batteryNotifyWithSound)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                    .disabled(!settings.settings.batteryNotifyForLowBattery)
                    .opacity(settings.settings.batteryNotifyForLowBattery ? 1.0 : 0.5)
                    .animation(.easeInOut, value: settings.settings.batteryNotifyForLowBattery)
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Battery Limit: \(Int(batteryLimit))%")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        CustomBatterySlider(value: $batteryLimit, range: 20...100)
                            .frame(height: 50)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())

                if batteryLimit < 50 {
                    InfoContainer(
                        text: "Setting the battery limit to lower than 50% isn't recommended as it can cause your battery to die quickly.",
                        iconName: "exclamationmark.triangle.fill",
                        color: .yellow
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .animation(.easeInOut, value: batteryLimit < 50)
        }
    }
}


struct GeminiSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Gemini")
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gemini API Key")
                        .font(.system(size: 14, weight: .medium))
                    
                    SecureField("Enter your API key", text: $settings.settings.geminiApiKey)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2)))
                }
                .padding(25)
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct HUDSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("HUD")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Volume HUD")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $settings.settings.enableVolumeHUD)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("View Style")
                        Spacer()
                        Picker("", selection: $settings.settings.volumeHUDStyle) {
                            ForEach(HUDStyle.allCases) { style in
                                Text(style.id).tag(style)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                    .disabled(!settings.settings.enableVolumeHUD)
                    .opacity(settings.settings.enableVolumeHUD ? 1.0 : 0.5)

                    Divider()

                    HStack {
                        Text("Sound on Change")
                        Spacer()
                        Toggle("", isOn: $settings.settings.volumeHUDSoundEnabled)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .disabled(!settings.settings.enableVolumeHUD)
                    .opacity(settings.settings.enableVolumeHUD ? 1.0 : 0.5)
                }
                .padding()
                .modifier(SettingsContainerModifier())
                .animation(.easeInOut, value: settings.settings.enableVolumeHUD)

                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Brightness HUD")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $settings.settings.enableBrightnessHUD)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("View Style")
                        Spacer()
                        Picker("", selection: $settings.settings.brightnessHUDStyle) {
                            ForEach(HUDStyle.allCases) { style in
                                Text(style.id).tag(style)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                    .disabled(!settings.settings.enableBrightnessHUD)
                    .opacity(settings.settings.enableBrightnessHUD ? 1.0 : 0.5)
                }
                .padding()
                .modifier(SettingsContainerModifier())
                .animation(.easeInOut, value: settings.settings.enableBrightnessHUD)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct MusicSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    @StateObject private var appFetcher = SystemAppFetcher()

    private var browserApps: [SystemApp] { appFetcher.apps.filter { $0.isBrowser } }
    private var otherApps: [SystemApp] { appFetcher.apps.filter { !$0.isBrowser } }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Music").font(.largeTitle.bold()).padding(.bottom)
                VStack(spacing: 0) {
                    HStack { Text("Show Now Playing in Menu Bar"); Spacer(); Toggle("", isOn: $settings.settings.showNowPlayingInMenuBar).labelsHidden().toggleStyle(.switch) }.padding()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    HStack { Text("Waveform is volume sensitive"); Spacer(); Toggle("", isOn: $settings.settings.musicWaveformIsVolumeSensitive).labelsHidden().toggleStyle(.switch) }.padding()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    HStack { Text("Default Music App"); Spacer(); Picker("", selection: $settings.settings.defaultMusicPlayer) { Text("Apple Music").tag(DefaultMusicPlayer.appleMusic); if appFetcher.foundBundleIDs.contains("com.spotify.client") { Text("Spotify").tag(DefaultMusicPlayer.spotify) } }.labelsHidden().frame(width: 150) }.padding()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spotify API Credentials")
                            .font(.system(size: 14, weight: .medium))
                        Text("Register your app at developer.spotify.com and copy these values here. The redirect URI is: sapphire://callback")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)

                        Text("Client ID")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        SecureField("Enter your Client ID", text: $settings.settings.spotifyClientId)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2)))
                        
                        Text("Client Secret")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.top, 5)
                        SecureField("Enter your Client Secret", text: $settings.settings.spotifyClientSecret)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2)))
                    }.padding().padding(.top, 5)
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    
                    HStack {
                        Text("Open detailed Music widget on live activity click"); Spacer(); Toggle("", isOn: $settings.settings.musicOpenOnClick).labelsHidden().toggleStyle(.switch) }.padding()
                }.modifier(SettingsContainerModifier())

                VStack(spacing: 0) {
                    HStack { Text("Show Lyrics in Live Activity"); Spacer(); Toggle("", isOn: $settings.settings.showLyricsInLiveActivity).labelsHidden().toggleStyle(.switch) }.padding()
                }.modifier(SettingsContainerModifier()).animation(.default, value: settings.settings.showLyricsInLiveActivity)

                if settings.settings.showLyricsInLiveActivity {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Allow Lyrics From:").font(.headline).padding([.horizontal, .top])
                        ScrollView {
                            VStack(spacing: 0) {
                                Text("Browsers (Disabled by Default)").font(.caption).foregroundStyle(.secondary).padding(.vertical, 5)
                                ForEach(browserApps) { app in SystemAppRowView(app: app, isEnabled: binding(for: app, isBrowser: true)) }
                                Text("Other Apps").font(.caption).foregroundStyle(.secondary).padding(.vertical, 5)
                                ForEach(otherApps) { app in SystemAppRowView(app: app, isEnabled: binding(for: app, isBrowser: false)) }
                            }
                        }.frame(maxHeight: 360)
                    }.modifier(SettingsContainerModifier()).transition(.opacity.combined(with: .move(edge: .top)))
                }
            }.padding(25).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).onAppear { appFetcher.fetchApps() }
        }
    }
    
    private func binding(for app: SystemApp, isBrowser: Bool) -> Binding<Bool> {
        .init(
            get: { settings.settings.musicAppStates[app.id, default: !isBrowser] },
            set: { settings.settings.musicAppStates[app.id] = $0 }
        )
    }
}

struct WeatherSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Weather")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Location")
                        TextField("e.g., New York, NY", text: $settings.settings.weatherDefaultLocation)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2)))
                    }
                    .padding()

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Use Celsius")
                        Spacer()
                        Toggle("", isOn: $settings.settings.weatherUseCelsius)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Open detailed Weather widget on live activity click")
                        Spacer()
                        Toggle("", isOn: $settings.settings.weatherOpenOnClick)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct CalendarSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Calendar")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                VStack(spacing: 0) {
                    HStack {
                        Text("Show All-Day Events")
                        Spacer()
                        Toggle("", isOn: $settings.settings.calendarShowAllDayEvents)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Start Week On")
                        Spacer()
                        Picker("", selection: $settings.settings.calendarStartOfWeek) {
                            ForEach(Day.allCases) { day in
                                Text(day.id).tag(day)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct EyeBreakSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Eye Break")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                VStack(spacing: 0) {
                    CustomSliderRowView(
                        label: "Work Interval",
                        value: $settings.settings.eyeBreakWorkInterval,
                        range: 5...60,
                        specifier: "%.0f min"
                    )
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    
                    CustomSliderRowView(
                        label: "Break Duration",
                        value: $settings.settings.eyeBreakBreakDuration,
                        range: 10...60,
                        specifier: "%.0f sec"
                    )
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)

                    HStack {
                        Text("Enable Sound Alerts")
                        Spacer()
                        Toggle("", isOn: $settings.settings.eyeBreakSoundAlerts)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct BluetoothSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Bluetooth")
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Notify for Low Battery")
                        Spacer()
                        Toggle("", isOn: $settings.settings.bluetoothNotifyLowBattery)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .padding()

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.leading, 20)
                    
                    HStack {
                        Text("Notify for Sound")
                        Spacer()
                        Toggle("", isOn: $settings.settings.bluetoothNotifySound)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct NeardropSettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    
    @State private var downloadPath: String = ""
    @State private var isPathValid: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Nearby Share")
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Enable Nearby Share")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Toggle("", isOn: $settings.settings.neardropEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.horizontal, 20)
                    
                    InfoContainer(
                        text: "Nearby Share allows you to share files from Android phones to your Mac using Android's native file sharing (Nearby Share / Quick Share). It's recommended to keep this feature enabled for convenient sharing from family and friends.",
                        iconName: "info.circle.fill",
                        color: .blue
                    )
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Device Display Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                            
                            TextField("My Mac", text: $settings.settings.neardropDeviceDisplayName)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
                                .foregroundStyle(.white)
                                .font(.system(size: 13))
                                .disabled(!settings.settings.neardropEnabled)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Download Location")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                            
                            HStack {
                                TextField("Path", text: $downloadPath, onCommit: validateAndSavePath)
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 13))
                                    .disabled(!settings.settings.neardropEnabled)
                                
                                Image(systemName: isPathValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isPathValid ? .green : .red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPathValid ? Color.white.opacity(0.2) : Color.red, lineWidth: 1))

                            if !isPathValid {
                                Text("A valid directory is required.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom], 20)
                    .opacity(settings.settings.neardropEnabled ? 1.0 : 0.5)

                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.horizontal, 20)
                    
                    HStack {
                        Text("Open detailed AirDrop widget on live activity click")
                        Spacer()
                        Toggle("", isOn: $settings.settings.neardropOpenOnClick)
                            .labelsHidden().toggleStyle(.switch)
                    }
                    .padding()
                    .disabled(!settings.settings.neardropEnabled)
                    .opacity(settings.settings.neardropEnabled ? 1.0 : 0.5)

                }
                .modifier(SettingsContainerModifier())
                .animation(.easeInOut, value: settings.settings.neardropEnabled)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                self.downloadPath = settings.settings.neardropDownloadLocationPath
            }
            .onChange(of: downloadPath) { newValue in
                self.isPathValid = validate(path: newValue)
            }
        }
    }

    private func validateAndSavePath() {
        if validate(path: downloadPath) {
            settings.settings.neardropDownloadLocationPath = downloadPath
        }
    }

    private func validate(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}

struct AboutSettingsView: View {
    @StateObject private var updateChecker = UpdateChecker()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About")
                    .font(.largeTitle.bold())
                    .padding(.bottom)

                HStack {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sapphire")
                            .font(.largeTitle.weight(.bold))
                        Text("Version \(currentAppVersion)")
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    Spacer()
                }

                VStack {
                    switch updateChecker.status {
                    case .checking:
                        HStack {
                            ProgressView().scaleEffect(0.5)
                            Text("Checking for updates...").foregroundStyle(.secondary)
                        }
                    case .upToDate:
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("You are up to date!").foregroundStyle(.secondary)
                        }
                    case .available(let version, let asset):
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill").foregroundColor(.accentColor)
                                Text("Version \(version) is available!").font(.headline)
                            }
                            Button("Download and Install") {
                                updateChecker.downloadAndUpdate(asset: asset)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                        }
                    case .downloading(let progress):
                        ProgressView("Downloading...", value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                    case .downloaded(let path):
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Download complete!").foregroundStyle(.secondary)
                            Button("Show in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([path])
                            }
                            .buttonStyle(.plain).font(.caption)
                        }
                    case .error(let message):
                        HStack {
                            Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
                            Text("Error: \(message)").foregroundStyle(.secondary)
                        }
                    }
                    
                    Button("Check for Updates") {
                        updateChecker.checkForUpdates()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor.opacity(0.8))
                    .padding(.top, 5)
                    .disabled(isCheckingOrDownloading())
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .padding()
                .modifier(SettingsContainerModifier())

                Text("© 2025 Shariq Charolia. All rights reserved.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                updateChecker.checkForUpdates()
            }
        }
    }
    
    private func isCheckingOrDownloading() -> Bool {
        if case .checking = updateChecker.status { return true }
        if case .downloading = updateChecker.status { return true }
        return false
    }
}
