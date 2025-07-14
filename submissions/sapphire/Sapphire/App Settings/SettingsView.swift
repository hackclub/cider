//
//  SettingsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI


private struct WindowKey: EnvironmentKey {
    static let defaultValue: NSWindow? = nil
}

extension EnvironmentValues {
    var window: NSWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
}


struct SettingsView: View {
    @StateObject private var settings = SettingsModel()
    @State private var selectedSection: SettingsSection? = .widgets

    var body: some View {
        
        ZStack {
            HStack(spacing: 0) {
                SettingsSidebarView(selectedSection: $selectedSection)
                    .frame(width: 190)
                
                SettingsDetailView(selectedSection: selectedSection)
            }
            
            WindowDragHandle()
            
            CustomTrafficLightButtons()
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .zIndex(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(settings)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}


struct WindowDragHandle: View {
    @Environment(\.window) private var window
    
    var body: some View {
        VStack {
            Color.clear
                .frame(height: 50)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let window = window {
                                let startPoint = window.frame.origin
                                let newPoint = NSPoint(
                                    x: startPoint.x + value.translation.width,
                                    y: startPoint.y - value.translation.height
                                )
                                window.setFrameOrigin(newPoint)
                            }
                        }
                )
            Spacer()
        }
        .zIndex(1)
    }
}
