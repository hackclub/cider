//
//  UserDefaultsHelper.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import UIKit

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    private let receiptsKey = "receiptsKey"
    private let hasLaunchedBeforeKey = "hasLaunchedBeforeKey"

    private init() {}

    func saveReceipts(_ receipts: [ReceiptItem]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(receipts) {
            UserDefaults.standard.set(encoded, forKey: receiptsKey)
            print("Receipts saved successfully.") // Debug print
        } else {
            print("Failed to encode receipts.") // Debug print
        }
    }

    func loadReceipts() -> [ReceiptItem]? {
        if let savedData = UserDefaults.standard.data(forKey: receiptsKey) {
            let decoder = JSONDecoder()
            if let loadedReceipts = try? decoder.decode([ReceiptItem].self, from: savedData) {
                print("Receipts loaded successfully.") // Debug print
                return loadedReceipts
            } else {
                print("Failed to decode receipts.") // Debug print
            }
        } else {
            print("No saved receipts found.") // Debug print
        }
        return nil
    }

    func hasLaunchedBefore() -> Bool {
        return UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
    }

    func setHasLaunchedBefore(_ hasLaunched: Bool) {
        UserDefaults.standard.set(hasLaunched, forKey: hasLaunchedBeforeKey)
    }

    func initializeDefaultReceipts() {
        if !hasLaunchedBefore() {
            let dinnerImage = UIImage(named: "Dinner") // replace with your actual image name
            let groceriesImage = UIImage(named: "Groceries") // replace with your actual image name

            let defaultReceipts = [
                ReceiptItem(id: UUID(), title: "Dinner", totalBill: 45.00, date: Date(), splitPercentage: 100, tags: ["Food", "Restaurant"], description: "Dinner at a nice restaurant", image: dinnerImage),
                ReceiptItem(id: UUID(), title: "Groceries", totalBill: 150.00, date: Date(), splitPercentage: 100, tags: ["Groceries", "Essentials"], description: "Weekly groceries", image: groceriesImage)
            ]

            saveReceipts(defaultReceipts)
            setHasLaunchedBefore(true)
        }
    }
}
