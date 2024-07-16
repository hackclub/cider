//
//  SettingsView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

enum ViewStyle: String, CaseIterable, Identifiable {
    case list
    case grid

    var id: String { self.rawValue }
}

struct SettingsView: View {
    @State private var showingAboutView = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsAndConditions = false
    @State private var showResetConfirmation = false
    @AppStorage("viewStyle") private var viewStyle: ViewStyle = .list
    @EnvironmentObject var imageData: ImageData
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("App Information").foregroundColor(colorScheme == .dark ? .secondaryText : .primary)) {
                        Button(action: {
                            showingAboutView.toggle()
                        }) {
                            HStack {
                                Text("About")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                Spacer()
                                Image(systemName: "info.circle")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            }
                        }
                        .sheet(isPresented: $showingAboutView) {
                            AboutView()
                        }

//                        HStack {
//                            Text("Contact")
//                                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
//                            Spacer()
//                            VStack(alignment: .trailing) {
//                                Text("Email: iam.muhammadanas0716@gmail.com")
//                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
//                                Text("X: @MuhammadAnas707")
//                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
//                            }
//                        }
                    }

                    Section(header: Text("Legal").foregroundColor(colorScheme == .dark ? .secondaryText : .primary)) {
                        Button(action: {
                            showingPrivacyPolicy.toggle()
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                Spacer()
                                Image(systemName: "lock.shield")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            }
                        }
                        .sheet(isPresented: $showingPrivacyPolicy) {
                            PrivacyPolicyView()
                        }

                        Button(action: {
                            showingTermsAndConditions.toggle()
                        }) {
                            HStack {
                                Text("Terms and Conditions")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                Spacer()
                                Image(systemName: "doc.text")
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                            }
                        }
                        .sheet(isPresented: $showingTermsAndConditions) {
                            TermsAndConditionsView()
                        }
                    }

                    Section(header: Text("View Style").foregroundColor(colorScheme == .dark ? .secondaryText : .primary)) {
                        Picker("View Style", selection: $viewStyle) {
                            Text("List").tag(ViewStyle.list)
                            Text("Grid").tag(ViewStyle.grid)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section {
                        HStack {
                            Spacer()
                            Text("App Version 1.0.1")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            Spacer()
                        }
                    }
                }
                .navigationBarTitle("Settings", displayMode: .inline)
                .background(colorScheme == .dark ? Color.primaryBackground.edgesIgnoringSafeArea(.all) : Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
            }
        }
    }

    private func resetAllData() {
        Task {
            await imageData.resetAllData()
        }
    }
}

// MARK: - Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ImageData()) // Added for preview purposes
    }
}
