import SwiftUI

@main
struct NotebookTaskApp: App {
    let coreDataManager = CoreDataManager.shared
    @StateObject private var taskViewModel = TaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DashboardView()
                    .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
                    .environmentObject(taskViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
