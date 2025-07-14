//
//  EyeBreakManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import Foundation
import Combine
import AppKit 

class EyeBreakManager: ObservableObject {
    private let settingsModel = SettingsModel()
    
    private var workInterval: TimeInterval { TimeInterval(settingsModel.settings.eyeBreakWorkInterval * 60) }
    private var breakInterval: TimeInterval { TimeInterval(settingsModel.settings.eyeBreakBreakDuration) }
    private var soundAlertsEnabled: Bool { settingsModel.settings.eyeBreakSoundAlerts }
    
    @Published var isBreakTime: Bool = false
    @Published var timeUntilNextBreak: TimeInterval
    @Published var timeRemainingInBreak: TimeInterval = 0
    @Published var isDoneButtonEnabled: Bool = false
    
    private var timer: Timer?

    init() {
        
        self.timeUntilNextBreak = 20 * 60
        
        startWorkTimer()
    }
    
    private func startWorkTimer() {
        isBreakTime = false
        isDoneButtonEnabled = false
        timeRemainingInBreak = 0
        
        timer?.invalidate()
        timeUntilNextBreak = workInterval 
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeUntilNextBreak > 0 {
                self.timeUntilNextBreak -= 1
            } else {
                self.startBreakTimer()
            }
        }
    }
    
    private func startBreakTimer() {
        timer?.invalidate()
        
        if soundAlertsEnabled {
            NSSound(named: "Glass")?.play()
        }
        
        isBreakTime = true
        isDoneButtonEnabled = false
        timeRemainingInBreak = breakInterval
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemainingInBreak > 0 {
                self.timeRemainingInBreak -= 1
            } else {
                self.isDoneButtonEnabled = true
                self.timer?.invalidate()
            }
        }
    }
    
    func dismissBreak() {
        resetAndStartWork()
    }
    
    func completeBreak() {
        resetAndStartWork()
    }
    
    private func resetAndStartWork() {
        self.startWorkTimer()
    }
}
