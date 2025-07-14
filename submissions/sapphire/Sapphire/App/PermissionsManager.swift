//
//  PermissionsManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI
import Combine
import CoreLocation
import EventKit
import AVFoundation
import UserNotifications
import ScreenCaptureKit
import CoreBluetooth
import Intents

enum PermissionType: Identifiable {
    case accessibility, notifications, location, calendar, bluetooth, focusStatus
    var id: Self { self }
}

enum PermissionStatus { case granted, denied, notRequested }

struct PermissionItem: Identifiable {
    let id = UUID()
    let type: PermissionType, title: String, description: String, iconName: String
    let iconColor: Color
}

@MainActor
class PermissionsManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {

    @Published var accessibilityStatus: PermissionStatus = .notRequested
    @Published var notificationsStatus: PermissionStatus = .notRequested
    @Published var locationStatus: PermissionStatus = .notRequested
    @Published var calendarStatus: PermissionStatus = .notRequested
    @Published var bluetoothStatus: PermissionStatus = .notRequested
    @Published var focusStatusStatus: PermissionStatus = .notRequested

    private var locationManager: CLLocationManager?
    private var bluetoothManager: CBCentralManager?

    let allPermissions: [PermissionItem] = [
        .init(type: .accessibility, title: "Accessibility", description: "Needed to detect media key presses for music and volume control.", iconName: "figure.wave.circle.fill", iconColor: .purple),
        .init(type: .notifications, title: "Notifications", description: "Needed to show custom alerts for messages and system events.", iconName: "bell.badge.fill", iconColor: .red),
        .init(type: .location, title: "Location", description: "Needed to provide live weather updates for your current location.", iconName: "location.fill", iconColor: .blue),
        .init(type: .calendar, title: "Calendar", description: "Needed to show your upcoming events.", iconName: "calendar", iconColor: .red),
        .init(type: .bluetooth, title: "Bluetooth", description: "Needed to detect connected devices and their battery levels.", iconName: "ipad.landscape.and.iphone", iconColor: .blue),
        .init(type: .focusStatus, title: "Focus Status", description: "Needed to show when a Focus mode is active.", iconName: "moon.fill", iconColor: .indigo)
    ]

    var areAllPermissionsGranted: Bool {
        accessibilityStatus == .granted &&
        notificationsStatus == .granted &&
        locationStatus == .granted &&
        calendarStatus == .granted &&
        bluetoothStatus == .granted &&
        focusStatusStatus == .granted
    }

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }

    func checkAllPermissions() {
        
        switch CBManager.authorization {
        case .allowedAlways:
            bluetoothStatus = .granted
        case .denied, .restricted:
            bluetoothStatus = .denied
        case .notDetermined:
            bluetoothStatus = .notRequested
        @unknown default:
            bluetoothStatus = .notRequested
        }
    }

    func status(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .accessibility: return accessibilityStatus
        case .notifications: return notificationsStatus
        case .location: return locationStatus
        case .calendar: return calendarStatus
        case .bluetooth: return bluetoothStatus
        case .focusStatus: return focusStatusStatus
        }
    }

    func requestPermission(_ type: PermissionType) {
        switch type {
        case .accessibility:
            self.accessibilityStatus = .granted

        case .notifications:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                DispatchQueue.main.async { self.notificationsStatus = granted ? .granted : .denied }
            }

        case .location:
            locationManager?.requestWhenInUseAuthorization()

        case .calendar:
            EKEventStore().requestFullAccessToEvents { granted, _ in
                DispatchQueue.main.async { self.calendarStatus = granted ? .granted : .denied }
            }

        case .bluetooth:
            
            
            if bluetoothManager?.state == .poweredOn {
                
                bluetoothManager?.scanForPeripherals(withServices: nil, options: nil)
            } else {
                
                DispatchQueue.main.async {
                    self.bluetoothStatus = .denied
                }
            }

        case .focusStatus:
            INFocusStatusCenter.default.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized: self.focusStatusStatus = .granted
                    case .denied: self.focusStatusStatus = .denied
                    case .notDetermined: self.focusStatusStatus = .notRequested
                    @unknown default: self.focusStatusStatus = .notRequested
                    }
                }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationStatus(for: manager.authorizationStatus)
    }

    private func updateLocationStatus(for status: CLAuthorizationStatus) {
        switch status {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .granted
        case .denied, .restricted:
            locationStatus = .denied
        case .notDetermined:
            locationStatus = .notRequested
        @unknown default:
            locationStatus = .notRequested
        }
    }

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            
            DispatchQueue.main.async {
                self.bluetoothStatus = .granted
            }
        case .poweredOff:
            
            DispatchQueue.main.async {
                self.bluetoothStatus = .denied
            }
        case .unauthorized:
            
            DispatchQueue.main.async {
                self.bluetoothStatus = .denied
            }
        case .unknown, .resetting:
            
            DispatchQueue.main.async {
                self.bluetoothStatus = .notRequested
            }
        @unknown default:
            DispatchQueue.main.async {
                self.bluetoothStatus = .notRequested
            }
        }
    }
}
