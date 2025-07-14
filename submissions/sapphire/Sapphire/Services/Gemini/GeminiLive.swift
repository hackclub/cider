//
//  GeminiLive.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import SwiftUI
import AppKit
import CoreGraphics




struct GeminiActiveActivityViewRight: View {
    let isMuted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                .font(.system(size: 14))
                .foregroundStyle(isMuted ? .white.opacity(0.7) : .red)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white.opacity(0.9))
    }
}

struct GeminiActiveActivityView {
    static func left() -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.purple)
    }

    
    static func right(isMuted: Bool, action: @escaping () -> Void) -> some View {
        GeminiActiveActivityViewRight(isMuted: isMuted, action: action)
    }
}
