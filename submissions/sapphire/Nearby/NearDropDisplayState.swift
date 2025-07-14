//
//  NearDropDisplayState.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-02.
//

import Foundation

/// The different states a NearDrop transfer can be in for the UI.
enum NearDropDisplayState: Equatable {
    case waitingForConsent
    case inProgress
    case finished
    case failed(String)
}

/// A clean, decoupled data structure for displaying the NearDrop live activity.
/// It has no dependency on the NearbyShare module.
struct NearDropDisplayPayload: Identifiable, Equatable {
    let id: String // The unique transfer ID
    let deviceName: String
    let fileInfo: String
    let pinCode: String?
    var state: NearDropDisplayState = .waitingForConsent
}
