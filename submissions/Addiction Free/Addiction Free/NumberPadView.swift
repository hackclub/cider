//
//  NumberPadView.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 17/08/2024.
//

import SwiftUI
import LocalAuthentication
import CoreHaptics

struct NumberPadView: View {
    @Binding var passcode: String
    @State private var isBiometricAvailable = false
    @State private var biometricType: BiometricType = .none
    let face = FaceIDManager()
    let bio = UserDefaults.standard.string(forKey: "bio")
    @State private var engine: CHHapticEngine?
    private let colums: [GridItem] = [
        .init(),
        .init(),
        .init()
    ]
    var body: some View {
        LazyVGrid(columns: colums){
            ForEach(1...9, id: \.self) {index in
                Button {
                    addValue(index)
                } label: {
                    Text("\(index)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .contentShape(.rect)
                }
            }
            Button {
                removeValue()
            } label: {
                Image(systemName: "delete.backward")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .contentShape(.rect)
            }
            Button {
                addValue(0)
            } label: {
                Text("0")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .contentShape(.rect)
            }
            if isBiometricAvailable {
                if face.isFaceIDEnabled {
                    Button(action: authenticate) {
                        Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .contentShape(.rect)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .onAppear(perform: prepareHaptics)
        
        
    }
    enum BiometricType {
            case none
            case touchID
            case faceID
        }
    private func checkBiometricStatus() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                isBiometricAvailable = true
                if context.biometryType == .faceID {
                    biometricType = .faceID
                    let _: Void = UserDefaults.standard.set("face", forKey: "bio")
                } else if context.biometryType == .touchID {
                    biometricType = .touchID
                    let _: Void = UserDefaults.standard.set("touch", forKey: "bio")
                }
                if face.isFaceIDEnabled {
                    authenticate()
                }
            } else {
                isBiometricAvailable = false
                biometricType = .none
            }
        }
    private func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Authenticate to access the app"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            passcode = KeychainHelper.shared.getPinCode()!
                        }
                    }
                }
            }
    }
    
    private func addValue(_ value: Int) {
        if passcode.count < 6 {
            playHapticA()
            passcode += "\(value)"
        }
    }
    private func removeValue() {
        playHapticR()
        if !passcode.isEmpty {
            passcode.removeLast()
        }
    }
    func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to create or start the haptic engine, error: \(error.localizedDescription)")
        }
        checkBiometricStatus()
    }
    
    func playHapticA() {
        guard let engine = engine else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern (add) , error: \(error.localizedDescription)")
        }
    }
    func playHapticR() {
            guard let engine = engine else { return }
            
            var events = [CHHapticEvent]()
            
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            events.append(event)
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                print("Failed to play remove haptic pattern (remove), error: \(error.localizedDescription)")
            }
        }
}

#Preview {
    NumberPadView(passcode: .constant(""))
}
