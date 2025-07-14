//
//  DesktopManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import AppKit
import Combine

class DesktopManager: ObservableObject {
    
    @Published private(set) var currentDesktopNumber: Int?

    init() {
        
        self.currentDesktopNumber = CGSHelper.getActiveDesktopNumber()
        
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeSpaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    @objc private func activeSpaceDidChange() {
        DispatchQueue.main.async {
            
            self.currentDesktopNumber = CGSHelper.getActiveDesktopNumber()
        }
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
