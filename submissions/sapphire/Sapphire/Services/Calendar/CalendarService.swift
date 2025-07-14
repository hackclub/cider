//
//  CalendarService.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-28.
//

import Foundation
import EventKit

class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var nextEvent: EKEvent?
    
    init() {
        requestAccess()
    }
    
    func requestAccess() {
        eventStore.requestFullAccessToEvents { [weak self] (granted, error) in
            if granted && error == nil {
                DispatchQueue.main.async {
                    self?.fetchNextEvent()
                    
                    Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true) { _ in
                        self?.fetchNextEvent()
                    }
                }
            }
        }
    }
    
    private func fetchNextEvent() {
        let calendars = eventStore.calendars(for: .event)
        let now = Date()
        let oneDayFromNow = Date(timeIntervalSinceNow: 24 * 60 * 60)
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: oneDayFromNow, calendars: calendars)
        
        let events = eventStore.events(matching: predicate).filter { !$0.isAllDay }
        
        DispatchQueue.main.async {
            self.nextEvent = events.first
        }
    }
}
