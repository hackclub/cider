//
//  EmptyStateView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//


import SwiftUI

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    var imageName: String
    var message: String

    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .accentColor)
                .padding(.bottom, 20)

            Text(message)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Click the + button to get started and add your first receipt.")
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color.primaryBackground.edgesIgnoringSafeArea(.all) : Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    EmptyStateView(imageName: "doc.text.fill", message: "No Receipts Found")
}
