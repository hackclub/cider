//
//  HomeViewModel.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//
//
//  HomeViewModel.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var receipts: [ReceiptItem] = []
    @Published var searchText: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadReceipts()
        setupSearch()
    }

    private func loadReceipts() {
        if let savedReceipts = UserDefaultsHelper.shared.loadReceipts() {
            receipts = savedReceipts
        } else {
            receipts = [] // Initialize with an empty array if no data
        }
    }

    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterReceipts(by: searchText)
            }
            .store(in: &cancellables)
    }

    private func filterReceipts(by searchText: String) {
        if searchText.isEmpty {
            loadReceipts()
        } else {
            receipts = receipts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }

    func deleteReceipt(at offsets: IndexSet) {
        receipts.remove(atOffsets: offsets)
        saveReceipts()
    }
    

    func saveReceipts() {
        UserDefaultsHelper.shared.saveReceipts(receipts)
    }
}
