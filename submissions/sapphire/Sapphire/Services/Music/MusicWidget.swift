//
//  MusicWidget.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-05-09.
//

import Foundation
import MediaRemoteAdapter
import AppKit
import Combine
import SwiftUICore
import AudioToolbox

enum PlayerAction: Equatable {
    case played, paused, skippedForward, skippedBackward, trackChanged
}

class MusicWidget: ObservableObject {

    private let mediaController = MediaController()
    private let lyricsFetcher = LyricsFetcher()
    let playerActionPublisher = PassthroughSubject<PlayerAction, Never>()
    
    
    @Published var title: String?
    @Published var artist: String?
    @Published var album: String?
    @Published var artwork: NSImage?
    @Published var isPlaying: Bool = false
    @Published var playbackProgress: Double = 0.0
    @Published var currentElapsedTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var lyrics: [LyricLine] = []
    @Published var currentLyric: LyricLine?
    @Published var accentColor: Color = .white
    @Published var leftGradientColor: Color = .white
    @Published var rightGradientColor: Color = .white
    @Published var appIcon: NSImage?
    @Published var systemVolume: Float = 0.0
    @Published var isDisplayingTransientIcon: Bool = false
    @Published var shouldShowLiveActivity: Bool = false
    
    
    @Published var lyricsTapped: Bool = false

    
    private var volumeListener: AudioObjectPropertyListenerBlock?
    private var currentTrackDuration: TimeInterval = 0
    private var lastFetchedTitle: String?
    private var lastKnownBundleID: String?
    private var cancellables = Set<AnyCancellable>()
    private var justSkipped = false
    private var skipDebounceTimer: Timer?

    init() {
        setupHandlers()
        setupNotificationObservers()
        setupVolumeListener()
        setupDerivedStatePublisher()
        mediaController.startListening()
    }
    
    deinit {
        mediaController.stop()
        removeVolumeListener()
        NotificationCenter.default.removeObserver(self)
        skipDebounceTimer?.invalidate()
    }
    
    private func setupDerivedStatePublisher() {
        Publishers.CombineLatest($isPlaying, $isDisplayingTransientIcon)
            .map { isPlaying, isDisplayingIcon in return isPlaying || isDisplayingIcon }
            .removeDuplicates().assign(to: \.shouldShowLiveActivity, on: self).store(in: &cancellables)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayPause), name: .mediaKeyPlayPausePressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNextTrack), name: .mediaKeyNextPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePreviousTrack), name: .mediaKeyPreviousPressed, object: nil)
    }
    
    private func setupHandlers() {
        mediaController.onTrackInfoReceived = { [weak self] trackInfo in
            guard let self = self else { return }
            let payload = trackInfo.payload
            DispatchQueue.main.async {
                let hasTrackChanged = payload.title != self.lastFetchedTitle
                self.title = payload.title; self.artist = payload.artist; self.album = payload.album
                if let newArtwork = payload.artwork {
                    self.artwork = newArtwork
                    if let edgeColors = newArtwork.getEdgeColors() { self.accentColor = edgeColors.accent; self.leftGradientColor = edgeColors.left; self.rightGradientColor = edgeColors.right }
                    else { self.resetColorsToDefault() }
                } else { self.artwork = nil; self.resetColorsToDefault() }
                if let newIsPlaying = payload.isPlaying {
                    if self.isPlaying && !newIsPlaying { self.playerActionPublisher.send(.paused) }
                    else if !self.isPlaying && newIsPlaying { self.playerActionPublisher.send(.played) }
                    self.isPlaying = newIsPlaying
                }
                self.currentTrackDuration = TimeInterval(payload.durationMicros ?? 0) / 1_000_000
                self.totalDuration = self.currentTrackDuration
                if hasTrackChanged {
                    self.lastFetchedTitle = payload.title
                    self.fetchAndTranslateLyricsIfNeeded()
                    if !self.justSkipped { self.playerActionPublisher.send(.trackChanged) }
                }
                if payload.bundleIdentifier != self.lastKnownBundleID {
                    self.lastKnownBundleID = payload.bundleIdentifier
                    self.fetchAppIcon(for: payload.bundleIdentifier)
                }
            }
        }
        mediaController.onPlaybackTimeUpdate = { [weak self] elapsedTime in
            guard let self = self, self.currentTrackDuration > 0 else { return }
            DispatchQueue.main.async {
                self.playbackProgress = max(0.0, min(1.0, elapsedTime / self.currentTrackDuration))
                self.currentElapsedTime = elapsedTime
                self.updateCurrentLyric(for: elapsedTime)
            }
        }
        mediaController.onListenerTerminated = { print("[MusicWidget] Error: The media listener process was terminated.") }
        mediaController.onDecodingError = { error, data in print("[MusicWidget] Decoding Error: \(error)") }
    }
    
    private func setupVolumeListener() {
        self.systemVolume = SystemControl.getVolume()
        guard let deviceID = getDefaultOutputDeviceID() else { return }
        var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyVolumeScalar, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        self.volumeListener = { [weak self] _, _ in DispatchQueue.main.async { self?.systemVolume = SystemControl.getVolume() } }
        AudioObjectAddPropertyListenerBlock(deviceID, &address, nil, self.volumeListener!)
    }

    private func removeVolumeListener() {
        guard let deviceID = getDefaultOutputDeviceID(), let listener = self.volumeListener else { return }
        var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyVolumeScalar, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        AudioObjectRemovePropertyListenerBlock(deviceID, &address, nil, listener)
    }
    
    private func getDefaultOutputDeviceID() -> AudioDeviceID? {
        var deviceID: AudioDeviceID = kAudioObjectUnknown, size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        return AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID) == noErr ? deviceID : nil
    }

    private func fetchAppIcon(for bundleIdentifier: String?) {
        guard let bundleId = bundleIdentifier, !bundleId.isEmpty, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else { DispatchQueue.main.async { self.appIcon = nil }; return }
        DispatchQueue.main.async { self.appIcon = NSWorkspace.shared.icon(forFile: url.path) }
    }

    private func fetchAndTranslateLyricsIfNeeded() {
        guard let title = self.title, let artist = self.artist, let album = self.album else { return }
        self.lyrics = []; self.currentLyric = nil
        Task {
            guard var fetchedLyrics = await lyricsFetcher.fetchSyncedLyrics(for: title, artist: artist, album: album), !fetchedLyrics.isEmpty else { return }
            await MainActor.run { self.lyrics = fetchedLyrics }
            let sampleText = fetchedLyrics.prefix(5).map { $0.text }.joined(separator: " ")
            guard !sampleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let lang = await lyricsFetcher.detectLanguage(for: sampleText) else { return }
            if lang != "en" { await lyricsFetcher.translate(lyrics: &fetchedLyrics, from: lang, to: "en"); await MainActor.run { self.lyrics = fetchedLyrics } }
        }
    }
    
    private func updateCurrentLyric(for elapsedTime: TimeInterval) {
        let newLyric = lyrics.last { $0.timestamp <= elapsedTime }
        if newLyric?.id != self.currentLyric?.id { self.currentLyric = newLyric }
    }
    
    private func resetColorsToDefault() {
        let defaultAccent = Color(red: 0.53, green: 0.73, blue: 0.88)
        self.accentColor = defaultAccent; self.leftGradientColor = defaultAccent; self.rightGradientColor = defaultAccent.opacity(0.7)
    }
    
    private func handleSkipAction(isForward: Bool) {
        justSkipped = true
        skipDebounceTimer?.invalidate()
        skipDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in self?.justSkipped = false }
        if isForward { mediaController.nextTrack() }
        else { mediaController.previousTrack() }
    }
    
    
    func play() { mediaController.play(); playerActionPublisher.send(.played) }
    func pause() { mediaController.pause(); playerActionPublisher.send(.paused) }
    func nextTrack() { handleSkipAction(isForward: true) }
    func previousTrack() { handleSkipAction(isForward: false) }
    func seek(to seconds: Double) { mediaController.setTime(seconds: seconds) }
    
    
    @objc private func handlePlayPause() { isPlaying ? pause() : play() }
    @objc private func handleNextTrack() { nextTrack() }
    @objc private func handlePreviousTrack() { previousTrack() }
}
