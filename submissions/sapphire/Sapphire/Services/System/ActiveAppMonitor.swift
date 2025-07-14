//
//  ActiveAppMonitor.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-09.
//

import AppKit
import Combine

@MainActor
class ActiveAppMonitor: ObservableObject {
    
    static let shared = ActiveAppMonitor()
    
    @Published private(set) var isLyricsAllowedForActiveApp: Bool = true

    private var activeAppBundleID: String?
    private let settingsModel: SettingsModel
    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.settingsModel = SettingsModel()
        
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .compactMap { ($0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bundleID in
                self?.activeAppBundleID = bundleID
                self?.updateLyricPermission()
            }
            .store(in: &cancellables)
        
        settingsModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateLyricPermission()
            }
            .store(in: &cancellables)
        
        if let initialApp = NSWorkspace.shared.frontmostApplication {
            self.activeAppBundleID = initialApp.bundleIdentifier
            self.updateLyricPermission()
        }
    }
    
    private func updateLyricPermission() {
        var newPermissionState = true
        
        
        

        guard settingsModel.settings.showLyricsInLiveActivity else {
            newPermissionState = false
            if isLyricsAllowedForActiveApp != newPermissionState { isLyricsAllowedForActiveApp = newPermissionState }
            return
        }
        
        guard let activeBundleID = activeAppBundleID else {
            newPermissionState = true
            if isLyricsAllowedForActiveApp != newPermissionState { isLyricsAllowedForActiveApp = newPermissionState }
            return
        }
        
        if let isAllowed = settingsModel.settings.musicAppStates[activeBundleID] {
            newPermissionState = isAllowed
            if isLyricsAllowedForActiveApp != newPermissionState { isLyricsAllowedForActiveApp = newPermissionState }
            return
        }
        
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: activeBundleID),
           let bundle = Bundle(url: appURL),
           let urlTypes = bundle.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            
            let isBrowser = urlTypes.contains { ($0["CFBundleURLSchemes"] as? [String])?.contains("http") ?? false }
            newPermissionState = !isBrowser
        }
        
        if isLyricsAllowedForActiveApp != newPermissionState {
            isLyricsAllowedForActiveApp = newPermissionState
        }
    }
}
