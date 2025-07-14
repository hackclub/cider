//
//  FocusModeManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import Foundation
import Combine
import Intents 



class FocusModeManager: ObservableObject {
    
    
    @Published private(set) var currentFocusMode: FocusModeInfo?
    
    private var timer: Timer?

    init() {
        
        
        INFocusStatusCenter.default.requestAuthorization { status in
            
            guard status == .authorized else {
                return
            }
            
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(withTimeInterval: 100, repeats: true) { [weak self] _ in
                    self?.checkFocusState()
                }
                
                self.checkFocusState()
            }
        }
    }

    
    private func checkFocusState() {
        
        let isFocused = INFocusStatusCenter.default.focusStatus.isFocused
        
        
        
        let newMode: FocusModeInfo? = (isFocused == true) ? getActiveFocusDetails() : nil
        
        
        if self.currentFocusMode != newMode {
            DispatchQueue.main.async {
                self.currentFocusMode = newMode
                if let mode = newMode {
                } else {
                }
            }
        }
    }
    
    
    
    private func getActiveFocusDetails() -> FocusModeInfo? {
        let dndServiceDefaults = UserDefaults(suiteName: "com.apple.do-not-disturb-service")
        
        guard let preferences = dndServiceDefaults?.persistentDomain(forName: "com.apple.do-not-disturb-service"),
              let assertionDetails = preferences["assertionDetails"] as? [[String: Any]],
              let activeModeDict = assertionDetails.first,
              let name = activeModeDict["name"] as? String,
              let identifier = activeModeDict["identifier"] as? String else {
            
            return FocusModeInfo(name: "Do Not Disturb", identifier: "moon.fill")
        }
        
        return FocusModeInfo(name: name, identifier: identifier)
    }

    deinit {
        timer?.invalidate()
    }
}
