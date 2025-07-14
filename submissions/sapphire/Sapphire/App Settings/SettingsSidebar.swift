//
//  SettingsSidebar.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI

struct SettingsSidebarView: View {
    @Binding var selectedSection: SettingsSection?
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 35)

            List(selection: $selectedSection) {
                Section {
                    ForEach(SettingsSection.allCases) { section in
                        SidebarRowView(section: section).tag(section)
                    }
                }
            }
            .listStyle(.sidebar).scrollContentBackground(.hidden)
            
            Spacer()

            
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 30, height: 30)
                        .background(Color.red.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    Text("Quit")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 3)
                .padding(.leading, 12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 15)
        }
    }
}

struct CustomTrafficLightButtons: View {
    @Environment(\.window) private var window: NSWindow?
    @State private var isHovering = false
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { window?.close() }) {
                Image(systemName: "xmark").font(.system(size: 7, weight: .bold, design: .rounded))
            }.buttonStyle(TrafficLightButtonStyle(color: .red, isHovering: isHovering))
            Button(action: { window?.miniaturize(nil) }) {
                Image(systemName: "minus").font(.system(size: 7, weight: .bold, design: .rounded))
            }.buttonStyle(TrafficLightButtonStyle(color: .yellow, isHovering: isHovering))
            Button(action: { window?.zoom(nil) }) {
                Image(systemName: "plus").font(.system(size: 7, weight: .bold, design: .rounded))
            }.buttonStyle(TrafficLightButtonStyle(color: .green, isHovering: isHovering))
        }.onHover { hovering in withAnimation(.easeInOut(duration: 0.1)) { isHovering = hovering } }
    }
}

struct TrafficLightButtonStyle: ButtonStyle {
    let color: Color; let isHovering: Bool
    func makeBody(configuration: Configuration) -> some View {
        ZStack { Circle().fill(color); configuration.label.foregroundStyle(.black.opacity(0.6)).opacity(isHovering ? 1 : 0) }.frame(width: 12, height: 12)
    }
}

fileprivate struct SidebarRowView: View {
    let section: SettingsSection
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: section.systemImage).font(.system(size: 11, weight: .bold)).foregroundStyle(.white).frame(width: 22, height: 22).background(section.iconBackgroundColor.opacity(0.8).gradient).clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            Text(section.label).font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
            Spacer()
        }.padding(.vertical, 3)
    }
}
