//
//  ReceiptRowView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct ReceiptRowView: View {
    @Environment(\.colorScheme) var colorScheme
    var receipt: ReceiptItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(receipt.title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .secondaryText)

                Text(receipt.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .secondaryText)

                Text("\(formattedTotalBill(receipt.totalBill))")
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(colorScheme == .dark ? .secondaryText : .secondaryText)
        }
        .padding()
        .background(colorScheme == .dark ? Color.primaryBackground : Color.primaryBackground)
        .cornerRadius(8)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func formattedTotalBill(_ totalBill: Double) -> String {
        let formatter = NumberFormatter.currency
        return formatter.string(from: NSNumber(value: totalBill)) ?? ""
    }
}

struct ReceiptRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReceiptRowView(receipt: ReceiptItem(
                title: "Grocery Shopping",
                totalBill: 150.75,
                date: Date(),
                splitPercentage: 50,
                tags: ["Groceries", "Essentials"],
                description: "Weekly grocery shopping", 
                image: UIImage(systemName: "photo")!
            ))
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)

            ReceiptRowView(receipt: ReceiptItem(
                title: "Grocery Shopping",
                totalBill: 150.75,
                date: Date(),
                splitPercentage: 50,
                tags: ["Groceries", "Essentials"],
                description: "Weekly grocery shopping",
                image: UIImage(systemName: "photo")!
            ))
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}
