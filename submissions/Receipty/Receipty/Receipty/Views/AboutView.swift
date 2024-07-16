//
//  AboutView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 20)
                
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.top)
                    
                    Text("""
                        Hey, it's Muhammad Anas here, the developer of the app Receipty. This simple yet useful application helps you note down your receipts and keep track of your expenses.
                        
                        My dad once told me to make a folder on his phone so he can save his receipts and warranties. Then, voila, I got the idea. I knew exactly what I needed to build, and I guess I made something. A super simple application, but I found my dad using it often, so it's totally worth it!
                        """)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contact")
                            .font(.title2)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            Text("Bay Tower, Al Reem Island, Abu Dhabi")
                                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            VStack(alignment: .leading) {
                                Text("Email:")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                Text("iam.muhammadanas0716@gmail.com")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = "iam.muhammadanas0716@gmail.com"
                                        }) {
                                            Label("Copy Email", systemImage: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "link")
                                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            Link("Follow me on Twitter", destination: URL(string: "https://x.com/muhammadanas707")!)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("App Version: 1.0.1")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .padding(.bottom, 20)
                }
                .padding()
                .background(colorScheme == .dark ? Color.primaryBackground : Color.white)
                .cornerRadius(20)
                .padding()
            }
        }
        .background(colorScheme == .dark ? Color.primaryBackground.edgesIgnoringSafeArea(.all) : Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
