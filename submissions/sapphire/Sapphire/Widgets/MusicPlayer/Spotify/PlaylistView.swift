//
//  PlaylistView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import SwiftUI

struct PlaylistView: View {
    
    var onDismiss: () -> Void
    var onSelectPlaylist: (SpotifyPlaylist) -> Void

    
    @State private var playlists: [SpotifyPlaylist] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("Your Playlists")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary, .tertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding([.top, .horizontal], 20)
            .padding(.bottom, 15)

            
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxHeight: .infinity)
                } else if playlists.isEmpty {
                    Text("No playlists found.")
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(playlists) { playlist in
                                PlaylistRow(playlist: playlist)
                                    .onTapGesture {
                                        onSelectPlaylist(playlist)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear(perform: fetchPlaylists)
    }

    private func fetchPlaylists() {
        Task {
            
            let fetchedPlaylists = await SpotifyAPIManager.shared.fetchPlaylists()
            
            
            await MainActor.run {
                self.playlists = fetchedPlaylists
                self.isLoading = false
            }
        }
    }
}


struct PlaylistRow: View {
    let playlist: SpotifyPlaylist

    var body: some View {
        HStack(spacing: 12) {
            
            
            ZStack {
                Color.secondary.opacity(0.3)
                Image(systemName: "music.note.list")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text("By \(playlist.owner.displayName)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}
