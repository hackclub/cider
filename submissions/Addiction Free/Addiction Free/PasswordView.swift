//
//  PasswordView.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 17/08/2024.
//

import SwiftUI
import CoreHaptics

struct PasswordView: View {
    @Binding var isAuthenticated: Bool
    @State private var passcode = ""
    @State var wrong = false
    @State private var engine: CHHapticEngine?
    var body: some View {
        VStack {
            VStack(spacing: 48) {
                Text("Enter PIN")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Please enter your 6-digit pin to securely access the Addiction Free app.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 35)
                if wrong {
                    Text("Passcodes do not match. Please try again.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .padding(.top)
            PasscodeIndicatorView(passcode: $passcode)
            Spacer()
            NumberPadView(passcode: $passcode)
        }
        .onChange(of: passcode, {oldValue, newValue in
            verifyPasscode()})
        .onAppear(perform: prepareHaptics)
    }
    private func verifyPasscode() {
        guard passcode.count == 6 else { return }
        Task {
            try? await Task.sleep(nanoseconds: 125_000_000)
            let pincode = KeychainHelper.shared.getPinCode()
            isAuthenticated = passcode == pincode
            if isAuthenticated == false {
                IncorrectPIN()
                wrong = true
            }
            
            passcode = ""
        }
    }
    func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to create or start the haptic engine, error: \(error.localizedDescription)")
        }
    }
    
    func IncorrectPIN() {
        guard let engine = engine else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
        let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
        
        events.append(contentsOf: [event1, event2, event3])
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern (incorrect PIN), error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PasswordView(isAuthenticated: .constant(false))
}
