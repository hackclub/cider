//
//  NearDropProgressView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-05.
//

import SwiftUI
import NearbyShare



struct NearDropProgressView: View {
    @StateObject private var nearbyManager = NearbyConnectionManager.shared
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    
    
    @State private var isShowing = false
    
    private var allDisplayableTransfers: [TransferProgressInfo] {
        let pending = nearbyManager.pendingTransfers.values.sorted { $0.id > $1.id }
        let active = nearbyManager.transfers
        return pending + active
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()

            
            
            Group {
                if allDisplayableTransfers.isEmpty {
                    EmptyStateView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    ScrollView {
                        
                        LazyVStack(spacing: 8) {
                            ForEach(allDisplayableTransfers) { transfer in
                                ModernTransferRowView(transfer: transfer)
                                    .transition(.opacity)
                            }
                        }
                        .padding(8)
                    }
                    .transition(.opacity)
                }
            }
            
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: allDisplayableTransfers.isEmpty)
        }
        .frame(width: 400)
        .frame(maxHeight: 500)
        .fixedSize(horizontal: false, vertical: true)
        
        .background(Color(red: 0.1, green: 0.1, blue: 0.21), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .environmentObject(liveActivityManager)
        
        .scaleEffect(isShowing ? 1 : 0.98)
        .opacity(isShowing ? 1 : 0)
        .padding(.top, 1)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isShowing = true
            }
        }
    }
}




private struct HeaderView: View {
    var body: some View {
        HStack {
            Image(privateName: "shareplay") 
                .font(.system(size: 20, weight: .semibold)) 
                .foregroundColor(.primary)
            
            Text("AirDrops")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(16) 
        .background(.black.opacity(0.3))
        
        
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.secondary)
            Text("No Active Transfers")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150) 
        .padding()
    }
}




private struct ModernTransferRowView: View {
    let transfer: TransferProgressInfo
    @EnvironmentObject var liveActivityManager: LiveActivityManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.15))
                Image(systemName: transfer.iconName).font(.title3).foregroundColor(.accentColor)
            }.frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(transfer.deviceName).font(.callout).fontWeight(.semibold).lineLimit(1)
                Text(transfer.fileDescription).font(.caption).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer(minLength: 8)
            
            
            trailingItem
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: transfer.state)
        }
        .padding(10)
        .background(Color.black.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    private var trailingItem: some View {
        
        switch transfer.state {
        case .waiting:
            IntegratedActionIconButtonsView(transfer: transfer)
                .environmentObject(liveActivityManager)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        case .inProgress:
            CircularProgressIndicator(progress: transfer.progress)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        case .finished:
            Image(systemName: "checkmark.circle.fill").font(.title2).foregroundStyle(.green)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        case .failed:
            Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.red)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        case .canceled:
            Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.secondary)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}



private struct IntegratedActionIconButtonsView: View {
    let transfer: TransferProgressInfo
    @EnvironmentObject var liveActivityManager: LiveActivityManager

    private func submitConsent(accept: Bool, action: NearDropUserAction = .save) {
        liveActivityManager.clearNearDropActivity(id: transfer.id)
        NearbyConnectionManager.shared.submitUserConsent(transferID: transfer.id, accept: accept, action: action)
    }

    var body: some View {
        HStack(spacing: 8) {
            if transfer.iconName == "link" {
                Button { submitConsent(accept: false) } label: { Image(systemName: "xmark") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: false))
                Button { submitConsent(accept: true, action: .copy) } label: { Image(systemName: "doc.on.doc") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: false))
                Button { submitConsent(accept: true, action: .open) } label: { Image(systemName: "arrow.up.right.square") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: true))
            } else if transfer.iconName == "text.quote" {
                Button { submitConsent(accept: false) } label: { Image(systemName: "xmark") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: false))
                Button { submitConsent(accept: true, action: .copy) } label: { Image(systemName: "doc.on.doc") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: false))
                Button { submitConsent(accept: true, action: .save) } label: { Image(systemName: "square.and.arrow.down") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: true))
            } else {
                Button { submitConsent(accept: false) } label: { Image(systemName: "xmark") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: false))
                Button { submitConsent(accept: true, action: .save) } label: { Image(systemName: "checkmark") }
                    .buttonStyle(ModernIconActionButtonStyle(isProminent: true))
            }
        }
    }
}

private struct CircularProgressIndicator: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 4.0).opacity(0.2).foregroundColor(.secondary)
            Circle().trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270.0))
            Text("\(Int(progress * 100))%").font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
        }
        .frame(width: 36, height: 36)
    }
}



private struct ModernIconActionButtonStyle: ButtonStyle {
    var isProminent: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isProminent ? .white : .primary)
            .frame(width: 32, height: 32)
            .background(isProminent ? Color.accentColor : Color.secondary.opacity(0.25))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
