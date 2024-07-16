//
//  NoteDetailViewModel.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

class NoteDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var totalBill: String
    @Published var date: Date
    @Published var splitPercentage: Double
    @Published var description: String?
    @Published var selectedTags: [String]
    @Published var image: UIImage?
    @Published var showImagePicker: Bool = false
    @Published var descriptionEnabled: Bool
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    private var originalReceipt: ReceiptItem?
    @Binding private var receipts: [ReceiptItem]

    let tags = ["Groceries", "Essentials", "Food", "Restaurant", "Travel", "Work", "Personal"]

    var isEditing: Bool {
        originalReceipt != nil
    }

    init(receipt: ReceiptItem? = nil, receipts: Binding<[ReceiptItem]>) {
        _receipts = receipts
        if let receipt = receipt {
            self.title = receipt.title
            self.totalBill = String(format: "%.2f", receipt.totalBill)
            self.date = receipt.date
            self.splitPercentage = Double(receipt.splitPercentage)
            self.description = receipt.description
            self.selectedTags = receipt.tags
            self.image = receipt.image
            self.descriptionEnabled = receipt.description != nil
            self.originalReceipt = receipt
        } else {
            self.title = ""
            self.totalBill = ""
            self.date = Date()
            self.splitPercentage = 0
            self.description = nil
            self.selectedTags = []
            self.image = nil
            self.descriptionEnabled = false
        }
    }

    func save() {
        // Set the title to "Untitled" if it is empty
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = "Untitled"
        }

        let totalBillDouble = Double(totalBill) ?? 0.0
        let newReceipt = ReceiptItem(
            id: originalReceipt?.id ?? UUID(),
            title: title,
            totalBill: totalBillDouble,
            date: date,
            splitPercentage: Int(splitPercentage),
            tags: selectedTags,
            description: description,
            image: image
        )

        if let originalReceipt = originalReceipt, let index = receipts.firstIndex(where: { $0.id == originalReceipt.id }) {
            receipts[index] = newReceipt
        } else {
            receipts.append(newReceipt)
        }

        // Save updated receipts list to UserDefaults
        UserDefaultsHelper.shared.saveReceipts(receipts)
        print("Receipt saved/updated: \(newReceipt)") // Debug print
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        get { self ?? "" }
        set { self = newValue }
    }
}
