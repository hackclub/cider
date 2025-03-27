import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var color: String
    
    static let defaultCategories = [
        Category(name: "Personal", color: "blue"),
        Category(name: "Work", color: "red"),
        Category(name: "Shopping", color: "green"),
        Category(name: "Health", color: "purple")
    ]
}
