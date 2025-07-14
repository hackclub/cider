//
//  CalendarViewModel.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import Foundation
import SwiftUI


class InteractiveCalendarViewModel: ObservableObject {
    @Published var dates: [Date] = []
    @Published var selectedDate: Date = Date()
    let today: Date = Date()
    
    var selectedMonthAbbreviated: String {
        selectedDate.format(as: "MMM")
    }

    init() {
        generateDates()
    }
    
    private func generateDates() {
        let calendar = Calendar.current
        let today = Date()
        let dateRange = -90...90
        
        self.dates = dateRange.compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    func selectDate(_ date: Date) {
        self.selectedDate = date
    }
}
