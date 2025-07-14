//
//  Helpers.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import Foundation
import SwiftUI
import AppKit


public class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue

    public init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    
    public func debounce(action: @escaping (() -> Void)) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    
    public func cancel() {
        workItem?.cancel()
    }
}


struct SizeLoggingViewModifier: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                        }
                        .onChange(of: geometry.size) { newSize in
                        }
                }
            )
    }
}


struct HapticManager {
    static func perform(_ pattern: NSHapticFeedbackManager.FeedbackPattern) {
        NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
    }
}

struct BlurButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .blur(radius: configuration.isPressed ? 4 : 0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct InteractiveProgressBar: View {
    @Binding var value: Double
    var gradient: Gradient
    var onSeek: (Double) -> Void
    @State private var isDragging = false
    @State private var dragValue: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 10)
                Rectangle().fill(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)).frame(width: geometry.size.width * CGFloat(isDragging ? dragValue : value), height: 10)
            }
            .clipShape(Capsule())
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { gestureValue in
                if !isDragging { isDragging = true; dragValue = value }
                let newProgress = min(max(0, gestureValue.location.x / geometry.size.width), 1)
                self.dragValue = newProgress
            }.onEnded { gestureValue in
                let finalProgress = min(max(0, gestureValue.location.x / geometry.size.width), 1)
                onSeek(finalProgress)
                isDragging = false
            })
            .animation(isDragging ? .none : .linear(duration: 0.5), value: value)
        }
    }
}
