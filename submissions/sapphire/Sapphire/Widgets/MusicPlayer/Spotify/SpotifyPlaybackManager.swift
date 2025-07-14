//
//  SpotifyPlaybackManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import Foundation


class SpotifyPlaybackManager {
    static let shared = SpotifyPlaybackManager()
    
    
    
    private var localPlayer: LibrespotSession?

    init() {
        
        
        self.localPlayer = LibrespotSession()
    }

    
    func play(trackUri: String) {
        let spotifyManager = SpotifyAPIManager.shared
        
        
        if spotifyManager.isPremiumUser {
            
            
            Task {
                await spotifyManager.playTrack(uri: trackUri)
            }
        } else {
            
            
            
            
            localPlayer?.play(uri: trackUri)
        }
    }
    
    
    func play(contextUri: String) {
        let spotifyManager = SpotifyAPIManager.shared
        
        if spotifyManager.isPremiumUser {
            Task {
                await spotifyManager.playPlaylist(contextUri: contextUri)
            }
        } else {
            localPlayer?.play(contextUri: contextUri)
        }
    }
}



struct LibrespotSession {
    func play(uri: String) {
        
        
        
        
        
        
    }
    
    func play(contextUri: String) {
    }
}
