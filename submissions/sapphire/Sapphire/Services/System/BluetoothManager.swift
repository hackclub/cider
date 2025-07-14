//
//  BluetoothManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-07.
//

import Foundation
import Combine
import IOBluetooth
import AppKit 
import IOKit.hid 
import IOKit 

struct BluetoothDeviceState: Hashable {
    enum EventType: Hashable {
        case connected, disconnected, batteryLow
    }
    let eventUUID = UUID()
    let id: String, name: String, iconName: String, eventType: EventType
    var batteryLevel: Int? = nil
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.eventUUID == rhs.eventUUID }
    func hash(into hasher: inout Hasher) { hasher.combine(eventUUID) }
}

class BluetoothManager: ObservableObject {
    @Published var lastEvent: BluetoothDeviceState?

    private var batteryCheckTimer: Timer?
    private var lowBatteryNotifiedDevices = Set<String>()
    
    
    private let privateMonitor = PrivateBluetoothMonitor()
    private var cancellables = Set<AnyCancellable>()

    private let lowBatteryThreshold = 20
    private let lowBatteryRefreshThreshold = 30

    init() {
        setupPrivateListener()
        setupBatteryMonitor()
    }
    
    private func setupPrivateListener() {
        privateMonitor.eventPublisher
            .sink { [weak self] event in
                self?.processPrivateEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func processPrivateEvent(_ event: PrivateBluetoothEvent) {
        
        guard let device = IOBluetoothDevice(addressString: event.address),
              let deviceName = device.name else { return }
        
        let batteryLevel = (event.type == .connected) ? self.getBatteryLevel(for: device) : nil
        
        
        if event.type == .disconnected {
            lowBatteryNotifiedDevices.remove(event.address)
        }
        
        let deviceState = BluetoothDeviceState(
            id: event.address,
            name: deviceName,
            iconName: Self.getIconName(for: device),
            eventType: (event.type == .connected) ? .connected : .disconnected,
            batteryLevel: batteryLevel
        )
        
        DispatchQueue.main.async {
            self.lastEvent = deviceState
        }
    }

    private func setupBatteryMonitor() {
        batteryCheckTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(checkForLowBattery), userInfo: nil, repeats: true)
        batteryCheckTimer?.fireDate = Date(timeIntervalSinceNow: 15.0)
    }

    @objc private func checkForLowBattery() {
        guard let pairedDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else { return }
        for device in pairedDevices where device.isConnected() {
            guard let addressString = device.addressString, let level = self.getBatteryLevel(for: device) else { continue }
            if level <= lowBatteryThreshold {
                if !lowBatteryNotifiedDevices.contains(addressString) {
                    let deviceState = BluetoothDeviceState(id: addressString, name: device.name ?? "Device", iconName: Self.getIconName(for: device), eventType: .batteryLow, batteryLevel: level)
                    DispatchQueue.main.async { self.lastEvent = deviceState; NSSound(named: "Tink")?.play() }
                    lowBatteryNotifiedDevices.insert(addressString)
                }
            } else if level >= lowBatteryRefreshThreshold {
                lowBatteryNotifiedDevices.remove(addressString)
            }
        }
    }
    
    private func getBatteryLevel(for device: IOBluetoothDevice) -> Int? {
        guard let deviceName = device.name else { return nil }
        let batteryKeys = ["BatteryPercent", "battery-level", "device-battery-level", "Battery Level"]
        var batteryLevel: Int?
        let matchingDict = IOServiceMatching(kIOHIDDeviceKey)
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == KERN_SUCCESS else { return nil }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            guard IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
                  let serviceProperties = properties?.takeRetainedValue() as? [String: Any] else {
                IOObjectRelease(service); service = IOIteratorNext(iterator); continue
            }
            if let productName = serviceProperties[kIOHIDProductKey] as? String, productName.caseInsensitiveCompare(deviceName) == .orderedSame {
                for key in batteryKeys {
                    if let level = serviceProperties[key] as? Int { batteryLevel = level; break }
                }
            }
            IOObjectRelease(service)
            if batteryLevel != nil { break }
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
        if batteryLevel == nil { print("--> BluetoothManager: No standard battery level key found for '\(deviceName)'.") }
        return batteryLevel
    }

    private static func getIconName(for device: IOBluetoothDevice) -> String {
        let majorClass = device.deviceClassMajor
        let minorClass = device.deviceClassMinor
        let deviceName = device.name?.lowercased() ?? ""
        if deviceName.contains("keyboard") || deviceName.contains("keys") { return "keyboard.fill" }
        switch majorClass {
        case UInt32(kBluetoothDeviceClassMajorPeripheral):
            switch minorClass {
            case UInt32(kBluetoothDeviceClassMinorPeripheral1Keyboard): return "keyboard.fill"
            case UInt32(kBluetoothDeviceClassMinorPeripheral1Pointing):
                if deviceName.contains("trackpad") { return "magictrackpad.gen2.fill" }
                if deviceName.contains("mouse") { return "magicmouse.fill" }
                return "cursorarrow.click.2"
            default:
                if deviceName.contains("controller") { return "gamecontroller.fill" }
                return "platter.filled.top.applewatch.case"
            }
        case UInt32(kBluetoothDeviceClassMajorAudio):
            if deviceName.contains("airpods max") { return "airpods.max" }
            if deviceName.contains("airpods pro") { return "airpodspro.right" }
            if deviceName.contains("airpods") { return "airpods" }
            if deviceName.contains("homepod") { return "homepod.fill" }
            if deviceName.contains("beats") { return "beats.headphones" }
            switch minorClass {
            case UInt32(kBluetoothDeviceClassMinorAudioHeadphones): return "headphones"
            case UInt32(kBluetoothDeviceClassMinorAudioLoudspeaker): return "speaker.wave.2.fill"
            default: return "headphones"
            }
        case UInt32(kBluetoothDeviceClassMajorComputer): return "desktopcomputer"
        case UInt32(kBluetoothDeviceClassMajorPhone): return "iphone"
        case UInt32(kBluetoothDeviceClassMajorWearable): return "applewatch"
        default: return "b.circle.fill"
        }
    }
}
