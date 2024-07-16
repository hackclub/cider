//
//  WelcomeView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct WelcomeView: View {
    @State private var username: String = ""
    @State private var isActive = false
    @State private var isLoading = false
    @State private var showContent = [false, false, false, false, false, false]
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    @Binding var hasLaunchedBefore: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .dark {
                    Color.primaryBackground.edgesIgnoringSafeArea(.all)
                } else {
                    Color.white.edgesIgnoringSafeArea(.all)
                }

                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(2)
                            .transition(.opacity)
                    } else {
                        VStack(spacing: 20) {
                            if showContent[0] {
                                Image(systemName: "camera.viewfinder")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                    .matchedGeometryEffect(id: "icon", in: animation)
                                    .transition(.scale.combined(with: .opacity))
                            }

                            if showContent[1] {
                                Text("Welcome to Receipty")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                    .matchedGeometryEffect(id: "headline", in: animation)
                                    .transition(.slide.combined(with: .opacity))
                            }

                            if showContent[2] {
                                Text("Snap all your Receipts all in one place!")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .secondary)
                                    .matchedGeometryEffect(id: "subtitle", in: animation)
                                    .transition(.slide.combined(with: .opacity))
                            }

                            if showContent[3] {
                                VStack(alignment: .leading, spacing: 20) {
                                    FeatureView(icon: "tray.full.fill", title: "Organize", description: "Keep all your receipts organized in one place.")
                                    FeatureView(icon: "tag.fill", title: "Tag", description: "Easily tag and categorize your receipts.")
                                    FeatureView(icon: "magnifyingglass", title: "Search", description: "Quickly find receipts with search.")
                                }
                                .padding(.horizontal)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            }

                            if showContent[4] {
                                TextField("What should we call you?", text: $username)
                                    .padding()
                                    .background(colorScheme == .dark ? Color.secondaryText.opacity(0.2) : Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                                    .matchedGeometryEffect(id: "textfield", in: animation)
                                    .transition(.slide.combined(with: .opacity))
                            }

                            if showContent[5] {
                                Button(action: {
                                    if username.isEmpty {
                                        username = "Receipty Master"
                                    }
                                    UserDefaults.standard.set(username, forKey: "username")
                                    withAnimation {
                                        isLoading = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            isLoading = false
                                            isActive = true
                                            hasLaunchedBefore = true
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Continue")
                                        Image(systemName: "arrow.right")
                                    }
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(colorScheme == .dark ? Color.secondaryText : Color.blue)
                                    .foregroundColor(colorScheme == .dark ? Color.primaryBackground : .white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "continue", in: animation)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .padding()
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: isLoading)
                .onAppear {
                    for index in showContent.indices {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                            withAnimation(.easeInOut) {
                                showContent[index] = true
                            }
                        }
                    }
                }

                NavigationLink("", isActive: $isActive) {
                    EmptyView()
                }
                .navigationDestination(for: String.self) { value in
                    if value == "home" {
                        HomeView()
                            .navigationBarHidden(true)
                    }
                }
            }
        }
    }
}

struct FeatureView: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .secondary)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.primaryBackground.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(10)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(hasLaunchedBefore: .constant(false))
                .preferredColorScheme(.light)
            WelcomeView(hasLaunchedBefore: .constant(false))
                .preferredColorScheme(.dark)
        }
    }
}

