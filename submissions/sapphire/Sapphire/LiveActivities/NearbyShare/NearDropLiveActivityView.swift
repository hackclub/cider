//
//  NearDropLiveActivityView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import SwiftUI
import NearbyShare


struct NearDropLiveActivityView: View {
    let payload: NearDropPayload
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    
    
    @State private var isShowing = false

    var body: some View {
        HStack(spacing: 16) {
            
            previewIconView

            
            VStack(alignment: .leading, spacing: 10) {
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("From \(payload.device.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(fileInfoText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                
                actionView
                    .frame(height: 36) 
            }
            
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: payload.state)
        }
        .padding(12)
        .padding(.horizontal)
        .padding(.top, 25)
        
        
        .scaleEffect(isShowing ? 1 : 0.95)
        .opacity(isShowing ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isShowing = true
            }
        }
    }
    
    
    
    @ViewBuilder
    private var previewIconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.accentColor)
            
            Image(systemName: iconName(for: payload.transfer))
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .frame(width: 72, height: 72)
    }
    
    @ViewBuilder
    private var actionView: some View {
        switch payload.state {
        case .waitingForConsent:
            IntegratedActionIconButtonsView(payload: payload)
                .environmentObject(liveActivityManager)
                
                .transition(.opacity)

        case .inProgress:
            ModernLinearProgressView(progress: payload.progress ?? 0)
                .transition(.opacity)

        case .finished:
            StatusTagView(text: "Transfer Complete", color: .green)
                .transition(.opacity)

        case .failed(let reason):
            StatusTagView(text: "Failed: \(reason)", color: .red)
                .transition(.opacity)
        }
    }
    
    
    
    private var fileInfoText: String {
        if let textTitle = payload.transfer.textDescription {
            return textTitle
        }
        if payload.transfer.files.count == 1 { return payload.transfer.files[0].name }
        return String.localizedStringWithFormat(NSLocalizedString("NFiles", comment: ""), payload.transfer.files.count)
    }
    
    private func extractURL(from string: String) -> URL? {
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            if let match = detector.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
                return match.url
            }
        }
        return nil
    }
    
    private func iconName(for transfer: TransferMetadata) -> String {
        if let desc = transfer.textDescription, extractURL(from: desc) != nil { return "link" }
        if transfer.textDescription != nil { return "text.quote" }
        guard let firstFile = transfer.files.first else { return "questionmark" }
        if transfer.files.count > 1 { return "doc.on.doc.fill" }
        let mimeType = firstFile.mimeType.lowercased()
        if mimeType.starts(with: "image/") { return "photo" }
        if mimeType.starts(with: "video/") { return "video.fill" }
        if mimeType.starts(with: "audio/") { return "music.note" }
        if mimeType.contains("pdf") { return "doc.richtext.fill" }
        if mimeType.contains("zip") || mimeType.contains("archive") { return "archivebox.fill" }
        return "doc.fill"
    }
}



private struct IntegratedActionIconButtonsView: View {
    let payload: NearDropPayload
    @EnvironmentObject var liveActivityManager: LiveActivityManager

    private func submitConsent(accept: Bool, action: NearDropUserAction = .save) {
        if accept { liveActivityManager.updateNearDropState(to: .inProgress) }
        NearbyConnectionManager.shared.submitUserConsent(transferID: payload.id, accept: accept, action: action)
    }

    var body: some View {
        HStack(spacing: 10) {
            let declineButton = Button { submitConsent(accept: false) } label: { Image(systemName: "xmark") }
                .buttonStyle(ModernIconActionButtonStyle(type: .destructive))
                .accessibilityLabel("Decline")

            if let textContent = payload.transfer.textDescription {
                if let _ = URL(string: textContent) { 
                    declineButton
                    Button { submitConsent(accept: true, action: .copy) } label: { Image(systemName: "doc.on.doc") }
                        .buttonStyle(ModernIconActionButtonStyle(type: .prominent))
                        .accessibilityLabel("Copy Link")
                    Button { submitConsent(accept: true, action: .open) } label: { Image(systemName: "arrow.up.right.square") }
                        .buttonStyle(ModernIconActionButtonStyle(type: .prominent))
                        .accessibilityLabel("Open Link")
                } else {
                    declineButton
                    Button { submitConsent(accept: true, action: .copy) } label: { Image(systemName: "doc.on.doc") }
                        .buttonStyle(ModernIconActionButtonStyle(type: .prominent))
                        .accessibilityLabel("Copy Text")
                    Button { submitConsent(accept: true, action: .save) } label: { Image(systemName: "square.and.arrow.down") }
                        .buttonStyle(ModernIconActionButtonStyle(type: .prominent))
                        .accessibilityLabel("Save Text")
                }
            } else {
                declineButton
                Button { submitConsent(accept: true, action: .save) } label: { Image(systemName: "checkmark") }
                    .buttonStyle(ModernIconActionButtonStyle(type: .prominent))
                    .accessibilityLabel("Accept")
            }
            Spacer() 
        }
    }
}

private struct ModernLinearProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.1))
                Capsule().fill(Color.accentColor).frame(width: geometry.size.width * progress)
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
            }
        }
        .animation(.easeOut, value: progress)
    }
}

private struct StatusTagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: color == .green ? "checkmark.circle.fill" : "xmark.circle.fill")
            Text(text).lineLimit(1)
        }
        .font(.caption.bold())
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundStyle(color)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}




enum ModernButtonType {
    case prominent, normal, destructive
}

private struct ModernIconActionButtonStyle: ButtonStyle {
    var type: ModernButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(foregroundColor)
            .frame(width: 36, height: 36)
            .background(backgroundColor)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
    
    private var backgroundColor: Color {
        switch type {
        case .prominent:
            return .accentColor
        case .normal:
            return .secondary.opacity(0.2)
        case .destructive:
            return .red
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .prominent, .destructive:
            return .white
        case .normal:
            return .primary
        }
    }
}
