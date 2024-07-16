//
//  ReceiptCardView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct ReceiptCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var receipt: ReceiptItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(receipt.title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                .padding(.bottom, 2)

            Text(receipt.date, style: .date)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .secondary)
                .padding(.bottom, 2)

            Text("\(formattedTotalBill(receipt.totalBill))")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .secondary)
        }
        .padding()
        .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : Color.white)
        .cornerRadius(10)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.3), radius: 5, x: 0, y: 5)
    }

    private func formattedTotalBill(_ totalBill: Double) -> String {
        let formatter = NumberFormatter.currency
        return formatter.string(from: NSNumber(value: totalBill)) ?? ""
    }
}

struct GridView: View {
    @Environment(\.colorScheme) var colorScheme
    var receipts: [ReceiptItem]
    var onReceiptSelected: (ReceiptItem) -> Void

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(receipts) { receipt in
                    ReceiptCardView(receipt: receipt)
                        .onTapGesture {
                            onReceiptSelected(receipt)
                        }
                        .background(colorScheme == .dark ? Color.primaryBackground : Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.3), radius: 5, x: 0, y: 5)
                        .padding([.horizontal, .top])
                }
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color.primaryBackground : Color(UIColor.systemBackground))
        }
    }
}

struct ReceiptCardGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GridView(receipts: [
                ReceiptItem(
                    title: "Grocery Shopping",
                    totalBill: 150.75,
                    date: Date(),
                    splitPercentage: 50,
                    tags: ["Groceries", "Essentials"],
                    description: "Weekly grocery shopping",
                    image: UIImage(systemName: "photo")!
                ),
                ReceiptItem(
                    title: "Dinner",
                    totalBill: 75.20,
                    date: Date().addingTimeInterval(-86400),
                    splitPercentage: 100,
                    tags: ["Food", "Restaurant"],
                    description: "Dinner with friends",
                    image: UIImage(systemName: "photo")!
                )
            ]) { _ in }
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)

            GridView(receipts: [
                ReceiptItem(
                    title: "Grocery Shopping",
                    totalBill: 150.75,
                    date: Date(),
                    splitPercentage: 50,
                    tags: ["Groceries", "Essentials"],
                    description: "Weekly grocery shopping",
                    image: UIImage(systemName: "photo")!
                ),
                ReceiptItem(
                    title: "Dinner",
                    totalBill: 75.20,
                    date: Date().addingTimeInterval(-86400),
                    splitPercentage: 100,
                    tags: ["Food", "Restaurant"],
                    description: "Dinner with friends",
                    image: UIImage(systemName: "photo")!
                )
            ]) { _ in }
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
