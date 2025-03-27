import Foundation
import CoreData

enum TaskStatus: String, Codable {
    case todo
    case inProgress
    case completed
    case onHold
}

@objc(Task)
public class Task: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var dueDate: Date?
    @NSManaged public var status: String
    @NSManaged public var priority: Int16
    @NSManaged public var category: Category?
    @NSManaged public var subtasks: NSSet?
    
    // Computed property to convert status string to enum
    var taskStatus: TaskStatus {
        get {
            return TaskStatus(rawValue: status) ?? .todo
        }
        set {
            status = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, 
                     title: String, 
                     description: String? = nil, 
                     dueDate: Date? = nil, 
                     priority: Int = 0, 
                     status: TaskStatus = .todo, 
                     category: Category? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.createdAt = Date()
        self.dueDate = dueDate
        self.taskStatus = status
        self.priority = Int16(priority)
        self.category = category
    }
}

extension Task {
    // Helper method to check if task is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && taskStatus != .completed
    }
    
    // Helper method to get priority description
    var priorityDescription: String {
        switch priority {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        case 3: return "Urgent"
        default: return "Unknown"
        }
    }
}
