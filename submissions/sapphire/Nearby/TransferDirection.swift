//
//  TransferDirection.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-03.
//

import Foundation

public enum TransferDirection {
    case incoming, outgoing
}

public enum TransferState {
    case waiting, inProgress, finished, failed, canceled
}

public struct TransferProgressInfo: Identifiable, Equatable {
    public let id: String
    public var deviceName: String
    public var fileDescription: String
    public var direction: TransferDirection
    public var state: TransferState = .waiting
    public var progress: Double = 0.0
    public var iconName: String = "doc"
}
