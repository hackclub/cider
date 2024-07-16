//
//  ImageData.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import Foundation
import SwiftUI

class ImageData: ObservableObject {
    @Published var receipts: [ReceiptItem] = []

    func resetAllData() async {
        receipts.removeAll()
        UserDefaultsHelper.shared.saveReceipts(receipts)
    }
}
