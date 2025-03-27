import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "NotebookTask")
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Enable cloud sync
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Task Operations
    func createTask(title: String, 
                    description: String? = nil, 
                    dueDate: Date? = nil, 
                    priority: Int = 0, 
                    status: TaskStatus = .todo, 
                    category: Category? = nil) -> Task {
        let context = persistentContainer.viewContext
        let task = Task(context: context, 
                        title: title, 
                        description: description, 
                        dueDate: dueDate, 
                        priority: priority, 
                        status: status, 
                        category: category)
        saveContext()
        return task
    }
    
    func fetchTasks(predicate: NSPredicate? = nil, 
                    sortDescriptors: [NSSortDescriptor]? = nil) -> [Task] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func updateTask(_ task: Task) {
        saveContext()
    }
    
    func deleteTask(_ task: Task) {
        let context = persistentContainer.viewContext
        context.delete(task)
        saveContext()
    }
    
    // MARK: - Category Operations
    func createCategory(name: String, color: Color? = nil) -> Category {
        let context = persistentContainer.viewContext
        let category = Category(context: context, name: name, color: color)
        saveContext()
        return category
    }
    
    func fetchCategories() -> [Category] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // MARK: - Utility Methods
    func getTodaysTasks() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = NSPredicate(format: "dueDate >= %@ AND dueDate < %@", today as NSDate, tomorrow as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: false)
        
        return fetchTasks(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func getOverdueTasks() -> [Task] {
        let predicate = NSPredicate(format: "dueDate < %@ AND status != %@", 
                                    Date() as NSDate, 
                                    TaskStatus.completed.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        
        return fetchTasks(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
}
