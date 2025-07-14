//
//  SpotifyAPIManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import Foundation
import Combine
import AppKit


enum PlaybackResult {
    case success
    case failure(reason: String)
    case requiresPremium
    case requiresSpotifyAppOpen
}

class SpotifyAPIManager: ObservableObject {
    static let shared = SpotifyAPIManager()
    
    
    private var clientId = "79b4d096a6f8415f8c7fc678647f4482"
    private var clientSecret = "fe9a27b5e3324a949d94f67ecc86d791"
    private let redirectURI = "sapphire://callback"

    @Published var isAuthenticated = false
    @Published var userProfile: UserProfile?
    @Published var isPremiumUser = false

    private var accessToken: String?
    private var refreshToken: String?
    
    private let settingsModel = SettingsModel()

    private init() {
        clientId = settingsModel.settings.spotifyClientId
        clientSecret = settingsModel.settings.spotifyClientSecret
    }
    
    
    
    func login() {
        
        let scope = "user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private user-read-private"
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
        ]
        guard let url = components.url else { return }
        NSWorkspace.shared.open(url)
    }
    
    func handleRedirect(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        Task { await self.exchangeCodeForToken(code: code) }
    }
    
    private struct TokenResponse: Decodable {
        let accessToken: String, refreshToken: String?, expiresIn: Int
        enum CodingKeys: String, CodingKey { case accessToken = "access_token", refreshToken = "refresh_token", expiresIn = "expires_in" }
    }
    
    private func exchangeCodeForToken(code: String) async {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
        ]
        request.httpBody = components.query?.data(using: .utf8)
        let authHeader = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            await MainActor.run {
                self.accessToken = tokenResponse.accessToken
                self.refreshToken = tokenResponse.refreshToken
                self.isAuthenticated = true
                Task { await self.fetchUserProfile() }
            }
        } catch { print("--> TOKEN ERROR: \(error)") }
    }

    
    private func makeAPIRequest<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil) async -> T? {
            guard isAuthenticated, let token = accessToken else {
                return nil
            }
            
            
            #if DEBUG
            if url.path.contains("audio-analysis") {
            }
            #endif

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            if let body = body { request.httpBody = body; request.addValue("application/json", forHTTPHeaderField: "Content-Type") }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return nil
                }
                
                if (200...299).contains(httpResponse.statusCode) && url.path.contains("audio-analysis") {
                } else if let jsonString = String(data: data, encoding: .utf8), !jsonString.isEmpty {
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 403 && url.path.contains("audio-analysis") {
                    } else {
                        let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                    }
                    return nil
                }
                
                if data.isEmpty, T.self == Bool.self { return true as? T }
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return nil
            }
        }
    
    
    private func isSpotifyAppRunning() -> Bool {
        return NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "com.spotify.client" }
    }
    
    private func runAppleScript(_ script: String) -> Bool {
        guard isSpotifyAppRunning() else { return false }
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let err = error { print("--> AppleScript Error: \(err)"); return false }
            return true
        }
        return false
    }
    
    func getLocalVolume() -> Int? {
        guard isSpotifyAppRunning() else { return nil }
        let script = "if application \"Spotify\" is running then tell application \"Spotify\" to get sound volume"
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            if error == nil, let volume = result.int32Value as? Int {
                return volume
            }
        }
        return nil
    }

    
    
    private struct PlayBody: Encodable { var context_uri: String? = nil; var uris: [String]? = nil }
    private struct TransferPlaybackBody: Encodable { let device_ids: [String]; let play: Bool }
    
    func fetchUserProfile() async {
        guard isAuthenticated, let url = URL(string: "https://api.spotify.com/v1/me") else { return }
        let profile: UserProfile? = await makeAPIRequest(url: url)
        await MainActor.run {
            self.userProfile = profile
            self.isPremiumUser = (profile?.product == "premium")
        }
    }
    
    func playTrack(uri: String) async -> PlaybackResult {
        if isPremiumUser {
            guard let url = URL(string: "https://api.spotify.com/v1/me/player/play") else { return .failure(reason: "Invalid URL") }
            let body = PlayBody(uris: [uri])
            guard let bodyData = try? JSONEncoder().encode(body) else { return .failure(reason: "Encoding failed") }
            let success: Bool? = await makeAPIRequest(url: url, method: "PUT", body: bodyData)
            return success == true ? .success : .failure(reason: "API request failed")
        } else {
            if isSpotifyAppRunning() {
                guard let url = URL(string: uri) else { return .failure(reason: "Invalid URI") }
                await MainActor.run { NSWorkspace.shared.open(url) }
                return .success
            } else { return .requiresSpotifyAppOpen }
        }
    }
    
    private func getLocalCurrentTrack() -> SpotifyTrack? {
        guard isSpotifyAppRunning() else { return nil }
        
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing or player state is paused then
                    return (get name of current track) & "|" & (get artist of current track) & "|" & (get album of current track) & "|" & (get spotify url of current track) & "|" & (get id of current track)
                else
                    return ""
                end if
            end tell
        end if
        return ""
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            if error == nil, let resultString = result.stringValue, !resultString.isEmpty {
                let parts = resultString.components(separatedBy: "|")
                if parts.count == 5 {
                    
                    let mockAlbum = SpotifyAlbum(images: [])
                    return SpotifyTrack(
                        id: parts[4],
                        name: parts[0],
                        uri: parts[3],
                        album: mockAlbum,
                        artists: [SpotifyArtist(name: parts[1])]
                    )
                }
            }
        }
        return nil
    }
    
    
    func playPlaylist(contextUri: String) async -> PlaybackResult {
        if isPremiumUser {
            guard let url = URL(string: "https://api.spotify.com/v1/me/player/play") else { return .failure(reason: "Invalid URL") }
            let body = PlayBody(context_uri: contextUri)
            guard let bodyData = try? JSONEncoder().encode(body) else { return .failure(reason: "Encoding failed") }
            let success: Bool? = await makeAPIRequest(url: url, method: "PUT", body: bodyData)
            return success == true ? .success : .failure(reason: "API request failed")
        } else {
            if isSpotifyAppRunning() {
                guard let url = URL(string: contextUri) else { return .failure(reason: "Invalid URI") }
                await MainActor.run { NSWorkspace.shared.open(url) }
                return .success
            } else { return .requiresSpotifyAppOpen }
        }
    }

    func setVolume(percent: Int) async -> PlaybackResult {
        if isPremiumUser {
            guard var components = URLComponents(string: "https://api.spotify.com/v1/me/player/volume") else { return .failure(reason: "Invalid URL") }
            components.queryItems = [URLQueryItem(name: "volume_percent", value: "\(percent)")]
            guard let url = components.url else { return .failure(reason: "Invalid URL") }
            let success: Bool? = await makeAPIRequest(url: url, method: "PUT")
            return success == true ? .success : .failure(reason: "API request failed")
        } else {
            if isSpotifyAppRunning() {
                let script = "tell application \"Spotify\" to set sound volume to \(percent)"
                let success = runAppleScript(script)
                return success ? .success : .failure(reason: "AppleScript failed")
            } else { return .requiresSpotifyAppOpen }
        }
    }

    func transferPlayback(to deviceId: String) async -> PlaybackResult {
        guard isPremiumUser else { return .requiresPremium }
        guard let url = URL(string: "https://api.spotify.com/v1/me/player") else { return .failure(reason: "Invalid URL") }
        let body = TransferPlaybackBody(device_ids: [deviceId], play: true)
        guard let bodyData = try? JSONEncoder().encode(body) else { return .failure(reason: "Encoding failed") }
        let success: Bool? = await makeAPIRequest(url: url, method: "PUT", body: bodyData)
        return success == true ? .success : .failure(reason: "API request failed")
    }
    
    func fetchQueue() async -> SpotifyQueue? {
        
        guard isPremiumUser else {
            return nil
        }
        
        guard let url = URL(string: "https://api.spotify.com/v1/me/player/queue") else { return nil }
        
        
        let queue: SpotifyQueue? = await makeAPIRequest(url: url)
        
        if queue == nil {
        } else {
        }
        return queue
    }


    func fetchPlaylists() async -> [SpotifyPlaylist] {
        guard isAuthenticated, let url = URL(string: "https://api.spotify.com/v1/me/playlists") else { return [] }
        struct PlaylistResponse: Decodable { let items: [SpotifyPlaylist] }
        let response: PlaylistResponse? = await makeAPIRequest(url: url)
        return response?.items ?? []
    }

    func fetchDevices() async -> [SpotifyDevice] {
        guard isPremiumUser, let url = URL(string: "https://api.spotify.com/v1/me/player/devices") else { return [] }
        struct DevicesResponse: Decodable { let devices: [SpotifyDevice] }
        let response: DevicesResponse? = await makeAPIRequest(url: url)
        return response?.devices ?? []
    }
    
    func fetchPlaybackState() async -> PlaybackState? {
        guard isPremiumUser, let url = URL(string: "https://api.spotify.com/v1/me/player") else { return nil }
        return await makeAPIRequest(url: url)
    }
    
    func fetchAudioAnalysis(for trackId: String) async -> AudioAnalysis? {
        guard isAuthenticated, let url = URL(string: "https://api.spotify.com/v1/audio-analysis/\(trackId)") else {
            return nil
        }
        return await makeAPIRequest(url: url)
    }

    func searchForTrack(title: String, artist: String) async -> SpotifyTrack? {
        guard isAuthenticated else { return nil }
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        
        let query = "track:\"\(title.trimmingCharacters(in: .whitespacesAndNewlines))\" artist:\"\(artist.trimmingCharacters(in: .whitespacesAndNewlines))\""
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "1") 
        ]
        guard let url = components.url else { return nil }
        
        let response: SearchResponse? = await makeAPIRequest(url: url)
        return response?.tracks.items.first
    }
}
