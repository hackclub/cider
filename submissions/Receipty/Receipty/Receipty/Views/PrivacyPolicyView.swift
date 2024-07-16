//
//  PrivacyPolicyView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import Foundation
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 20)
                
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.top)
                    
                    Text("Privacy Policy")
                        .font(.title)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity) // Center the content

                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    Receipty respects your privacy. This privacy policy explains how we handle your personal information.
                    """)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)

                    Divider()
                    
                    Group {
                        Text("Data Collection and Storage")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)

                        Text("""
                        We do not collect any personal data from you. All information, including your receipts and any related data, is stored locally on your iPhone within the Receipty app. This data is not transmitted to our servers or any third parties.
                        """)
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Data Security")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("""
                        Your data security is important to us. Since all data is stored locally on your device, we recommend that you use the security features provided by your iPhone, such as passcodes, Touch ID, or Face ID, to protect your information.
                        """)
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Changes to This Privacy Policy")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("""
                        We may update our Privacy Policy from time to time. Any changes will be posted on this page. You are advised to review this Privacy Policy periodically for any changes.
                        """)
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                    }

                    Divider()
                    
                    Group {
                        Text("Contact Us")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                        
                        Text("""
                        If you have any questions about this Privacy Policy, please contact us at:

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

// MARK: - Previews
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
