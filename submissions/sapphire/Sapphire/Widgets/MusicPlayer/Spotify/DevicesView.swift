//
//  DevicesView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import SwiftUI

struct DevicesView: View {
    var onDismiss: () -> Void
    @EnvironmentObject var spotifyManager: SpotifyAPIManager
    
    @State private var devices: [SpotifyDevice] = []
    @State private var isLoading = true
    @State private var volume: Double = 75
    @State private var debouncer = Debouncer(delay: 0.2)

    var body: some View {
        VStack(spacing: 15) {

            
            if isLoading {
                ProgressView().frame(maxHeight: .infinity)
            } else if spotifyManager.isPremiumUser {
                premiumUserView
            } else {
                freeUserView
            }
        }
        .padding(20).onAppear { Task { await fetchInitialData() } }
    }
    
    private var premiumUserView: some View {
        VStack {
            if devices.contains(where: { $0.isActive }) {
                VolumeControl(volume: $volume)
                    .onChange(of: volume) { newValue in
                        debouncer.debounce { Task { _ = await spotifyManager.setVolume(percent: Int(newValue)) } }
                    }
            }
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(devices) { device in
                        DeviceRow(device: device, isActive: device.isActive)
                            .onTapGesture {
                                guard !device.isActive, let deviceId = device.id else { return }
                                Task { _ = await spotifyManager.transferPlayback(to: deviceId); await fetchInitialData() }
                            }
                    }
                }
            }
        }
    }
    
    private var freeUserView: some View {
        VStack(spacing: 20) {
            Text("Local Volume Control").font(.headline)
            VolumeControl(volume: $volume)
                .onChange(of: volume) { newValue in
                    debouncer.debounce { Task { _ = await spotifyManager.setVolume(percent: Int(newValue)) } }
                }
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.lock.fill").font(.largeTitle).foregroundColor(.yellow)
                Text("Device Switching Requires Premium").font(.headline)
                Text("You can control the volume of your local Spotify app. To switch playback to other devices, a Premium account is required.").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            }.padding().background(.thinMaterial).cornerRadius(16)
            Spacer()
        }
    }
    
    private func fetchInitialData() async {
        if spotifyManager.isPremiumUser {
            let allDevices = await spotifyManager.fetchDevices()
            let playbackState = await spotifyManager.fetchPlaybackState()
            await MainActor.run {
                self.devices = allDevices
                if let currentVolume = playbackState?.device.volumePercent { self.volume = Double(currentVolume) }
                self.isLoading = false
            }
        } else {
            if let localVolume = spotifyManager.getLocalVolume() { await MainActor.run { self.volume = Double(localVolume) } }
            await MainActor.run { self.isLoading = false }
        }
    }
}



struct VolumeControl: View {
    @Binding var volume: Double
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: volume < 1 ? "speaker.slash.fill" : "speaker.wave.1.fill")
            Slider(value: $volume, in: 0...100)
            Image(systemName: volume > 66 ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
        }
        .foregroundColor(.secondary).padding().background(.ultraThinMaterial).cornerRadius(16)
    }
}

struct DeviceRow: View {
    let device: SpotifyDevice
    let isActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: iconName(for: device.type)).font(.title2).frame(width: 30).foregroundColor(isActive ? .green : .primary)
            Text(device.name).fontWeight(isActive ? .semibold : .regular)
            Spacer()
            if isActive { Image(systemName: "speaker.wave.2.fill").foregroundColor(.green) }
        }
        .padding().background(.thinMaterial).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isActive ? Color.green.opacity(0.7) : Color.secondary.opacity(0.2), lineWidth: 1.5))
        .scaleEffect(isActive ? 1.0 : 0.98).animation(.spring(response: 0.4, dampingFraction: 0.6), value: isActive)
    }
    
    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "computer": return "desktopcomputer"
        case "speaker": return "hifispeaker.2.fill"
        case "smartphone": return "iphone" 
        case "avr", "stb": return "tv.inset.filled"
        default: return "questionmark.circle"
        }
    }
}
