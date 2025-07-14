//
//  AppModels.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-06.
//

import SwiftUI
import NearbyShare

enum LiveActivityContent: Equatable {
    case none
    case full(view: AnyView, id: AnyHashable)
    case standard(view: AnyView, id: AnyHashable)

    static func == (lhs: LiveActivityContent, rhs: LiveActivityContent) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case let (.full(_, lhsId), .full(_, rhsId)): return lhsId == rhsId
        case let (.standard(_, lhsId), .standard(_, rhsId)): return lhsId == rhsId
        default: return false
        }
    }
}

struct StandardActivityView<LeftContent: View, RightContent: View, BottomContent: View>: View {
    let leftContent: LeftContent?
    let rightContent: RightContent?
    let bottomContent: BottomContent?
    let onBottomContentTapped: (() -> Void)?

    init(
        @ViewBuilder left: () -> LeftContent,
        @ViewBuilder right: () -> RightContent,
        @ViewBuilder bottom: () -> BottomContent,
        onBottomContentTapped: (() -> Void)? = nil
    ) {
        self.leftContent = left()
        self.rightContent = right()
        self.bottomContent = bottom()
        self.onBottomContentTapped = onBottomContentTapped
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: NotchConfiguration.initialSize.width) {
                leftContent.padding(.leading, 10)
                rightContent.padding(.trailing, 10)
            }
            .frame(minHeight: NotchConfiguration.initialSize.height)
            .modifier(SizeLoggingViewModifier(label: "StandardActivityView Internal HStack"))
            
            if !(bottomContent is EmptyView) {
                VStack {
                    Divider().opacity(0.3)
                    bottomContent
                        .padding(.bottom, 10)
                        .contentShape(Rectangle())
                        .onTapGesture { onBottomContentTapped?() }
                }
            }
        }
        .fixedSize()
    }
}

extension StandardActivityView where BottomContent == EmptyView {
    init(
        @ViewBuilder left: () -> LeftContent,
        @ViewBuilder right: () -> RightContent,
        onBottomContentTapped: (() -> Void)? = nil
    ) {
        self.init(left: left, right: right, bottom: { EmptyView() }, onBottomContentTapped: onBottomContentTapped)
    }
}

extension StandardActivityView where RightContent == EmptyView, BottomContent == EmptyView {
    init(
        @ViewBuilder left: () -> LeftContent,
        onBottomContentTapped: (() -> Void)? = nil
    ) {
        self.init(left: left, right: { EmptyView() }, bottom: { EmptyView() }, onBottomContentTapped: onBottomContentTapped)
    }
}



struct NotificationPayload: Identifiable, Equatable {
    let id: String, appIdentifier: String, title: String, body: String
    var hasAudioAttachment: Bool { body.contains("Audio Message") || body.contains("sent an audio message") }
    var hasImageAttachment: Bool { body.contains("sent an image") }
    var appName: String {
        switch appIdentifier {
        case "com.apple.iChat": "Messages"; case "com.apple.facetime": "FaceTime"; case "com.apple.sharingd": "AirDrop"; default: "Notification"
        }
    }
}

enum NearDropTransferState: Equatable, Hashable { case waitingForConsent, inProgress, finished, failed(String) }
struct NearDropPayload: Identifiable, Hashable {
    let id: String, device: RemoteDeviceInfo, transfer: TransferMetadata, destinationURLs: [URL]
    var state: NearDropTransferState = .waitingForConsent; var progress: Double?
    static func == (lhs: NearDropPayload, rhs: NearDropPayload) -> Bool { lhs.id == rhs.id && lhs.state == rhs.state && lhs.progress == rhs.progress }
    func hash(into hasher: inout Hasher) { hasher.combine(id); hasher.combine(state); hasher.combine(progress) }
}

enum GeminiLiveState: Equatable, Hashable { case active }
struct GeminiPayload: Identifiable, Hashable {
    let id = UUID(); var state: GeminiLiveState = .active; var isMicMuted: Bool = true
}

struct LyricLine: Identifiable, Hashable {
    let id = UUID(); let text: String; let timestamp: TimeInterval; var translatedText: String?
}

struct BatteryState: Equatable, Hashable {
    let level: Int, isCharging: Bool, isPluggedIn: Bool
    var isLow: Bool { level <= 20 && !isCharging }
}

struct FocusModeInfo: Equatable, Hashable { let name: String, identifier: String }
