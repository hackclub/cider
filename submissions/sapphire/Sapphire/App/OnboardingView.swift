//
//  OnboardingView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-09.
//

import SwiftUI

struct OnboardingView: View {
    enum OnboardingStep {
        case welcome, permissions
    }

    @State private var currentStep: OnboardingStep = .welcome
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.3), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            CustomWindowControls()
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .zIndex(2)

            switch currentStep {
            case .welcome:
                WelcomeStepView(onGetStarted: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = .permissions
                    }
                })
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading).combined(with: .opacity)))
            case .permissions:
                PermissionsStepView(onComplete: onComplete)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing).combined(with: .opacity)))
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}



private struct WelcomeStepView: View {
    var onGetStarted: () -> Void
    
    @State private var isHoveringGetStarted = false

    private var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 249/255, green: 165/255, blue: 154/255),
                Color(red: 255/255, green: 197/255, blue: 158/255),
                Color(red: 255/255, green: 247/255, blue: 174/255)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Text("Welcome to Sapphire")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("A new way to experience your Mac's notch.\nLet's get started by setting up a few permissions.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Spacer()
            
            Button(action: onGetStarted) {
                HStack {
                    Text("Get Started")
                    if isHoveringGetStarted {
                        Image(systemName: "arrow.right")
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    }
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(buttonGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            .padding(.bottom, 50)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHoveringGetStarted = hovering
                }
            }
        }
    }
}



private struct PermissionsStepView: View {
    @StateObject private var permissionsManager = PermissionsManager()
    var onComplete: () -> Void
    
    
    private var doneButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 154/255, green: 249/255, blue: 165/255),
                Color(red: 174/255, green: 255/255, blue: 247/255)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Required Permissions")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 40).padding(.bottom, 10)
            
            Text("Sapphire needs a few permissions to provide live information and control your system. Your data is never collected or sent anywhere.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
                .padding(.horizontal, 50).padding(.bottom, 30)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(permissionsManager.allPermissions) { permission in
                        PermissionRowView(permission: permission, manager: permissionsManager)
                    }
                }.padding(.horizontal, 50)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Done")
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 60).padding(.vertical, 12)
                    .background(doneButtonGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!permissionsManager.areAllPermissionsGranted)
            .padding(.bottom, 50)
            .animation(.easeInOut, value: permissionsManager.areAllPermissionsGranted)
        }
        .onAppear {
            permissionsManager.checkAllPermissions()
        }
    }
}



private struct PermissionRowView: View {
    let permission: PermissionItem
    @ObservedObject var manager: PermissionsManager

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: permission.iconName).font(.title2).frame(width: 40, height: 40)
                .background(permission.iconColor.opacity(0.2)).clipShape(Circle()).foregroundColor(permission.iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(permission.title).font(.headline)
                Text(permission.description).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            let status = manager.status(for: permission.type)
            switch status {
            case .granted: Image(systemName: "checkmark.circle.fill").font(.title2).foregroundColor(.green)
            case .denied: Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.red)
            case .notRequested: Button("Request") { manager.requestPermission(permission.type) }.buttonStyle(.bordered).tint(.accentColor)
            }
        }
        .padding().background(.black.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}



private struct CustomWindowControls: View {
    @Environment(\.window) private var window: NSWindow?
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: { window?.close() }) {
                Image(systemName: "xmark").font(.system(size: 9, weight: .bold, design: .rounded))
            }
            .buttonStyle(TrafficLightButtonStyle(color: .red, isHovering: isHovering))

            Button(action: { window?.miniaturize(nil) }) {
                Image(systemName: "minus").font(.system(size: 9, weight: .bold, design: .rounded))
            }
            .buttonStyle(TrafficLightButtonStyle(color: .yellow, isHovering: isHovering))

            Button(action: { window?.zoom(nil) }) {
                Image(systemName: "plus").font(.system(size: 9, weight: .bold, design: .rounded))
            }
            .buttonStyle(TrafficLightButtonStyle(color: .green, isHovering: isHovering))
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }
}
