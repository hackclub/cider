//
//  CalendarHeader.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 22/08/2024.
//

import SwiftUI
import SwiftData

struct CalendarHeader: View {
    @State private var monthDate = Date.now
    @State private var years: [Int] = []
    @State private var selectedMonth = Date.now.monthInt
    @State private var selectedYear = Date.now.yearInt
    @Query private var statuses: [Status]
    @Query(sort: \Activity.name) private var activities: [Activity]
    @State private var selectedActivity: Activity?
    
    let months = Date.fullMonthNames
    var body: some View {
        NavigationStack {
            VStack() {
                HStack() {
                    Picker("", selection: $selectedActivity) {
                        Text("All").tag(nil as Activity?)
                        ForEach(activities) { activity in
                            Text(activity.name).tag(activity as Activity?)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.black)
                }
                .buttonStyle(.bordered)
                CalendarView(date: monthDate, selectedActivity: selectedActivity)
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onChange(of: selectedMonth) {
            updateDate()
        }
    }
    func updateDate() {
        monthDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
    }
}

#Preview {
    CalendarHeader()
        .modelContainer(Activity.preview)
}
