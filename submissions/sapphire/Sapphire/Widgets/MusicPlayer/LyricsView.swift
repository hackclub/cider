//
//  LyricsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import SwiftUI


struct LyricLineView: View {
    let lyric: LyricLine
    let isCurrent: Bool
    let accentColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(lyric.text)
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(isCurrent ? accentColor : .primary)
                .shadow(radius: 5)
            
            if let translated = lyric.translatedText, !translated.isEmpty {
                Text(translated)
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isCurrent ? accentColor : .secondary)
                    .opacity(isCurrent ? 0.8 : 0.6)
            }
        }
        .scaleEffect(isCurrent ? 1.0 : 0.90)
        .opacity(isCurrent ? 1.0 : 0.5)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isCurrent)
    }
}


struct LyricsView: View {
    
    var lyrics: [LyricLine]
    var currentLyricID: UUID?
    var accentColor: Color
    var onDismiss: () -> Void
    
    
    private let lineSpacing: CGFloat = 70.0

    
    var body: some View {
        GeometryReader { geometry in
            let computedOffset = calculateScrollOffset(fullViewHeight: geometry.size.height)
            
            ZStack(alignment: .top) {
                if lyrics.isEmpty {
                    emptyLyricsView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        ForEach(lyrics) { lyric in
                            LyricLineView(
                                lyric: lyric,
                                isCurrent: lyric.id == currentLyricID,
                                accentColor: accentColor
                            )
                            .frame(height: lineSpacing)
                        }
                    }
                    .frame(width: geometry.size.width)
                    .offset(y: computedOffset)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: computedOffset)
                }
            }
            .mask {

                let viewHeight = geometry.size.height
                
                if viewHeight > 0 {
                    let fadeLength: CGFloat = 5
                    let fadePercentage = fadeLength / viewHeight
                    
                    let solidStartLocation = min(fadePercentage, 0.5)
                    let solidEndLocation = max(1.0 - fadePercentage, 0.5)

                    LinearGradient(
                        gradient: Gradient(stops: [
                            
                            .init(color: .clear, location: 0.0),
                            
                            .init(color: .black, location: solidStartLocation),
                            
                            .init(color: .black, location: solidEndLocation),
                            
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    Color.black
                }
            }
        }
        .frame(width: 400)
        .onTapGesture(perform: onDismiss)
    }
    
    
    
    private func calculateScrollOffset(fullViewHeight: CGFloat) -> CGFloat {
        guard let currentIndex = lyrics.firstIndex(where: { $0.id == currentLyricID }) else {
            let totalContentHeight = CGFloat(lyrics.count) * lineSpacing
            return (fullViewHeight - totalContentHeight) / 2
        }
        
        let targetOffset = (fullViewHeight / 2) - (lineSpacing / 2) - (CGFloat(currentIndex) * lineSpacing)
        return targetOffset
    }
    
    
    private var emptyLyricsView: some View {
        Text("No lyrics available.")
            .font(.headline)
            .foregroundColor(.secondary)
    }
}
