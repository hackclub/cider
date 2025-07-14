//
//  AudioDeviceManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-08.
//

import Foundation
import Combine
import AudioToolbox


struct AudioSwitchEvent: Hashable {
    enum Direction: Hashable {
        case switchedToMac
        case switchedAwayFromMac
    }
    
    let id = UUID()
    let deviceName: String
    let direction: Direction
}


class AudioDeviceManager: ObservableObject {
    @Published var lastSwitchEvent: AudioSwitchEvent?
    
    private var previousDeviceName: String?
    
    init() {
        
        DispatchQueue.main.async {
            self.setupAudioListener()
            
            self.previousDeviceName = self.getCurrentDeviceName()
        }
    }
    
    private func setupAudioListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        
        let propertyListener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.handleDeviceChange()
            }
        }
        
        let status = AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            nil, 
            propertyListener
        )
        
        if status != noErr {
        }
    }
    
    private func handleDeviceChange() {
        let newDeviceName = getCurrentDeviceName()
        
        
        guard newDeviceName != previousDeviceName else { return }
        
        
        let didSwitchAway = isAutoSwitchDevice(name: previousDeviceName) && !isAutoSwitchDevice(name: newDeviceName)
        let didSwitchTo = !isAutoSwitchDevice(name: previousDeviceName) && isAutoSwitchDevice(name: newDeviceName)
        
        if didSwitchAway, let name = previousDeviceName {
            lastSwitchEvent = AudioSwitchEvent(deviceName: name, direction: .switchedAwayFromMac)
        } else if didSwitchTo, let name = newDeviceName {
            lastSwitchEvent = AudioSwitchEvent(deviceName: name, direction: .switchedToMac)
        }
        
        
        self.previousDeviceName = newDeviceName
    }
    
    
    
    
    private func isAutoSwitchDevice(name: String?) -> Bool {
        guard let lowercasedName = name?.lowercased() else { return false }
        let keywords = ["airpods", "beats", "powerbeats"]
        return keywords.contains { lowercasedName.contains($0) }
    }
    
    private func getCurrentDeviceName() -> String? {
        var deviceID: AudioDeviceID = kAudioObjectUnknown
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID) == noErr else {
            return nil
        }
        
        return getDeviceName(for: deviceID)
    }
    
    private func getDeviceName(for deviceID: AudioDeviceID) -> String? {
        var name: CFString = "" as CFString
        var propertySize = UInt32(MemoryLayout<CFString>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        guard AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &name) == noErr else {
            return nil
        }
        
        return name as String
    }
}
