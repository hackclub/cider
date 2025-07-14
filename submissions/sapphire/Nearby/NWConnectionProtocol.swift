//
//  NWConnectionProtocol.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-02.
//


import Foundation
import Network // This is the ONLY file that will contain this import.

// Create protocols that mirror the NWConnection and NWListener APIs
// This decouples our code from the Network framework itself.

protocol NWConnectionProtocol {
    init(to: NWEndpoint, using: NWParameters)
    var stateUpdateHandler: ((NWConnection.State) -> Void)? { get set }
    func start(queue: DispatchQueue)
    func send(content: Data?, completion: NWConnection.SendCompletion)
    func receive(minimumIncompleteLength: Int, maximumLength: Int, completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void)
    func cancel()
}

protocol NWListenerProtocol {
    init(using: NWParameters) throws
    var stateUpdateHandler: ((NWListener.State) -> Void)? { get set }
    var newConnectionHandler: ((NWConnection) -> Void)? { get set }
    var port: NWEndpoint.Port? { get }
    func start(queue: DispatchQueue)
    func cancel()
}

// Make the real classes conform to our protocols
extension NWConnection: NWConnectionProtocol {}
extension NWListener: NWListenerProtocol {}

// We will now use `NWConnectionProtocol` and `NWListenerProtocol`
// throughout the NearbyShare code instead of the concrete types.