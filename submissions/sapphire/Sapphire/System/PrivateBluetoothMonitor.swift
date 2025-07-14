//
//  PrivateBluetoothMonitor.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-07.
//

import Foundation
import Combine

class PrivateBluetoothMonitor {
    private var diagnosticObserver: NSObjectProtocol?

    init() {
        
        let dnc = DistributedNotificationCenter.default()
        
        
        diagnosticObserver = dnc.addObserver(
            forName: nil, 
            object: nil,
            queue: nil
        ) { notification in
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            if let observer = self?.diagnosticObserver {
                DistributedNotificationCenter.default().removeObserver(observer)
            }
        }
    }

    deinit {
        if let observer = diagnosticObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
        }
    }
    
    
    let eventPublisher = PassthroughSubject<PrivateBluetoothEvent, Never>()
}


struct PrivateBluetoothEvent {
    enum EventType {
        case connected, disconnected
    }
    let address: String
    let type: EventType
}
