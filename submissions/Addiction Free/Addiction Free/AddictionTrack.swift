//
//  AddictionTrack.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 21/08/2024.
//

import SwiftUI
import SwiftData
import CoreHaptics

struct AddictionTrack: View {
    @Environment(\.modelContext) private var modelContext
    @State private var engine: CHHapticEngine?
    @Binding var count: Int
    var body: some View {
        VStack{
            HStack{
                Button() {
                    playHapticFeedback(for: .success)
                } label: {
                    Text("I'm still okay")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                }
                .background(Color.green.opacity(0.8))
                .cornerRadius(12)
                .shadow(color: Color.primary.opacity(0.3), radius: 5, x: 0, y: 5)
                .padding([.top, .leading, .bottom])
                Button() {
                    playHapticFeedback(for: .failure)
                    addSmokeWorkout()
                } label: {
                    Text("I failed")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                }
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
                .shadow(color: Color.primary.opacity(0.3), radius: 5, x: 0, y: 5)
                .padding([.top, .bottom, .trailing])
            }
        }
        .onAppear {
            prepareHaptics()
        }
    }

    func addSmokeWorkout() {
        let fetchDescriptor = FetchDescriptor<Activity>()
        
        let activities = try? modelContext.fetch(fetchDescriptor)
        let smokeActivity: Activity

        if let activity = activities?.first {
            smokeActivity = activity
        } else {
            smokeActivity = Activity(name: "🚬 Smoke", hexColor: "000000")
            modelContext.insert(smokeActivity)
        }

        let newStatus = Status(date: Date())
        smokeActivity.statuses.append(newStatus)

        try? modelContext.save()
        count += 1
    }
    func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to create or start the haptic engine, error: \(error.localizedDescription)")
        }
    }
        func playHapticFeedback(for type: FeedbackType) {
            guard let engine = engine else { return }
            
            var events = [CHHapticEvent]()
            
            switch type {
            case .success:
                let successIntensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                let successSharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                let successEvent1 = CHHapticEvent(eventType: .hapticTransient, parameters: [successIntensity1, successSharpness1], relativeTime: 0)
                
                let successIntensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                let successSharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                let successEvent2 = CHHapticEvent(eventType: .hapticTransient, parameters: [successIntensity2, successSharpness2], relativeTime: 0.1)
                
                events.append(contentsOf: [successEvent1, successEvent2])
                
            case .failure:
                let failureIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                let failureSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                
                let failureEvent1 = CHHapticEvent(eventType: .hapticTransient, parameters: [failureIntensity, failureSharpness], relativeTime: 0)
                let failureEvent2 = CHHapticEvent(eventType: .hapticTransient, parameters: [failureIntensity, failureSharpness], relativeTime: 0.1)
                let failureEvent3 = CHHapticEvent(eventType: .hapticTransient, parameters: [failureIntensity, failureSharpness], relativeTime: 0.2)
                
                events.append(contentsOf: [failureEvent1, failureEvent2, failureEvent3])
            }
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                print("Failed to play haptic pattern: \(error.localizedDescription)")
            }
        }
    enum FeedbackType {
        case success
        case failure
    }
}


#Preview {
    AddictionTrack(count: .constant(0))
}
