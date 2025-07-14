//
//  TimerManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-28.
//

import Foundation



class TimerManager: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.1
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }
}
