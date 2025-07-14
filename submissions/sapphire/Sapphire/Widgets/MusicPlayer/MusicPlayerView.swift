//
//  MusicPlayerView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import SwiftUI
import AppKit

struct MusicPlayerView: View {
    @Binding var mode: NotchWidgetMode
    @EnvironmentObject var musicWidget: MusicWidget
    @EnvironmentObject var spotifyManager: SpotifyAPIManager
    
    @EnvironmentObject var liveActivityManager: LiveActivityManager

    private enum ActiveView {
        case player, loginPrompt, queueAndPlaylists, devices, lyrics
    }
    @State private var activeView: ActiveView = .player
    
    
    @State private var showLyrics: Bool = false

    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            ZStack {
                switch activeView {
                case .player:
                    playerView
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity))
                        )
                case .loginPrompt:
                    LoginPromptView(onDismiss: { dismissSubView() })
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity))
                        )
                case .queueAndPlaylists:
                    QueueAndPlaylistsView(onDismiss: { dismissSubView() })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity))
                        )
                case .devices:
                    DevicesView(onDismiss: { dismissSubView() })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity))
                        )
                
                case .lyrics:
                    LyricsView(
                        lyrics: musicWidget.lyrics,
                        currentLyricID: musicWidget.currentLyric?.id,
                        accentColor: musicWidget.accentColor,
                        onDismiss: { dismissSubView() }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.05).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity))
                    )
                }
            }
            .id(activeView)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeView)
        }
        
        .onAppear {
            liveActivityManager.showLyricsBinding = $showLyrics
        }
        .onChange(of: showLyrics) { shouldShow in
            if shouldShow {
                activeView = .lyrics
                
                showLyrics = false
            }
        }
    }
    
    
    private var playerView: some View {
        VStack(spacing: 3) {
            HStack(spacing: 12) {
                Image(nsImage: musicWidget.artwork ?? NSImage(systemSymbolName: "waveform", accessibilityDescription: "Album art")!)
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60)
                    .cornerRadius(8).shadow(color: musicWidget.accentColor.opacity(0.7), radius: 5)
                VStack(alignment: .leading, spacing: 3) {
                    Text(musicWidget.title ?? "Title").font(.system(size: 16, weight: .semibold)).lineLimit(1)
                    Text(musicWidget.artist ?? "Artist").font(.system(size: 13)).foregroundColor(.secondary).lineLimit(1)
                }
                Spacer()
                WaveformView().environmentObject(musicWidget).scaleEffect(1.3)
            }

            HStack(alignment: .center, spacing: 8) {
                Text(formatTime(musicWidget.currentElapsedTime))
                InteractiveProgressBar(
                    value: $musicWidget.playbackProgress,
                    gradient: Gradient(colors: [musicWidget.leftGradientColor, musicWidget.rightGradientColor]),
                    onSeek: { [musicWidget] newProgress in
                        let seekTime = newProgress * musicWidget.totalDuration
                        if seekTime.isFinite && musicWidget.totalDuration > 0 { musicWidget.seek(to: seekTime) }
                    }
                ).frame(height: 30).shadow(color: musicWidget.accentColor.opacity(0.5), radius: 8, y: 3)
                Text("-\(formatTime(musicWidget.totalDuration - musicWidget.currentElapsedTime))")
            }.font(.system(size: 10, weight: .medium, design: .monospaced)).foregroundColor(.secondary)

            
            if let lyricText = (musicWidget.currentLyric?.translatedText ?? musicWidget.currentLyric?.text),
               !lyricText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(lyricText).font(.system(size: 12, weight: .medium)).foregroundColor(musicWidget.accentColor)
                    .multilineTextAlignment(.center).lineLimit(2).frame(minHeight: 35, alignment: .center)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3))).id(musicWidget.currentLyric?.id)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        
                        activeView = .lyrics
                    }
            }
            
            HStack {
                Button(action: { handleButtonTap(for: .queueAndPlaylists) }) { Image(systemName: "list.bullet").font(.system(size: 20)) }.foregroundColor(.secondary).frame(width: 40, height: 40).contentShape(Rectangle())
                Spacer()
                Button(action: { musicWidget.previousTrack() }) { Image(systemName: "backward.fill") }.frame(width: 44, height: 44).contentShape(Rectangle())
                Spacer()
                Button(action: { musicWidget.isPlaying ? musicWidget.pause() : musicWidget.play() }) { Image(systemName: musicWidget.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 28)) }.frame(width: 44, height: 44).contentShape(Rectangle())
                Spacer()
                Button(action: { musicWidget.nextTrack() }) { Image(systemName: "forward.fill") }.frame(width: 44, height: 44).contentShape(Rectangle())
                Spacer()
                Button(action: { handleButtonTap(for: .devices) }) { Image(systemName: "hifispeaker").font(.system(size: 18)) }.foregroundColor(.secondary).frame(width: 40, height: 40).contentShape(Rectangle())
            }.buttonStyle(BlurButtonStyle()).font(.system(size: 22)).foregroundColor(.primary)
            .padding(.top, musicWidget.currentLyric == nil ? 10 : 0)
            .padding(.bottom, musicWidget.currentLyric == nil ? 5 : 0)
        }
        .frame(width: 400).padding(10)
        .animation(.easeInOut(duration: 0.3), value: musicWidget.currentLyric)
    }
    
    
    private func handleButtonTap(for view: ActiveView) {
        if spotifyManager.isAuthenticated { activeView = view }
        else { activeView = .loginPrompt }
    }
    
    private func dismissSubView() { activeView = .player }
    private func formatTime(_ seconds: Double) -> String {
        let cleanSeconds = seconds.isNaN || seconds.isInfinite ? 0 : seconds
        let (minutes, seconds) = (Int(cleanSeconds) / 60, Int(cleanSeconds) % 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}
