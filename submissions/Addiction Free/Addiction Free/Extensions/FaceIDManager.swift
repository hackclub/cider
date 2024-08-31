//
//  FaceIDManager.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 31/08/2024.
//

import Foundation

class FaceIDManager {
    
    private let faceIDEnabledKey = "faceid"
    
    var isFaceIDEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: faceIDEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: faceIDEnabledKey)
        }
    }
    
    init() {
    }
    
    func enableFaceID() {
        isFaceIDEnabled = true
    }
    
    func disableFaceID() {
        isFaceIDEnabled = false
    }
    
    func isFaceIDTurnedOn() -> Bool {
        return isFaceIDEnabled
    }
}
