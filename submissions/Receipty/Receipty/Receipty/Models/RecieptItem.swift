//
//  RecieptItem.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import Foundation
import UIKit

struct ReceiptItem: Identifiable, Codable {
    var id: UUID
    var title: String
    var totalBill: Double
    var date: Date
    var splitPercentage: Int
    var tags: [String]
    var description: String?
    var imageData: Data?

    var image: UIImage? {
        get {
            guard let imageData = imageData else { return nil }
            return UIImage(data: imageData)
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 1.0)
        }
    }

    init(id: UUID = UUID(), title: String, totalBill: Double, date: Date, splitPercentage: Int, tags: [String], description: String? = nil, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.totalBill = totalBill
        self.date = date
        self.splitPercentage = splitPercentage
        self.tags = tags
        self.description = description
        self.imageData = image?.jpegData(compressionQuality: 1.0)
    }
}

