import SwiftUI

struct TaskListView: View {
    let tasks: [Task]
    @State private var selectedTask: Task?
    
    var body: some View {
        List {
            if tasks.isEmpty {
                // Empty state view
                VStack(alignment: .center) {
                    Image(systemName: "list.bullet.clipboard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.secondary)
                    
                    Text("No tasks found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add a new task to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            } else {
                // Task list
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
                .onDelete(perform: deleteTask)
            }
        }
        .listStyle(PlainListStyle())
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        // This would typically call the view model's delete method
        // For this example, we'll leave it as a placeholder
        // In a real app, you'd implement task deletion through the view model
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            // Status Indicator
            StatusIndicatorView(status: task.taskStatus)
            
            VStack(alignment: .leading) {
                // Task Title
                Text(task.title)
                    .font(.headline)
                    .lineLimit(1)
                
                // Additional Task Details
                HStack {
                    // Due Date
                    if let dueDate = task.dueDate {
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Category
                    if let category = task.category {
                        CategoryBadgeView(category: category)
                    }
                }
            }
            
            Spacer()
            
            // Priority Indicator
            PriorityIndicatorView(priority: Int(task.priority))
        }
        .padding(.vertical, 8)
    }
}

struct StatusIndicatorView: View {
    let status: TaskStatus
    
    var body: some View {
        Image(systemName: statusIcon)
            .foregroundColor(statusColor)
    }
    
    private var statusIcon: String {
        switch status {
        case .todo: return "circle"
        case .inProgress: return "arrow.right.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .onHold: return "pause.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .todo: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .onHold: return .orange
        }
    }
}

struct PriorityIndicatorView: View {
    let priority: Int
    
    var body: some View {
        Image(systemName: "flag.fill")
            .foregroundColor(priorityColor)
    }
    
    private var priorityColor: Color {
        switch priority {
        case 0: return .gray
        case 1: return .blue
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
}

struct CategoryBadgeView: View {
    let category: Category
    
    var body: some View {
        Text(category.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(category.color.opacity(0.2))
            .foregroundColor(category.color)
            .cornerRadius(10)
    }
}
