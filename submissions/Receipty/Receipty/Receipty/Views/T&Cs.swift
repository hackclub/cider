//
//  TermsAndConditionsView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 20)
                
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.top)
                    
                    Text("Terms and Conditions")
                        .font(.title)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    By downloading or using the Receipty app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app.
                    """)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)

                    Divider()
                    
                    Group {
                        Text("User Responsibilities")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)

                        Text("1. You are solely responsible for the data you input and manage within the app. Ensure you back up important information.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("2. The app does not store any data on external servers. All data is stored locally on your device.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Data Accuracy and Integrity")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("3. The app is not responsible for any data loss or inaccuracies. It is your responsibility to ensure that the data entered is correct and to maintain backups.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Updates to the Terms")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("4. The developer reserves the right to update the terms and conditions at any time without prior notice. You are advised to review this page periodically for any changes.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("5. Continued use of the app following the posting of changes will mean that you accept and agree to the changes.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Intellectual Property")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("6. The app and all of its content, including but not limited to text, images, and code, are the property of the developer. You may not copy, modify, or distribute any part of the app without prior written permission from the developer.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Termination")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("7. We may terminate or suspend access to our app immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Contact Us")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("""
                        If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us at:

                        Email: iam.muhammadanas0716@gmail.com
                        """)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Text("Last updated: July 14, 2024")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(colorScheme == .dark ? Color.primaryBackground : Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .background(colorScheme == .dark ? Color.primaryBackground.edgesIgnoringSafeArea(.all) : Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
