//
//  Activity.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 21/08/2024.
//

import Foundation
import SwiftData

@Model class Activity {
    var name: String
    @Relationship(deleteRule: .cascade)
    var hexColor: String
    var statuses: [Status] = []
    init(name: String, hexColor: String = "FF0000") {
        self.name = name
        self.hexColor = hexColor
    }
}

extension Activity {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: Activity.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )
        return container
    }
    var daysSinceLastLog: Int? {
        let sortedStatus = statuses.sorted { $0.date > $1.date }
        
        guard let lastLog = sortedStatus.first else {
            return nil
        }
        
        // Calculate the difference in days between the last workout and now
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: lastLog.date, to: Date()).day
        
        return daysSince
    }
}
