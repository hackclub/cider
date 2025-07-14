//
//  SystemAudioMonitor.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-01.
//

import Foundation
import AVFoundation
import Combine
import CoreAudio
import Accelerate

class SystemAudioMonitor: ObservableObject {
    @Published var audioLevel: Float = 0.0

    private let engine = AVAudioEngine()
    private var isMonitoring = false
    
    init() {}

    func start() {
        guard !isMonitoring else { return }
        setupAndStartEngine()
    }

    func stop() {
        guard isMonitoring else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isMonitoring = false
    }
    
    private func setupAndStartEngine() {
        let inputNode = engine.inputNode
        
        guard let blackHoleDeviceID = findBlackHoleDeviceID() else {
            return
        }

        do {
            var deviceID = blackHoleDeviceID
            guard let audioUnit = inputNode.audioUnit else {
                print("[SystemAudioMonitor] ❌ Could not get AudioUnit for input node."); return
            }
            let error = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &deviceID, UInt32(MemoryLayout<AudioDeviceID>.size))
            if error != noErr {
                print("[SystemAudioMonitor] ❌ Failed to set input device. Error: \(error)"); return
            }
            try engine.start()
        } catch {
            print("[SystemAudioMonitor] ❌ Failed to start audio engine: \(error.localizedDescription)"); return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            let level = self?.calculateRMS(from: buffer) ?? 0.0
            DispatchQueue.main.async { self?.audioLevel = level }
        }
        
        isMonitoring = true
    }

    private func findBlackHoleDeviceID() -> AudioDeviceID? {
        var deviceID: AudioDeviceID = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )
        
        if status == noErr, let deviceName = getDeviceName(deviceID), deviceName.contains("BlackHole") {
            return deviceID
        }
        
        
        var devicesPropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        var devicesPropertySize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &devicesPropertySize) == noErr else { return nil }
        
        let deviceCount = Int(devicesPropertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &devicesPropertySize, &deviceIDs) == noErr else { return nil }
        
        for id in deviceIDs {
            if let name = getDeviceName(id), name.contains("BlackHole") {
                return id
            }
        }
        
        return nil
    }

    private func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var name: CFString = "" as CFString
        var propertySize = UInt32(MemoryLayout<CFString>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &name) == noErr else { return nil }
        return name as String
    }
    
    
    private func calculateRMS(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        let channelCount = Int(buffer.format.channelCount)
        var rms: Float = 0.0

        for channel in 0..<channelCount {
            let samples = channelData[channel]
            var channelRms: Float = 0.0
            vDSP_rmsqv(samples, 1, &channelRms, vDSP_Length(frameLength))
            rms += channelRms
        }
        
        let averageRms = rms / Float(channelCount)
        let amplifier: Float = 4.5
        let processedRms = min(1.0, averageRms * amplifier)
        
        return processedRms
    }
}
