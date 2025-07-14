//
//  LiveActivityComponents.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-06.
//

import SwiftUI
import EventKit

// MARK: - Music Components

struct AlbumArtView: View {
    let image: NSImage?

    var body: some View {
        Group {
            if let artwork = image {
                Image(nsImage: artwork)
                    .resizable()
            } else {
                Image(systemName: "music.note")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 20, height: 20)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .id(image)
    }
}

struct MusicLyricsView: View {
    @EnvironmentObject var musicWidget: MusicWidget
    @Binding var showLyrics: Bool
    
    init(_ showLyrics: Binding<Bool>) {
        self._showLyrics = showLyrics
    }
    
    var body: some View {
        let lyricText = (musicWidget.currentLyric?.translatedText ?? musicWidget.currentLyric?.text)
        
        if let text = lyricText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text(text)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(musicWidget.accentColor.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 200)
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                .id("lyric-\(musicWidget.currentLyric?.id.uuidString ?? "")")
                .onTapGesture {
                    showLyrics = true
                }
        } else {
            EmptyView()
        }
    }
}

struct NowPlayingTextView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: 200)
            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            .opacity(0.5)
    }
}

// MARK: - Activity View Components

struct AudioSwitchActivityView {
    static func left(for event: AudioSwitchEvent) -> some View {
        Image(systemName: "arrow.uturn.backward.circle.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .symbolRenderingMode(.hierarchical)
    }
    
    static func right(for event: AudioSwitchEvent) -> some View {
        let targetDeviceIcon = event.direction == .switchedToMac ? "desktopcomputer" : "iphone"
        let targetDeviceName = event.direction == .switchedToMac ? "Mac" : "iPhone"
        
        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(event.deviceName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                Text("Connected to \(targetDeviceName)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            Image(systemName: targetDeviceIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct BatteryActivityView {
    static func left(for state: BatteryState) -> some View {
        let iconName = state.isLow ? "battery.25" : (state.isCharging ? "bolt.fill" : "powerplug.fill")
        let iconColor = state.isLow ? Color.red : (state.isCharging ? .green : .white.opacity(0.9))
        
        return Image(systemName: iconName)
            .frame(width: 20, height: 20)
            .foregroundColor(iconColor)
    }
    
    static func right(for state: BatteryState) -> some View {
        Text("\(state.level)%")
            .font(.system(size: 13, weight: .semibold))
    }
}

struct BatteryRingView: View {
    let level: Int
    
    private var color: Color {
        if level <= 20 { return .red }
        if level <= 45 { return .yellow }
        return .green
    }
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.2), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: CGFloat(level) / 100.0)
                .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: level)
        }
        .frame(width: 18, height: 18)
    }
}

struct BluetoothActivityView {
    static func left(for device: BluetoothDeviceState) -> some View {
        Image(systemName: device.iconName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .symbolRenderingMode(.hierarchical)
    }
    
    static func right(for device: BluetoothDeviceState) -> some View {
        HStack(spacing: 8) {
            Text(device.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            if let level = device.batteryLevel {
                BatteryRingView(level: level)
            }
        }
    }
}

struct BluetoothBatteryActivityView {
    static func left(for device: BluetoothDeviceState) -> some View {
        Image(systemName: device.iconName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .symbolRenderingMode(.hierarchical)
    }
    
    static func right(for device: BluetoothDeviceState) -> some View {
        HStack(spacing: 8) {
            if let level = device.batteryLevel {
                BatteryRingView(level: level)
                Text("\(level)%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                Text("Low Battery")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red)
            }
        }
    }
}

struct BluetoothDisconnectedActivityView {
    static func left(for device: BluetoothDeviceState) -> some View {
        Image(systemName: "wifi.slash")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
            .symbolRenderingMode(.hierarchical)
    }
    
    static func right(for device: BluetoothDeviceState) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(device.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            Text("Disconnected")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct CalendarActivityView {
    static func left(for event: EKEvent) -> some View {
        Image(systemName: "calendar")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundColor(.white.opacity(0.85))
            .padding(.vertical, 2)
    }
    
    static func right(for event: EKEvent) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .lineLimit(1)
                .font(.system(size: 13, weight: .semibold))
            Text(event.startDate, style: .relative)
                .lineLimit(1)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct DesktopActivityView {
    static func left(for number: Int) -> some View {
        Image(systemName: "rectangle.on.rectangle")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
    }
    
    static func right(for number: Int) -> some View {
        Text("\(number)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
    }
}

struct EyeBreakActivityView {
    static var left: some View {
        Image(systemName: "eye.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundColor(.cyan)
    }
    
    static var right: some View {
        Text("Eye Break: Look 20ft away")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
    }
    
    static func bottom() -> some View {
        EyeBreakButtonsView()
    }
}

fileprivate struct EyeBreakButtonsView: View {
    @EnvironmentObject var eyeBreakManager: EyeBreakManager
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: { self.eyeBreakManager.dismissBreak() }) {
                Text("Dismiss")
                    .fontWeight(.semibold)
                    .frame(minWidth: 80)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Button(action: { self.eyeBreakManager.completeBreak() }) {
                Text(eyeBreakManager.isDoneButtonEnabled ? "Done" : "Done (\(Int(eyeBreakManager.timeRemainingInBreak))s)")
                    .fontWeight(.semibold)
                    .frame(minWidth: 80)
                    .padding(.vertical, 8)
                    .background(eyeBreakManager.isDoneButtonEnabled ? Color.blue : Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!eyeBreakManager.isDoneButtonEnabled)
            .animation(.easeInOut, value: eyeBreakManager.isDoneButtonEnabled)
        }
        .foregroundColor(.white)
    }
}

struct FocusModeActivityView {
    private static func color(for id: String) -> Color {
        switch id {
        case "moon.fill": return .purple
        case "person.fill": return .blue
        case "briefcase.fill": return .cyan
        case "bed.double.fill": return .indigo
        case "car.fill": return .gray
        case "gamecontroller.fill": return .red
        default: return .purple
        }
    }
    
    static func left(for mode: FocusModeInfo) -> some View {
        Image(systemName: mode.identifier)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(color(for: mode.identifier))
    }
    
    static func right(for mode: FocusModeInfo) -> some View {
        Text("Focus: \(mode.name)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
    }
}

struct TimerActivityView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            HStack(spacing: 8) {
                Image(systemName: "timer").foregroundColor(.orange)
                Text(formatTime(timerManager.elapsedTime))
            }
            .foregroundColor(.white.opacity(0.9))
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
}

struct WeatherActivityView {
    static func left(for data: ProcessedWeatherData) -> some View {
        Image(systemName: WeatherIconMapper.map(from: data.iconCode))
            .font(.title3)
            .symbolRenderingMode(.multicolor)
    }

    static func right(for data: ProcessedWeatherData) -> some View {
        RightView(data: data)
    }

    private struct RightView: View {
        @EnvironmentObject var settings: SettingsModel
        let data: ProcessedWeatherData

        var body: some View {
            let temp = settings.settings.weatherUseCelsius ? data.temperatureMetric : data.temperature
            Text("\(temp)°")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct NotificationActivityView {
    static func left(for payload: NotificationPayload) -> some View {
        let iconName: String
        let bgColor: Color
        
        switch payload.appIdentifier {
        case "com.apple.facetime":
            iconName = "video.fill"
            bgColor = .green
        case "com.apple.iChat":
            iconName = "message.fill"
            bgColor = .blue
        case "com.apple.sharingd":
            iconName = "square.and.arrow.down.on.square.fill"
            bgColor = .cyan
        default:
            iconName = "app.badge.fill"
            bgColor = .gray
        }
        
        return Image(systemName: iconName)
            .font(.system(size: 16))
            .frame(width: 28, height: 28)
            .background(bgColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    static func right(for payload: NotificationPayload) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(payload.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(payload.body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
    }
}

struct NotificationBottomView: View {
    let payload: NotificationPayload
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        HStack(spacing: 12) {
            Button("Dismiss") { notificationManager.dismissLatestNotification() }
                .buttonStyle(NotificationButtonStyle(color: .gray.opacity(0.4)))
            
            if payload.appIdentifier == "com.apple.sharingd" {
                Button(action: {
                    if let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                        NSWorkspace.shared.open(url)
                    }
                    notificationManager.dismissLatestNotification()
                }) {
                    HStack {
                        Image(systemName: "folder.fill")
                        Text("Show")
                    }
                }
                .buttonStyle(NotificationButtonStyle(color: .cyan))
            } else if payload.hasAudioAttachment {
                Button(action: {
                    NSWorkspace.shared.launchApplication("Messages")
                    notificationManager.dismissLatestNotification()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                }
                .buttonStyle(NotificationButtonStyle(color: .blue))
            } else {
                Button("Reply") {
                    NSWorkspace.shared.launchApplication("Messages")
                    notificationManager.dismissLatestNotification()
                }
                .buttonStyle(NotificationButtonStyle(color: .gray.opacity(0.4)))
            }
        }
    }
}

struct NotificationButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
