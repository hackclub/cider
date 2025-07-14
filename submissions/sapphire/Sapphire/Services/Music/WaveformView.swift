//
//  WaveformView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI
import Combine

struct WaveformView: View {
    @EnvironmentObject var musicWidget: MusicWidget
    @EnvironmentObject var settingsModel: SettingsModel

    @State private var transientIcon: TransientIcon?
    @State private var drawingHeight = false

    enum TransientIcon: Equatable {
        case paused, skippedForward, skippedBackward
        
        var systemName: String {
            switch self {
            case .paused: return "pause.fill"
            case .skippedForward: return "forward.end.fill"
            case .skippedBackward: return "backward.end.fill"
            }
        }
    }

    private let iconDisplayDuration: TimeInterval = 2.5
    private let barCount = 3
    private let minHeight: CGFloat = 3.0
    private let maxHeight: CGFloat = 22.0
    
    private var animation: Animation {
        return .linear(duration: 1.5).repeatForever()
    }

    var body: some View {
        ZStack {
            if let icon = transientIcon {
                iconBody(systemName: icon.systemName)
            } else if musicWidget.isPlaying {
                animatedWaveformBody
            } else {
                staticWaveformBody
            }
        }
        .frame(width: 22, height: 22, alignment: .center)
        .onReceive(musicWidget.playerActionPublisher) { action in
            handle(playerAction: action)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: musicWidget.isPlaying)
    }
    
    private func handle(playerAction: PlayerAction) {
        var iconToShow: TransientIcon?
        switch playerAction {
        case .paused: iconToShow = .paused
        case .skippedForward: iconToShow = .skippedForward
        case .skippedBackward: iconToShow = .skippedBackward
        case .played, .trackChanged:
            transientIcon = nil
            return
        }
        if let icon = iconToShow {
            showTransientIcon(icon)
        }
    }
    
    private func showTransientIcon(_ icon: TransientIcon) {
        self.transientIcon = icon
        Task {
            setTransientState(true)
            try? await Task.sleep(for: .seconds(iconDisplayDuration))
            if self.transientIcon == icon {
                self.transientIcon = nil
            }
            setTransientState(false)
        }
    }
    
    private func setTransientState(_ isDisplaying: Bool) {
        if musicWidget.isDisplayingTransientIcon != isDisplaying {
            DispatchQueue.main.async {
                musicWidget.isDisplayingTransientIcon = isDisplaying
            }
        }
    }

    private var animatedWaveformBody: some View {
        HStack(spacing: 3) {
            // First bar (smaller)
            let scale = settingsModel.settings.musicWaveformIsVolumeSensitive ? musicWidget.systemVolume : 0.7
            bar(low: 0.2, high: 0.5 * CGFloat(scale))
                .animation(animation.speed(1.8), value: drawingHeight)
            
            // Center bar (tallest)
            bar(low: 0.3, high: 0.8 * CGFloat(scale))
                .animation(animation.speed(1.2), value: drawingHeight)
            
            // Last bar (smaller)
            bar(low: 0.1, high: 0.65 * CGFloat(scale))
                .animation(animation.speed(1.4), value: drawingHeight)
        }
        .frame(width: 18, height: 22)
        .onAppear {
            drawingHeight.toggle()
        }
        .transition(.opacity)
    }
    
    private func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        let lowHeight = minHeight + (maxHeight - minHeight) * low
        let highHeight = minHeight + (maxHeight - minHeight) * high

        return Capsule()
            .fill(musicWidget.accentColor)
            .shadow(color: musicWidget.accentColor.opacity(0.6), radius: 4, y: 2)
            .frame(height: drawingHeight ? highHeight : lowHeight)
            // Align to center for symmetrical expansion
            .frame(height: maxHeight, alignment: .center)
    }
    
    private var staticWaveformBody: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { _ in
                Capsule().fill(musicWidget.accentColor).frame(width: 3, height: minHeight)
            }
        }
        .frame(width: 18, height: 22)
        .transition(.opacity)
    }

    private func iconBody(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(musicWidget.accentColor)
            .transition(.opacity.animation(.easeOut(duration: 0.2)))
    }
}
