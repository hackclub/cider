//
//  SystemHUD.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-06.
//

import SwiftUI
import AppKit
import Combine


fileprivate func eventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard type.rawValue == NX_SYSDEFINED else {
        return Unmanaged.passRetained(event)
    }
    
    
    if SystemHUDManager.shared.handleMediaKeyEvent(event) {
        return nil
    }
     
    return Unmanaged.passRetained(event)
}


extension Notification.Name {
    static let mediaKeyPlayPausePressed = Notification.Name("mediaKeyPlayPausePressed")
    static let mediaKeyNextPressed = Notification.Name("mediaKeyNextPressed")
    static let mediaKeyPreviousPressed = Notification.Name("mediaKeyPreviousPressed")
}



enum HUDType: Hashable {
    case volume(level: Float)
    case brightness(level: Float)
    
    var caseIdentifier: CaseIdentifier {
        switch self {
        case .volume: return .volume
        case .brightness: return .brightness
        }
    }
    enum CaseIdentifier { case volume, brightness }
}

private enum MediaKeyAction {
    case volumeUp, volumeDown
    case brightnessUp, brightnessDown
}


class SystemHUDManager: ObservableObject {
    static let shared = SystemHUDManager()
    
    @Published private(set) var currentHUD: HUDType?
    var style: HUDStyle = .default
    
    private var eventTap: CFMachPort?
    private var hudDismissalTimer: Timer?
    private var changeAnimator: Timer?
    private var currentAction: MediaKeyAction?
    private var isFineTuning: Bool = false
    private var keyPressStartTime: Date?

    private let initialStepAmount: Float = 1.0 / 16.0
    private let keyRepeatDelay: TimeInterval = 0.2
    private let animationInterval: TimeInterval = 1.0 / 60.0
    private let baseAnimationRate: Float = 1.0 / 2.0
    private let maxAnimationRate: Float = 1.0 / 0.7
    private let accelerationDuration: TimeInterval = 1.5
    private let fineAnimationRate: Float = 1.0 / 5.0

    private init() {
        setupEventTap()
    }
    
    private func setupEventTap() {
        let eventsToMonitor: CGEventMask = (1 << NX_SYSDEFINED)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventsToMonitor,
            callback: eventTapCallback,
            userInfo: nil
        )
        
        guard let eventTap = eventTap else {
            return
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    fileprivate func handleMediaKeyEvent(_ cgEvent: CGEvent) -> Bool {
        guard let nsEvent = NSEvent(cgEvent: cgEvent),
              nsEvent.type == .systemDefined,
              nsEvent.subtype.rawValue == 8 else {
            return false
        }
        
        let keyCode = Int32((nsEvent.data1 & 0xFFFF0000) >> 16)
        let keyState = (nsEvent.data1 & 0xFF00) >> 8
        let isKeyDown = (keyState == 0x0A)
        let isKeyUp = (keyState == 0x0B)
        
        

            switch keyCode {
            case NX_KEYTYPE_PLAY:
                NotificationCenter.default.post(name: .mediaKeyPlayPausePressed, object: nil)
                return true 
            case NX_KEYTYPE_FAST:
                NotificationCenter.default.post(name: .mediaKeyNextPressed, object: nil)
                return true 
            case NX_KEYTYPE_REWIND:
                NotificationCenter.default.post(name: .mediaKeyPreviousPressed, object: nil)
                return true 
            default:
                break 
            }


        let action: MediaKeyAction?
        switch keyCode {
            case NX_KEYTYPE_SOUND_UP: action = .volumeUp
            case NX_KEYTYPE_SOUND_DOWN: action = .volumeDown
            case NX_KEYTYPE_BRIGHTNESS_UP: action = .brightnessUp
            case NX_KEYTYPE_BRIGHTNESS_DOWN: action = .brightnessDown
            case NX_KEYTYPE_MUTE:
                if isKeyDown {
                    DispatchQueue.main.async { self.handleMute() }
                }
                return true
            default:
                return false
        }
        
        guard let validAction = action else { return false }
        
        DispatchQueue.main.async {
            if isKeyDown {
                if self.currentAction == nil {
                    self.startSmoothChange(for: validAction, with: nsEvent.modifierFlags)
                }
            } else if isKeyUp {
                if validAction == self.currentAction {
                    self.stopSmoothChange()
                }
            }
        }
        
        return true
    }

    private func handleMute() {
        stopSmoothChange()
        let isMuted = SystemControl.isMuted()
        SystemControl.setMuted(to: !isMuted)
        let currentVolume = SystemControl.getVolume()
        showHUD(for: .volume(level: !isMuted ? 0.0 : (currentVolume > 0 ? currentVolume : 0.01)))
        if !isMuted { NSSound(named: "Tink")?.play() }
    }
    
    private func startSmoothChange(for action: MediaKeyAction, with modifiers: NSEvent.ModifierFlags) {
        currentAction = action
        isFineTuning = modifiers.contains([.shift, .option])
        keyPressStartTime = Date()
        
        let initialStep = isFineTuning ? (initialStepAmount / 4.0) : initialStepAmount
        performChange(by: initialStep, isInitialPress: true)

        changeAnimator = Timer.scheduledTimer(
            timeInterval: animationInterval,
            target: self,
            selector: #selector(performAnimatedStep),
            userInfo: nil,
            repeats: true
        )
        changeAnimator?.fireDate = Date(timeIntervalSinceNow: keyRepeatDelay)
    }

    private func stopSmoothChange() {
        changeAnimator?.invalidate()
        changeAnimator = nil
        currentAction = nil
        keyPressStartTime = nil
    }

    @objc private func performAnimatedStep() {
        guard let startTime = keyPressStartTime else {
            stopSmoothChange()
            return
        }
        
        let effectiveRate: Float
        if isFineTuning {
            effectiveRate = fineAnimationRate
        } else {
            let duration = Date().timeIntervalSince(startTime)
            let elapsedSinceAnimationStart = max(0, duration - keyRepeatDelay)
            let progress = min(1.0, elapsedSinceAnimationStart / accelerationDuration)
            let easedProgress = Float(progress * progress)
            effectiveRate = baseAnimationRate + (maxAnimationRate - baseAnimationRate) * easedProgress
        }
        
        let step = effectiveRate * Float(animationInterval)
        performChange(by: step, isInitialPress: false)
    }
    
    private func performChange(by amount: Float, isInitialPress: Bool) {
        guard let action = currentAction else { return }

        switch action {
        case .volumeUp:
            let newVolume = min(1.0, SystemControl.getVolume() + amount)
            SystemControl.setVolume(to: newVolume)
            SystemControl.setMuted(to: false)
            showHUD(for: .volume(level: newVolume))
            if isInitialPress { NSSound(named: "Tink")?.play() }
        case .volumeDown:
            let newVolume = max(0.0, SystemControl.getVolume() - amount)
            SystemControl.setVolume(to: newVolume)
            SystemControl.setMuted(to: false)
            showHUD(for: .volume(level: newVolume))
            if isInitialPress { NSSound(named: "Tink")?.play() }
        case .brightnessUp:
            let newBrightness = min(1.0, SystemControl.getBrightness() + amount)
            SystemControl.setBrightness(to: newBrightness)
            showHUD(for: .brightness(level: newBrightness))
        case .brightnessDown:
            let newBrightness = max(0.0, SystemControl.getBrightness() - amount)
            SystemControl.setBrightness(to: newBrightness)
            showHUD(for: .brightness(level: newBrightness))
        }
    }

    private func showHUD(for hudType: HUDType) {
        self.currentHUD = hudType
        hudDismissalTimer?.invalidate()
        hudDismissalTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.currentHUD = nil
        }
    }
}


struct SystemHUDView: View {
    let type: HUDType
    @State private var isShowing = false

    private var iconName: String {
        switch type {
        case .volume(let level):
            if level == 0 { return "speaker.slash.fill" }
            if level < 0.33 { return "speaker.wave.1.fill" }
            if level < 0.66 { return "speaker.wave.2.fill" }
            return "speaker.wave.3.fill"
        case .brightness: return "sun.max.fill"
        }
    }

    private var level: Float {
        switch type {
        case .volume(let level): return level
        case .brightness(let level): return level
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(.white.opacity(0.1))
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 40, height: 40)
            
            ModernLinearIndicator(level: CGFloat(level))
                .frame(height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.thinMaterial)
        .background(.black.opacity(0.4))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
        .padding(.top, 30) 
        .frame(width: 240)
        .scaleEffect(isShowing ? 1 : 0.9)
        .opacity(isShowing ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isShowing = true
            }
        }
        .transition(.identity)
    }
}


struct SystemHUDSlimActivityView {
    static func left(type: HUDType) -> some View {
        let iconName: String = {
            switch type {
            case .volume(let level):
                if level == 0 { return "speaker.slash.fill" }
                if level < 0.33 { return "speaker.wave.1.fill" }
                if level < 0.66 { return "speaker.wave.2.fill" }
                return "speaker.wave.3.fill"
            case .brightness: return "sun.max.fill"
            }
        }()
        
        return ZStack {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .animation(nil, value: type)
        }
        .frame(width: 20, height: 20)
        .animation(.default, value: type.caseIdentifier)
    }

    static func right(type: HUDType) -> some View {
        let level: Float = {
            switch type {
            case .volume(let level): return level
            case .brightness(let level): return level
            }
        }()

        return ModernLinearIndicator(level: CGFloat(level))
            .frame(width: 100, height: 6)
            .fixedSize()
    }
}


struct ModernLinearIndicator: View {
    var level: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.primary.opacity(0.15))
                Capsule().fill(Color.white)
                    .frame(width: geometry.size.width * max(0, level))
                    .animation(.linear(duration: 0.05), value: level)
            }
        }
    }
}
