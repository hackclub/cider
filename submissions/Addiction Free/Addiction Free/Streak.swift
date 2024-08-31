//
//  Streak.swift
//  Addiction Free
//
//  Created by ScriptKid on 26/08/2024.
//

import SwiftUI
import SwiftData

struct Streak: View {
    @Environment(\.modelContext) private var modelContext
    @State private var activity: Activity?
    let streak = UserDefaults.standard.integer(forKey: "streak")
    let screenSize = UIScreen.main.bounds.width
    var body: some View {
        VStack {
            if let daysSinceLastLog = activity?.daysSinceLastLog {
                if daysSinceLastLog == 0 {
                    Text("You have no streak yet.")
                        .padding(.all)
                        .frame(minWidth: screenSize * 0.93)
                        .font(.headline)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 2))
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 5)
                } else {
                    Text("You haven't failed for \(daysSinceLastLog) days.")
                        .padding(.all)
                        .frame(minWidth: screenSize * 0.93)
                        .font(.headline)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 2))
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 5)
                }
            } else {
                Text("No addictions/logs recorded yet.")
                    .font(.headline)
            }
        }
        .onAppear {
            let fetchDescriptor = FetchDescriptor<Activity>()
            if let activities = try? modelContext.fetch(fetchDescriptor) {
                self.activity = activities.first
            }
            if let daysSinceLastLog = activity?.daysSinceLastLog {
                if daysSinceLastLog == 0 {
                    let _: Void = UserDefaults.standard.set(0, forKey: "streak")
                } else {
                    let _: Void = UserDefaults.standard.set(daysSinceLastLog, forKey: "streak")
                }
            } else {
                let _: Void = UserDefaults.standard.set(-1, forKey: "streak")
            }
        }
        .padding()
    }
}

#Preview {
    Streak()
}
