//
//  SpotifyModels.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import Foundation


struct SpotifyImage: Codable {
    let url: String
}

struct SpotifyAlbum: Codable {
    let images: [SpotifyImage]
}

struct SpotifyArtist: Codable {
    let name: String
}



struct PlaybackState: Codable {
    let device: SpotifyDevice
    let item: SpotifyTrack? 
    let isPlaying: Bool
    let progressMs: Int?

    enum CodingKeys: String, CodingKey {
        case device, item, progressMs = "progress_ms", isPlaying = "is_playing"
    }
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let displayName: String
    let product: String 

    enum CodingKeys: String, CodingKey {
        case id, product, displayName = "display_name"
    }
}


struct SpotifyUserSimple: Codable, Identifiable {
    let id: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id, displayName = "display_name"
    }
}

struct SpotifyTrack: Codable, Identifiable {
    let id: String
    let name: String
    let uri: String
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]
    
    var imageURL: URL? {
        guard let urlString = images.first?.url else { return nil }
        return URL(string: urlString)
    }
    
    private var images: [SpotifyImage] {
        return album.images
    }
}

struct SpotifyPlaylist: Codable, Identifiable {
    let id: String
    let name: String
    let uri: String
    let images: [SpotifyImage]
    
    let owner: SpotifyUserSimple
    
    var imageURL: URL? {
        guard let urlString = images.first?.url else { return nil }
        return URL(string: urlString)
    }
}

struct SpotifyDevice: Codable, Identifiable {
    let id: String?
    let name: String
    let type: String
    let isActive: Bool
    let volumePercent: Int?
    enum CodingKeys: String, CodingKey { case id, name, type, isActive = "is_active", volumePercent = "volume_percent" }
}

struct SpotifyQueue: Codable {
    let currentlyPlaying: SpotifyTrack?
    let queue: [SpotifyTrack]
    enum CodingKeys: String, CodingKey { case currentlyPlaying = "currently_playing", queue }
}


struct AudioAnalysis: Codable {
    let segments: [AnalysisSegment]
}

struct AnalysisSegment: Codable {
    let start: Double
    let duration: Double
    let loudness_max: Double
    
    enum CodingKeys: String, CodingKey {
        case start, duration
        case loudness_max = "loudness_max"
    }
}


struct SearchResponse: Codable {
    let tracks: TrackSearchResult
}

struct TrackSearchResult: Codable {
    let items: [SpotifyTrack]
}
