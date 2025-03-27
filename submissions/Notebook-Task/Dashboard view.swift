import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var selectedFilter: TaskStatus? = nil
    @State private var isAddTaskPresented = false
    
    var body: some View {
        VStack {
            // Header with Statistics
            DashboardHeaderView()
            
            // Task Filters
            TaskFilterScrollView(selectedFilter: $selectedFilter)
            
            // Task List
            TaskListView(tasks: filteredTasks)
            
            // Add Task Button
            AddTaskButton()
        }
        .navigationTitle("Notebook Task")
        .sheet(isPresented: $isAddTaskPresented) {
            AddTaskView()
        }
    }
    
    // Computed property for filtered tasks
    private var filteredTasks: [Task] {
        taskViewModel.filterTasks(by: selectedFilter)
    }
}

// Dashboard Header with Task Statistics
struct DashboardHeaderView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        HStack {
            // Total Tasks Card
            StatisticCardView(
                title: "Total Tasks",
                value: "\(taskViewModel.tasks.count)",
                color: .blue
            )
            
            // Completed Tasks Card
            StatisticCardView(
                title: "Completed",
                value: "\(taskViewModel.getTaskCountByStatus()[.completed] ?? 0)",
                color: .green
            )
            
            // Overdue Tasks Card
            StatisticCardView(
                title: "Overdue",
                value: "\(taskViewModel.overdueTasks.count)",
                color: .red
            )
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

// Statistic Card View
struct StatisticCardView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Task Filter Scroll View
struct TaskFilterScrollView: View {
    @Binding var selectedFilter: TaskStatus?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                // All Tasks Filter
                FilterChipView(
                    title: "All Tasks", 
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }
                
                // Status Filters
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    FilterChipView(
                        title: status.rawValue.capitalized, 
                        isSelected: selectedFilter == status
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// Filter Chip View
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// Add Task Button
struct AddTaskButton: View {
    @State private var isAddTaskPresented = false
    
    var body: some View {
        Button(action: { isAddTaskPresented = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add New Task")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
        }
        .sheet(isPresented: $isAddTaskPresented) {
            AddTaskView()
        }
    }
}
