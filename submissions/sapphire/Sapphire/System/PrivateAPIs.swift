//
//  PrivateAPIs.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import SwiftUI
import Cocoa
import AudioToolbox



fileprivate typealias CGSConnectionID = Int
fileprivate typealias CGSSpaceID = UInt64


@_silgen_name("_CGSDefaultConnection")
fileprivate func _CGSDefaultConnection() -> CGSConnectionID


@_silgen_name("CGSSpaceCreate")
fileprivate func CGSSpaceCreate(_ cid: CGSConnectionID, _ unknown: Int, _ options: NSDictionary?) -> CGSSpaceID
@_silgen_name("CGSSpaceDestroy")
fileprivate func CGSSpaceDestroy(_ cid: CGSConnectionID, _ space: CGSSpaceID)
@_silgen_name("CGSSpaceSetAbsoluteLevel")
fileprivate func CGSSpaceSetAbsoluteLevel(_ cid: CGSConnectionID, _ space: CGSSpaceID, _ level: Int)
@_silgen_name("CGSAddWindowsToSpaces")
fileprivate func CGSAddWindowsToSpaces(_ cid: CGSConnectionID, _ windows: NSArray, _ spaces: NSArray)
@_silgen_name("CGSRemoveWindowsFromSpaces")
fileprivate func CGSRemoveWindowsFromSpaces(_ cid: CGSConnectionID, _ windows: NSArray, _ spaces: NSArray)
@_silgen_name("CGSHideSpaces")
fileprivate func CGSHideSpaces(_ cid: CGSConnectionID, _ spaces: NSArray)
@_silgen_name("CGSShowSpaces")
fileprivate func CGSShowSpaces(_ cid: CGSConnectionID, _ spaces: NSArray)
@_silgen_name("CGSGetActiveSpace")
private func CGSGetActiveSpace(_ cid: CGSConnectionID) -> CGSSpaceID
@_silgen_name("CGSCopyManagedDisplaySpaces")
private func CGSCopyManagedDisplaySpaces(_ cid: CGSConnectionID) -> CFArray



@_silgen_name("DisplayServicesGetBrightness")
private func DisplayServicesGetBrightness(_ display: CGDirectDisplayID, _ brightness: UnsafeMutablePointer<Float>) -> Int32
@_silgen_name("DisplayServicesSetBrightness")
private func DisplayServicesSetBrightness(_ display: CGDirectDisplayID, _ brightness: Float) -> Int32



@_silgen_name("$s7SwiftUI5ImageV19_internalSystemNameACSS_tcfC")
private func _swiftUI_image(internalSystemName: String) -> Image?

extension Image {
    
    init?(privateName: String) {
        guard let systemImage = _swiftUI_image(internalSystemName: privateName) else {
            return nil
        }
        self = systemImage
    }
}




public final class CGSSpace {
    private let identifier: CGSSpaceID
    private let createdByInit: Bool
    private let connectionID: CGSConnectionID

    public var windows: Set<NSWindow> = [] {
        didSet {
            let remove = oldValue.subtracting(self.windows)
            let add = self.windows.subtracting(oldValue)

            if connectionID != 0 {
                 if !remove.isEmpty {
                     CGSRemoveWindowsFromSpaces(connectionID, remove.map { $0.windowNumber } as NSArray, [self.identifier] as NSArray)
                 }
                if !add.isEmpty {
                     CGSAddWindowsToSpaces(connectionID, add.map { $0.windowNumber } as NSArray, [self.identifier] as NSArray)
                }
            } else {
            }
        }
    }

    
    public init(level: Int = 0) {
        self.connectionID = _CGSDefaultConnection()
        let flag = 0x1
        
        self.identifier = CGSSpaceCreate(connectionID, flag, nil as NSDictionary?)
        CGSSpaceSetAbsoluteLevel(connectionID, self.identifier, level)
        CGSShowSpaces(connectionID, [self.identifier] as NSArray)
        self.createdByInit = true
    }

    deinit {
         if connectionID != 0 && identifier != 0 {
             CGSHideSpaces(connectionID, [self.identifier] as NSArray)
             if createdByInit {
                 CGSSpaceDestroy(connectionID, self.identifier)
             }
         }
    }
}




class OSDManager {
    static func disableSystemHUD() {
        let kickstart = Process()
        kickstart.launchPath = "/bin/launchctl"
        kickstart.arguments = ["kickstart", "gui/\(getuid())/com.apple.OSDUIHelper"]
        
        do {
            try kickstart.run()
            kickstart.waitUntilExit()
        } catch {
        }
        
        let stopProcess = Process()
        stopProcess.launchPath = "/usr/bin/killall"
        stopProcess.arguments = ["-STOP", "OSDUIHelper"]
        
        do {
            try stopProcess.run()
        } catch {
        }
    }
    
    static func enableSystemHUD() {
        let continueProcess = Process()
        continueProcess.launchPath = "/usr/bin/killall"
        continueProcess.arguments = ["-CONT", "OSDUIHelper"]
        
        do {
            try continueProcess.run()
        } catch {
        }
    }
}




struct SystemControl {

    
    private static func getDefaultOutputDeviceID() -> AudioDeviceID? {
        var deviceID: AudioDeviceID = kAudioObjectUnknown
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
        return status == noErr ? deviceID : nil
    }

    static func getVolume() -> Float {
        guard let deviceID = getDefaultOutputDeviceID() else { return 0.5 }
        var volume: Float32 = 0.0
        var propertySize = UInt32(MemoryLayout<Float32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &volume)
        return Float(volume)
    }

    static func setVolume(to level: Float) {
        guard let deviceID = getDefaultOutputDeviceID() else { return }
        var newVolume = Float32(max(0.0, min(1.0, level)))
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, UInt32(MemoryLayout.size(ofValue: newVolume)), &newVolume)
    }

    static func isMuted() -> Bool {
        guard let deviceID = getDefaultOutputDeviceID() else { return false }
        var isMuted: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &isMuted)
        return isMuted == 1
    }
    
    static func setMuted(to isMuted: Bool) {
        guard let deviceID = getDefaultOutputDeviceID() else { return }
        var muteVal: UInt32 = isMuted ? 1 : 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, UInt32(MemoryLayout.size(ofValue: muteVal)), &muteVal)
    }

    
    static func getBrightness() -> Float {
        var brightness: Float = 0.0
        guard let screen = NSScreen.main else { return 0.5 }
        let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
        if DisplayServicesGetBrightness(displayID, &brightness) != 0 {
            return 0.5
        }
        return brightness
    }

    static func setBrightness(to level: Float) {
        let clampedLevel = min(1.0, max(0.0, level))
        for screen in NSScreen.screens {
            let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
            DisplayServicesSetBrightness(displayID, clampedLevel)
        }
    }
}




struct CGSHelper {
    private static let connection = _CGSDefaultConnection()

    
    static func getActiveDesktopNumber() -> Int? {
        let activeSpaceID = CGSGetActiveSpace(connection)
        
        guard let displaySpaces = CGSCopyManagedDisplaySpaces(connection) as? [[String: Any]],
              let mainDisplay = displaySpaces.first,
              let spacesForMainDisplay = mainDisplay["Spaces"] as? [[String: Any]] else {
            return nil
        }
        
        if let index = spacesForMainDisplay.firstIndex(where: { ($0["id64"] as? CGSSpaceID) == activeSpaceID }) {
            return index + 1
        }
        
        return nil
    }
}
