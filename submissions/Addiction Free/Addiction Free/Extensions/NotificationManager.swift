import Foundation
import UserNotifications
import SwiftData

class NotificationManager {
    
    private let notificationsEnabledKey = "isNotificationsEnabled"
    
    private var isNotificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey)
        }
    }
    
    private let quotes = [
        "Every step away from addiction is a step closer to freedom.",
        "The power to change lies within you.",
        "Small wins add up to big victories.",
        "You're stronger than you think.",
        "Every day without addiction is a triumph.",
        "Progress is progress, no matter how small.",
        "Focus on the future, not the past.",
        "Your strength today is your success tomorrow.",
        "One day at a time, you're winning.",
        "Believe in the person you're becoming.",
        "Keep pushing forward, you're doing great.",
        "The journey is tough, but so are you.",
        "Recovery is a journey, not a destination.",
        "Today is another chance to get it right.",
        "Your future is worth fighting for.",
        "Stay strong, your progress is showing.",
        "You’re proving your strength every day.",
        "Don't look back, you're not going that way.",
        "Celebrate every small victory.",
        "Log your progress in the app to keep the momentum going."
    ]
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            self?.isNotificationsEnabled = granted
            if granted {
                self?.turnOnNotifications()
            } else {
                self?.turnOffNotifications()
            }
        }
    }
    
    func turnOnNotifications() {
        guard isNotificationsEnabled else { return }
        
        for hour in 10...19 {
            scheduleHourlyQuoteNotification(at: hour)
        }
        
        scheduleDailyCheckInNotification(streak: -1)
        
        isNotificationsEnabled = true
    }
    
    func turnOffNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationsEnabled = false
    }
    
    func areNotificationsTurnedOn() -> Bool {
        return isNotificationsEnabled
    }
    
    private func scheduleHourlyQuoteNotification(at hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Log your progress in the app!"
        content.body = quotes.randomElement() ?? "Keep it up!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "AddictionNotification_\(hour)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleDailyCheckInNotification(streak: Int) {
        let streak = UserDefaults.standard.integer(forKey: "streak")
        let content = UNMutableNotificationContent()
        content.title = "Streak Report"
        
        if streak == -1 {
            content.body = "Start logging your activity to build a streak!"
        } else {
            if streak == 0 {
                content.body = "You have no streak yet. Come back tomorrow, and keep going!"
            } else {
                let streakstr = String(streak)
                content.body = "You haven't failed for \(streakstr) days."
            }
        }
        
        
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyStreakNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
