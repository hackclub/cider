//
//  QueueAndPlaylistsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import SwiftUI


struct CustomUnavailableView: View {
    let title: String
    let systemImage: String
    var description: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage).font(.largeTitle).foregroundColor(.secondary.opacity(0.7))
            Text(title).font(.headline).foregroundColor(.primary)
            if let description = description {
                Text(description).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            }
        }.frame(maxHeight: .infinity)
    }
}


struct QueueAndPlaylistsView: View {
    var onDismiss: () -> Void
    @State private var selection: Int = 0
    @State private var queue: SpotifyQueue?
    @State private var playlists: [SpotifyPlaylist] = []
    @State private var isLoading = true
    @State private var showSpotifyNotOpenAlert = false

    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                Button(action: onDismiss) { Image(systemName: "chevron.left"); Text("Back") }
                .buttonStyle(.plain).foregroundColor(.secondary)
                Spacer()
            }.font(.system(size: 18))

            
            HStack(spacing: 10) {
                TabButton(title: "Queue", systemImage: "list.bullet.rectangle", isSelected: selection == 0) { selection = 0 }
                TabButton(title: "Playlists", systemImage: "music.note.list", isSelected: selection == 1) { selection = 1 }
            }

            
            if isLoading {
                ProgressView().frame(maxHeight: .infinity)
            } else {
                if selection == 0 { queueView }
                else { playlistsView }
            }
            
            
        }
        .padding(20)
        .onAppear(perform: fetchData)
        .alert("Spotify App Is Not Open", isPresented: $showSpotifyNotOpenAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("To control playback with a free account, please open the Spotify desktop app first.")
        }
    }
    
    private func fetchData() {
        Task {
            async let queueData = SpotifyAPIManager.shared.fetchQueue()
            async let playlistsData = SpotifyAPIManager.shared.fetchPlaylists()
            self.queue = await queueData
            self.playlists = await playlistsData
            self.isLoading = false
        }
    }

    
    
    private var queueView: some View {
        ScrollView {
            if let queue = queue, let nowPlaying = queue.currentlyPlaying {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Now Playing")
                    QueueTrackRow(track: nowPlaying, onPlay: handlePlaybackResult)

                    if !queue.queue.isEmpty {
                        SectionHeader(title: "Next Up")
                        ForEach(queue.queue) { track in
                            QueueTrackRow(track: track, onPlay: handlePlaybackResult)
                        }
                    } else {
                        CustomUnavailableView(title: "No Songs Up Next", systemImage: "music.note.list", description: "Add songs to your queue in the Spotify app to see them here.").padding(.top, 20)
                    }
                }
            } else {
                CustomUnavailableView(title: "Queue Unavailable", systemImage: "speaker.slash.fill", description: "Start playing music in Spotify and ensure you have a Premium account to view your queue.")
            }
        }
    }

    private var playlistsView: some View {
        ScrollView {
            if !playlists.isEmpty {
                VStack(spacing: 10) {
                    ForEach(playlists) { playlist in
                        FullPlaylistRow(playlist: playlist, onPlay: handlePlaybackResult)
                    }
                }
            } else {
                CustomUnavailableView(title: "No Playlists Found", systemImage: "music.mic")
            }
        }
    }

    private func handlePlaybackResult(_ result: PlaybackResult) {
        switch result {
        case .requiresSpotifyAppOpen:
            showSpotifyNotOpenAlert = true
        default:
            break
        }
    }
}

struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor : .clear)
        .foregroundColor(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View { Text(title).font(.headline).foregroundColor(.secondary).padding(.leading, 5) }
}

struct QueueTrackRow: View {
    let track: SpotifyTrack
    var onPlay: (PlaybackResult) -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: track.imageURL) { $0.resizable() } placeholder: { ZStack { Color.secondary.opacity(0.3); Image(systemName: "music.note") } }
                .frame(width: 45, height: 45).cornerRadius(6)
                .overlay(
                    ZStack {
                        if isHovered {
                            Color.black.opacity(0.5)
                            Image(systemName: "play.fill").font(.title3).foregroundColor(.white)
                        }
                    }.cornerRadius(6)
                )
            VStack(alignment: .leading) { Text(track.name).fontWeight(.medium).lineLimit(1); Text(track.artists.map(\.name).joined(separator: ", ")).font(.subheadline).foregroundColor(.secondary).lineLimit(1) }
            Spacer()
        }
        .padding(8).background(.thinMaterial).cornerRadius(10)
        
        .onHover { hovering in
            self.isHovered = hovering
        }
        .onTapGesture { performPlayback() }
        
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    private func performPlayback() {
        Task {
            let result = await SpotifyAPIManager.shared.playTrack(uri: track.uri)
            onPlay(result)
        }
    }
}

struct FullPlaylistRow: View {
    let playlist: SpotifyPlaylist
    var onPlay: (PlaybackResult) -> Void
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: playlist.imageURL) { $0.resizable() } placeholder: { ZStack { Color.secondary.opacity(0.3); Image(systemName: "music.note.list") } }
                .frame(width: 45, height: 45).cornerRadius(6)
            VStack(alignment: .leading) { Text(playlist.name).fontWeight(.medium).lineLimit(1); Text("By \(playlist.owner.displayName)").font(.subheadline).foregroundColor(.secondary).lineLimit(1) }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(8).background(.thinMaterial).cornerRadius(10)
        .onTapGesture { performPlayback() }
    }

    private func performPlayback() {
        Task {
            let result = await SpotifyAPIManager.shared.playPlaylist(contextUri: playlist.uri)
            onPlay(result)
        }
    }
}
