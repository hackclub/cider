//
//  MusicWidgetView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import SwiftUI
import AppKit

struct MusicWidgetView: View {
    @EnvironmentObject var musicWidget: MusicWidget
    @EnvironmentObject var settings: SettingsModel
    @Binding var mode: NotchWidgetMode
    @State private var isHoveringArtwork = false

    var body: some View {
        
        if let title = musicWidget.title, !title.isEmpty {
            
            HStack(alignment: .center, spacing: 16) {
                albumArtWithOverlay
                
                VStack(alignment: .leading, spacing: 8) {
                    MusicInfoView(
                        title: musicWidget.title,
                        album: musicWidget.album,
                        artist: musicWidget.artist
                    )
                    
                    MusicControlsView(
                        isPlaying: musicWidget.isPlaying,
                        onPrevious: musicWidget.previousTrack,
                        onPlayPause: { musicWidget.isPlaying ? musicWidget.pause() : musicWidget.play() },
                        onNext: musicWidget.nextTrack
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 100)
            .frame(maxWidth: 300)
            .fixedSize()
        } else {
            
            OpenPlayerView(
                player: settings.settings.defaultMusicPlayer,
                action: openDefaultPlayer
            )
        }
    }

    private var albumArtWithOverlay: some View {
        Image(nsImage: musicWidget.artwork ?? NSImage(systemSymbolName: "waveform", accessibilityDescription: "Album art")!)
            .resizable().aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100).cornerRadius(30)
            .shadow(color: musicWidget.accentColor.opacity(0.7), radius: 8, y: 5)
            .overlay(alignment: .bottomLeading) {
                if let icon = musicWidget.appIcon {
                    Image(nsImage: icon).resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22).clipShape(Circle()).padding(6)
                }
            }
            .onHover { hovering in
                self.isHoveringArtwork = hovering
                if hovering { HapticManager.perform(.alignment) }
            }
            .onTapGesture { mode = .musicPlayer }
    }
    
    
    private func openDefaultPlayer() {
        let player = settings.settings.defaultMusicPlayer
        let bundleId = player == .appleMusic ? "com.apple.Music" : "com.spotify.client"
        NSWorkspace.shared.launchApplication(bundleId)
    }
}


private struct OpenPlayerView: View {
    let player: DefaultMusicPlayer
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.8))

            Button(action: action) {
                Text("Open \(player.displayName)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 300, height: 100) 
    }
}


private struct MusicInfoView: View {
    let title: String?
    let album: String?
    let artist: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            
            if let album = album, !album.isEmpty, album != title {
                Text(album)
                    .font(.system(size: 14, weight: .medium))
            }
            if let artist = artist, !artist.isEmpty {
                Text(artist)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}


private struct MusicControlsView: View {
    let isPlaying: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 18) {
            Button(action: onPrevious) { Image(systemName: "backward.end.fill") }
            Button(action: onPlayPause) { Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 20, weight: .semibold)) }
            Button(action: onNext) { Image(systemName: "forward.end.fill") }
        }
        .buttonStyle(BlurButtonStyle())
        .font(.system(size: 16))
        .foregroundColor(.white)
    }
}
