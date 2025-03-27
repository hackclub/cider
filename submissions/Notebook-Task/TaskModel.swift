import SwiftUI
import Combine
import CoreData

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var todayTasks: [Task] = []
    @Published var overdueTasks: [Task] = []
    @Published var categories: [Category] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        setupObservers()
    }
    
    private func setupObservers() {
        // Fetch initial data
        fetchTasks()
        fetchCategories()
        fetchTodayAndOverdueTasks()
    }
    
    // MARK: - Fetch Methods
    func fetchTasks(filterPredicate: NSPredicate? = nil, 
                    sortDescriptors: [NSSortDescriptor]? = nil) {
        tasks = coreDataManager.fetchTasks(predicate: filterPredicate, 
                                           sortDescriptors: sortDescriptors)
    }
    
    func fetchCategories() {
        categories = coreDataManager.fetchCategories()
    }
    
    func fetchTodayAndOverdueTasks() {
        todayTasks = coreDataManager.getTodaysTasks()
        overdueTasks = coreDataManager.getOverdueTasks()
    }
    
    // MARK: - Task Management Methods
    func addTask(title: String, 
                 description: String? = nil, 
                 dueDate: Date? = nil, 
                 priority: Int = 0, 
                 status: TaskStatus = .todo, 
                 category: Category? = nil) {
        let newTask = coreDataManager.createTask(
            title: title, 
            description: description, 
            dueDate: dueDate, 
            priority: priority, 
            status: status, 
            category: category
        )
        
        // Refresh tasks
        fetchTasks()
        fetchTodayAndOverdueTasks()
    }
    
    func updateTask(_ task: Task) {
        coreDataManager.updateTask(task)
        fetchTasks()
        fetchTodayAndOverdueTasks()
    }
    
    func deleteTask(_ task: Task) {
        coreDataManager.deleteTask(task)
        fetchTasks()
        fetchTodayAndOverdueTasks()
    }
    
    // MARK: - Category Management Methods
    func addCategory(name: String, color: Color? = nil) {
        _ = coreDataManager.createCategory(name: name, color: color)
        fetchCategories()
    }
    
    // MARK: - Filter and Search Methods
    func filterTasks(by status: TaskStatus? = nil, 
                     category: Category? = nil, 
                     priority: Int? = nil) -> [Task] {
        var predicates: [NSPredicate] = []
        
        if let status = status {
            predicates.append(NSPredicate(format: "status == %@", status.rawValue))
        }
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if let priority = priority {
            predicates.append(NSPredicate(format: "priority == %d", priority))
        }
        
        let compoundPredicate = predicates.isEmpty ? 
            nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        
        return coreDataManager.fetchTasks(predicate: compoundPredicate, 
                                          sortDescriptors: [sortDescriptor])
    }
    
    // MARK: - Statistics Methods
    func getTaskCompletionRate() -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        
        let completedTasks = tasks.filter { $0.taskStatus == .completed }
        return Double(completedTasks.count) / Double(tasks.count)
    }
    
    func getTaskCountByStatus() -> [TaskStatus: Int] {
        var statusCounts: [TaskStatus: Int] = [:]
        
        for status in TaskStatus.allCases {
            statusCounts[status] = tasks.filter { $0.taskStatus == status }.count
        }
        
        return statusCounts
    }
}

// Add extension to TaskStatus to conform to CaseIterable
extension TaskStatus: CaseIterable {}
