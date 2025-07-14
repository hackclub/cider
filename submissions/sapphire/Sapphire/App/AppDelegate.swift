//
//  AppDelegate.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import Cocoa
import SwiftUI
import Combine
import UserNotifications
import NearbyShare
import ApplicationServices
import IOBluetooth

@MainActor
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, MainAppDelegate {
    
    public var notchWindow: NSWindow?
    private var cgsSpace: CGSSpace?
    private var onboardingWindow: NSWindow?
    private var settingsWindow: NSWindow?
    
    
    private var settingsDelegate: SettingsWindowDelegate?

    var spotifyAPIManager: SpotifyAPIManager?
    var systemHUDManager: SystemHUDManager?
    var notificationManager: NotificationManager?
    var desktopManager: DesktopManager?
    var focusModeManager: FocusModeManager?
    var musicWidget: MusicWidget?
    var calendarService: CalendarService?
    var batteryMonitor: BatteryMonitor?
    var bluetoothManager: BluetoothManager?
    var audioDeviceManager: AudioDeviceManager?
    var eyeBreakManager: EyeBreakManager?
    var timerManager: TimerManager?
    var weatherActivityViewModel: WeatherActivityViewModel?
    var contentPickerHelper: ContentPickerHelper?
    var geminiLiveManager: GeminiLiveManager?
    var settingsModel: SettingsModel?
    var activeAppMonitor: ActiveAppMonitor?
    var liveActivityManager: LiveActivityManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            startMainApp()
        } else {
            showOnboardingWindow()
        }
    }
    
    func showOnboardingWindow() {
        if onboardingWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                styleMask: [.borderless],
                backing: .buffered, defer: false
            )
            
            window.center()
            window.title = "Welcome to Sapphire"
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true
            
            
            window.isOpaque = false
            window.backgroundColor = .clear
            
            
            let hostingView = NSHostingView(rootView: OnboardingView(onComplete: { self.onboardingDidComplete() }))
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor  
            
            window.contentView = hostingView
            onboardingWindow = window
        }

        
        onboardingWindow?.makeKeyAndOrderFront(nil)
        onboardingWindow?.level = .modalPanel 

        
        NSApp.activate(ignoringOtherApps: true)
    }

    
    func onboardingDidComplete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        self.onboardingWindow?.orderOut(nil)
        self.onboardingWindow = nil
        
        startMainApp()
    }
    
    func startMainApp() {
        self.spotifyAPIManager = .shared; self.systemHUDManager = .shared; self.notificationManager = NotificationManager()
        self.desktopManager = DesktopManager(); self.focusModeManager = FocusModeManager(); self.musicWidget = MusicWidget()
        self.calendarService = CalendarService(); self.batteryMonitor = BatteryMonitor(); self.bluetoothManager = BluetoothManager()
        self.audioDeviceManager = AudioDeviceManager(); self.eyeBreakManager = EyeBreakManager(); self.timerManager = TimerManager()
        self.weatherActivityViewModel = WeatherActivityViewModel(); self.contentPickerHelper = ContentPickerHelper()
        self.geminiLiveManager = GeminiLiveManager(); self.settingsModel = SettingsModel(); self.activeAppMonitor = .shared
        
        self.liveActivityManager = LiveActivityManager(
            systemHUDManager: systemHUDManager!, notificationManager: notificationManager!, desktopManager: desktopManager!,
            focusModeManager: focusModeManager!, musicWidget: musicWidget!, calendarService: calendarService!,
            batteryMonitor: batteryMonitor!, bluetoothManager: bluetoothManager!, audioDeviceManager: audioDeviceManager!,
            eyeBreakManager: eyeBreakManager!, timerManager: timerManager!, weatherActivityViewModel: weatherActivityViewModel!,
            geminiLiveManager: geminiLiveManager!, settingsModel: settingsModel!, activeAppMonitor: activeAppMonitor!
        )
        
        OSDManager.disableSystemHUD()
        _ = IOBluetoothDevice.pairedDevices()
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURL), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        createNotchWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenParametersChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        UNUserNotificationCenter.current().delegate = self
        NearbyConnectionManager.shared.mainAppDelegate = self
        NearbyConnectionManager.shared.becomeVisible()
        
        
        transitionToAgentApp()
    }
    
    private func transitionToAgentApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if NSApp.activationPolicy() != .accessory {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        OSDManager.enableSystemHUD()
        NSAppleEventManager.shared().removeEventHandler(forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        cgsSpace = nil
        NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    @objc func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) else { return }
        if url.scheme == "dynamicnotch" { spotifyAPIManager?.handleRedirect(url: url) }
    }

    func createNotchWindow() {
        notchWindow?.orderOut(nil); notchWindow?.close()
        guard let mainScreen = NSScreen.main else { return }
        let screenFrame = mainScreen.frame
        let paddedWindowWidth: CGFloat = 1200, paddedWindowHeight: CGFloat = 600
        let windowOriginX = (screenFrame.width - paddedWindowWidth) / 2, windowOriginY = screenFrame.maxY - paddedWindowHeight
        let windowRect = NSRect(x: windowOriginX, y: windowOriginY, width: paddedWindowWidth, height: paddedWindowHeight)
        let newWindow = NSWindow(contentRect: windowRect, styleMask: .borderless, backing: .buffered, defer: false)
        self.notchWindow = newWindow
        guard let window = self.notchWindow else { return }
        window.isOpaque = false; window.backgroundColor = .clear; window.hasShadow = false; window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.ignoresMouseEvents = true
        if self.cgsSpace == nil { self.cgsSpace = CGSSpace() }; self.cgsSpace?.windows.removeAll(); self.cgsSpace?.windows.insert(window)
        
        let notchControllerView = NotchController(notchWindow: window)
        let rootViewContainer = VStack(spacing: 0) { notchControllerView; Spacer() }.frame(width: paddedWindowWidth, height: paddedWindowHeight)
        
        let hostingView = NSHostingView(
            rootView: rootViewContainer
                .environmentObject(systemHUDManager!).environmentObject(musicWidget!).environmentObject(spotifyAPIManager!)
                .environmentObject(liveActivityManager!).environmentObject(audioDeviceManager!).environmentObject(bluetoothManager!)
                .environmentObject(notificationManager!).environmentObject(desktopManager!).environmentObject(focusModeManager!)
                .environmentObject(eyeBreakManager!).environmentObject(timerManager!).environmentObject(contentPickerHelper!)
                .environmentObject(geminiLiveManager!).environmentObject(settingsModel!).environmentObject(activeAppMonitor!)
        )
        hostingView.frame = NSRect(origin: .zero, size: windowRect.size)
        hostingView.autoresizingMask = [.width, .height]
        hostingView.wantsLayer = true; hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        window.contentView = hostingView; window.makeKeyAndOrderFront(nil)
    }
    
    func openSettingsWindow() {
        if let window = settingsWindow {
            NSApp.setActivationPolicy(.regular)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 950, height: 650),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        newWindow.center(); newWindow.isMovableByWindowBackground = true
        newWindow.title = "Sapphire Settings"
        
        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView.environment(\.window, newWindow).environmentObject(settingsModel!))
        newWindow.contentView = hostingView
        
        
        self.settingsDelegate = SettingsWindowDelegate {
            NSApp.setActivationPolicy(.accessory)
            self.settingsWindow = nil
        }
        newWindow.delegate = self.settingsDelegate
        
        self.settingsWindow = newWindow
        NSApp.setActivationPolicy(.regular)
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func screenParametersChanged(notification: Notification) {
        guard let window = self.notchWindow, let mainScreen = NSScreen.main else { createNotchWindow(); return }
        let screenFrame = mainScreen.frame, windowSize = window.frame.size
        let newOriginX = (screenFrame.width - windowSize.width) / 2, newOriginY = screenFrame.maxY - windowSize.height
        window.setFrame(NSRect(x: newOriginX, y: newOriginY, width: windowSize.width, height: windowSize.height), display: true, animate: false)
    }
    
    func obtainUserConsent(for transfer: TransferMetadata, from device: RemoteDeviceInfo, fileURLs: [URL]) {
        DispatchQueue.main.async { self.liveActivityManager?.startNearDropActivity(transfer: transfer, device: device, fileURLs: fileURLs) }
    }
    func incomingTransfer(id: String, didUpdateProgress progress: Double) {
        DispatchQueue.main.async { self.liveActivityManager?.updateNearDropProgress(id: id, progress: progress) }
    }
    func incomingTransfer(id: String, didFinishWith error: Error?) {
        DispatchQueue.main.async { self.liveActivityManager?.finishNearDropTransfer(id: id, error: error) }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let transferID = response.notification.request.content.userInfo["transferID"] as? String {
            let accepted = response.actionIdentifier == "ACCEPT"
            NearbyConnectionManager.shared.submitUserConsent(transferID: transferID, accept: accepted)
            if accepted { liveActivityManager?.updateNearDropState(to: .inProgress) } else { liveActivityManager?.clearNearDropActivity() }
        }
        completionHandler()
    }
}

fileprivate class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    var onClose: () -> Void
    init(onClose: @escaping () -> Void) { self.onClose = onClose }
    func windowWillClose(_ notification: Notification) { onClose() }
}
