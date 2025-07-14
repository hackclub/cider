//
//  NearDropCompactActivityView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-03.
//

import SwiftUI
import NearbyShare


struct NearDropCompactActivityView {

    
    static func left() -> some View {
        ZStack {
            Image(privateName: "shareplay")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 20, height: 20)
    }

    
    static func right(payload: NearDropPayload) -> some View {
        ZStack {
            switch payload.state {
            case .inProgress:
                
                CustomCircularProgressView(progress: payload.progress ?? 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))

            case .finished:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            
            case .failed:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            
            case .waitingForConsent:
                Image(systemName: "hourglass")
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .frame(width: 15, height: 15)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: payload.state)
    }
}





private struct CustomCircularProgressView: View {
    let progress: Double
    private let lineWidth: CGFloat = 3.0

    var body: some View {
        ZStack {
            
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(.accentColor)
                .opacity(0.3)

            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270.0)) 
        }
        
        
        .animation(.linear(duration: 0.2), value: progress)
    }
}
