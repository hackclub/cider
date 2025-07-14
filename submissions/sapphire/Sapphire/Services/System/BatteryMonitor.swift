//
//  BatteryMonitor.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-03.
//

import Foundation
import IOKit.ps

class BatteryMonitor: ObservableObject {
    @Published var currentState: BatteryState?

    private var runLoopSource: CFRunLoopSource?

    init() {
        setupBatteryChangeNotification()
        updateBatteryState()
    }

    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    private func setupBatteryChangeNotification() {
        let callback: IOPowerSourceCallbackType = { _ in
            DispatchQueue.main.async {
                BatteryMonitor.shared?.updateBatteryState()
            }
        }

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        if let source = IOPSNotificationCreateRunLoopSource(callback, context)?.takeRetainedValue() {
            runLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        } else {
        }

        BatteryMonitor.shared = self
    }

    private static var shared: BatteryMonitor?

    private func updateBatteryState() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let powerSource = sources.first,
              let info = IOPSGetPowerSourceDescription(snapshot, powerSource)?.takeUnretainedValue() as? [String: AnyObject] else {
            return
        }

        let level = info[kIOPSCurrentCapacityKey] as? Int ?? -1
        let isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
        let sourceState = info[kIOPSPowerSourceStateKey] as? String ?? ""

        
        let newState = BatteryState(
            level: level,
            isCharging: isCharging,
            isPluggedIn: sourceState == kIOPSACPowerValue
        )

        
        if newState != currentState {
            currentState = newState
        }
    }
}
