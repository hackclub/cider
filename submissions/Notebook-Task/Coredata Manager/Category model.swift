import Foundation
import CoreData
import SwiftUI

@objc(Category)
public class Category: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var colorHex: String?
    @NSManaged public var tasks: NSSet?
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, 
                     name: String, 
                     color: Color? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.colorHex = color?.toHexString()
    }
    
    // Computed property to get SwiftUI Color
    var color: Color {
        get {
            return colorHex?.toColor() ?? .blue
        }
        set {
            colorHex = newValue.toHexString()
        }
    }
}

// Extension to convert Color to and from Hex String
extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let hexString = String(format: "#%02X%02X%02X", 
                                Int(red * 255), 
                                Int(green * 255), 
                                Int(blue * 255))
        
        return hexString
    }
}

extension String {
    func toColor() -> Color {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
