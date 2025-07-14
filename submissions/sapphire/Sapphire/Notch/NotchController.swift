//
//  NotchController.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import SwiftUI
import Combine
import ScreenCaptureKit


fileprivate class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    var onClose: () -> Void
    init(onClose: @escaping () -> Void) { self.onClose = onClose }
    func windowWillClose(_ notification: Notification) { onClose() }
}

struct NotchController: View {
    let notchWindow: NSWindow?

    enum NotchState {
        case initial, autoExpanded, hoverExpanded, clickExpanded
    }

    
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    @EnvironmentObject var geminiLiveManager: GeminiLiveManager
    @EnvironmentObject var pickerHelper: ContentPickerHelper
    @EnvironmentObject var settings: SettingsModel

    
    @State private var notchState: NotchState = .initial
    @State private var isHovered: Bool = false
    @State private var collapseTimer: Timer?
    @State private var widgetChangeState: Bool = false
    @State private var isPinned = false

    
    @State private var settingsWindow: NSWindow?
    @State private var settingsDelegate: SettingsWindowDelegate?

    
    @State private var isGeminiHovered = false

    
    @State private var animatedWidth: CGFloat = NotchConfiguration.initialSize.width
    @State private var animatedHeight: CGFloat = NotchConfiguration.initialSize.height
    @State private var animatedCornerRadius: CGFloat = NotchConfiguration.initialCornerRadius
    @State private var shadowOpacity: Double = 0
    
    
    @State private var measuredClickContentSize: CGSize = .zero
    @State private var measuredAutoContentSize: CGSize = .zero
    
    
    @State private var widgetMode: NotchWidgetMode = .defaultWidgets
    
    
    @State private var clickContentOpacity: Double = 0
    @State private var autoContentOpacity: Double = 0

    
    private var isLiveActivityActive: Bool { liveActivityManager.currentActivity != .none }
    private var isFullViewActivity: Bool { liveActivityManager.isFullViewActivity }
    
    private var activeScaleFactor: CGFloat {
        guard notchState == .hoverExpanded && !isFullViewActivity else { return 1.0 }
        return NotchConfiguration.scaleFactor
    }
    
    public init(notchWindow: NSWindow?) {
        self.notchWindow = notchWindow
    }

    
    var body: some View {
        ZStack(alignment: .top) {
            CustomNotchShape(cornerRadius: animatedCornerRadius)
                .fill(Color.black)
                .shadow(
                    color: NotchConfiguration.expandedShadowColor.opacity(shadowOpacity),
                    radius: notchState == .clickExpanded ? NotchConfiguration.expandedShadowRadius : 12,
                    y: notchState == .clickExpanded ? NotchConfiguration.expandedShadowOffset.y : 6
                )
                .onTapGesture(perform: handleTap)

            ZStack(alignment: .top) {
                contentView
                if notchState == .clickExpanded {
                    expandedOverlayIcons
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                }
            }
            .mask(CustomNotchShape(cornerRadius: animatedCornerRadius))
        }
        .frame(width: animatedWidth, height: animatedHeight)
        .contentShape(CustomNotchShape(cornerRadius: animatedCornerRadius))
        .onHover(perform: handleHover)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(measurementView.hidden())
        .onAppear(perform: updateMouseEventHandling)
        .onChange(of: liveActivityManager.currentActivity, perform: handleActivityChange)
        .onChange(of: notchState, perform: handleStateChange)
        .onChange(of: isHovered, perform: { _ in updateMouseEventHandling() })
        .onChange(of: widgetMode, perform: handleWidgetModeChange)
        .onChange(of: measuredClickContentSize) { newSize in
            if notchState == .clickExpanded {
                withAnimation(NotchConfiguration.expandAnimation) {
                    animatedWidth = newSize.width
                    animatedHeight = newSize.height
                }
            }
        }
        .onChange(of: measuredAutoContentSize) { newSize in
            let scale = activeScaleFactor
            let targetHeight = newSize.height * scale
            let isShrinking = targetHeight < self.animatedHeight
            let expandAnimation = (notchState == .hoverExpanded) ? NotchConfiguration.expandAnimation : NotchConfiguration.autoExpandAnimation
            let animationToUse = isShrinking ? NotchConfiguration.collapseAnimation : expandAnimation

            if notchState == .autoExpanded || (notchState == .hoverExpanded && isLiveActivityActive) {
                withAnimation(animationToUse) {
                    animatedWidth = newSize.width * scale
                    animatedHeight = targetHeight
                }
            }
        }
        .onReceive(pickerHelper.pickerResultPublisher) { result in
            switch result {
            case .success(let filter):
                geminiLiveManager.startSession(with: filter)
                liveActivityManager.startGeminiLive()
            case .failure(let error):
                if let error = error {
                } else {
                }
            }
        }
    }

    
    
    @ViewBuilder
    private var contentView: some View {
        if notchState == .clickExpanded {
            NotchWidgetView(mode: $widgetMode)
                .padding(.top, NotchConfiguration.contentTopPadding)
                .padding(.bottom, NotchConfiguration.contentBottomPadding)
                .padding(.horizontal, NotchConfiguration.contentHorizontalPadding)
                .opacity(clickContentOpacity)
                .frame(width: animatedWidth, height: animatedHeight)
                .clipped()
                .allowsHitTesting(true)
        } else if isLiveActivityActive && (notchState == .autoExpanded || notchState == .hoverExpanded) {
            Group {
                autoActivityView
            }
            .id(liveActivityManager.contentUpdateID)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                removal: .opacity.combined(with: .scale(scale: 1.02, anchor: .top))
            ))
            .animation(NotchConfiguration.autoExpandAnimation, value: liveActivityManager.contentUpdateID)
            .opacity(autoContentOpacity)
            .scaleEffect(activeScaleFactor)
            .animation(NotchConfiguration.expandAnimation, value: notchState)
            .frame(width: animatedWidth, height: animatedHeight)
            .clipped()
            .allowsHitTesting(isHovered)
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }

    @ViewBuilder
    private var autoActivityView: some View {
        switch liveActivityManager.activityContent {
        case .standard(let view, _):
            view
        case .full(let view, _):
            view
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var measurementView: some View {
        ZStack {
            NotchWidgetView(mode: $widgetMode)
                .padding(.top, NotchConfiguration.contentTopPadding)
                .padding(.bottom, NotchConfiguration.contentBottomPadding)
                .padding(.horizontal, NotchConfiguration.contentHorizontalPadding)
                .fixedSize()
                .background(GeometryReader { geo in Color.clear.onSizeChange(of: geo.size) { measuredClickContentSize = $0 } })
            
            autoActivityView
                .fixedSize()
                .background(GeometryReader { geo in Color.clear.onSizeChange(of: geo.size) { measuredAutoContentSize = $0 } })
        }
    }
    
    @ViewBuilder
    private var expandedOverlayIcons: some View {
        if widgetMode == .defaultWidgets {
            defaultModeIcons
        } else {
            backButton
        }
    }

    @ViewBuilder
    private var defaultModeIcons: some View {
        HStack {
            HStack(spacing: 0) {
                SubtleIconButton(systemName: "gearshape", action: openSettingsWindow)
                if settings.settings.geminiEnabled { geminiButton }
            }
            Spacer()
            HStack(spacing: 0) {
                if settings.settings.dropboxIconEnabled {
                    SubtleIconButton(systemName: "arrow.down.circle", action: { widgetMode = .nearDrop })
                }
                if settings.settings.batteryEstimatorEnabled {
                    SubtleIconButton(systemName: "battery.100", action: { print("Battery tapped") })
                }
                if settings.settings.pinEnabled {
                    SubtleIconButton(systemName: isPinned ? "pin.fill" : "pin", action: { isPinned.toggle(); if isPinned { collapseTimer?.invalidate() } })
                }
            }
        }
        .padding(.horizontal, 40)
        .frame(height: NotchConfiguration.initialSize.height)
        .frame(width: animatedWidth)
        .offset(y: -4)
    }

    @ViewBuilder
    private var backButton: some View {
        HStack {
            Button(action: {
                withAnimation(NotchConfiguration.expandAnimation) {
                    widgetMode = .defaultWidgets
                }
            }) {
                
                ZStack(alignment: .leading) {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 100, height: 60)

                    
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.leading, 40)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .frame(height: NotchConfiguration.initialSize.height)
        .frame(width: animatedWidth)
    }

    @ViewBuilder
    private var geminiButton: some View {
        let baseSize: CGFloat = 25
        let geminiGradient = LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        Button(action: {
            pickerHelper.showPicker()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "sparkle")
                    .font(.system(size: isGeminiHovered ? 12 : 14, weight: .medium))
                    .rotationEffect(.degrees(isGeminiHovered ? 90 : 0))
                    .foregroundStyle(
                        isGeminiHovered ?
                        LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isGeminiHovered)

                if isGeminiHovered {
                    Text("Go live")
                        .font(.system(size: 10, weight: .semibold))
                        .fixedSize()
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .padding(.horizontal, isGeminiHovered ? 10 : 0)
            .frame(width: isGeminiHovered ? nil : baseSize, height: baseSize)
            .background(isGeminiHovered ? geminiGradient : nil)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                isGeminiHovered = hovering
            }
        }
    }
    
    
    
    private func handleTap() {
        collapseTimer?.invalidate()
        if isPinned { return }
        
        if isLiveActivityActive && (notchState == .autoExpanded || notchState == .hoverExpanded) {
            let activityType = liveActivityManager.currentActivity
            if activityType == .music, settings.settings.musicOpenOnClick {
                notchState = .clickExpanded; widgetMode = .musicPlayer; return
            }
            if activityType == .weather, settings.settings.weatherOpenOnClick {
                notchState = .clickExpanded; widgetMode = .weatherPlayer; return
            }
        }
        
        switch notchState {
        case .initial, .hoverExpanded, .autoExpanded: notchState = .clickExpanded
        case .clickExpanded: notchState = isLiveActivityActive ? .autoExpanded : .initial
        }
    }

    private func handleHover(hovering: Bool) {
        isHovered = hovering
        if hovering {
            collapseTimer?.invalidate()
            if notchState == .initial || notchState == .autoExpanded {
                notchState = .hoverExpanded
            }
        } else if !widgetChangeState {
            let delay = (widgetMode == .defaultWidgets) ? 0.0 : NotchConfiguration.collapseDelay
            scheduleCollapse(after: delay)
        }
    }
    
    private func handleActivityChange(_ newActivity: ActivityType) {
        guard notchState != .clickExpanded else { return }
        notchState = newActivity != .none ? .autoExpanded : .initial
    }

    private func handleStateChange(newState: NotchState) {
        updateMouseEventHandling()
        
        switch newState {
        case .initial:
            withAnimation(NotchConfiguration.collapseAnimation) {
                animatedWidth = NotchConfiguration.initialSize.width
                animatedHeight = NotchConfiguration.initialSize.height
                animatedCornerRadius = NotchConfiguration.initialCornerRadius
                widgetMode = .defaultWidgets
                autoContentOpacity = 0
                shadowOpacity = 0
                isPinned = false
            }
            withAnimation(.easeOut(duration: 0.1)) { clickContentOpacity = 0 }

        case .hoverExpanded:
            let scale = activeScaleFactor
            let targetWidth = isLiveActivityActive ? measuredAutoContentSize.width * scale : NotchConfiguration.hoverExpandedSize.width
            let targetHeight = isLiveActivityActive ? measuredAutoContentSize.height * scale : NotchConfiguration.hoverExpandedSize.height
            let targetRadius = (scale > 1.0 && self.isLiveActivityActive) ? NotchConfiguration.autoExpandedCornerRadius : NotchConfiguration.hoverExpandedCornerRadius
                        
            withAnimation(NotchConfiguration.expandAnimation) {
                animatedWidth = targetWidth; animatedHeight = targetHeight; animatedCornerRadius = targetRadius
                widgetMode = .defaultWidgets
                if isLiveActivityActive { autoContentOpacity = 1 }
                shadowOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.1)) { clickContentOpacity = 0 }

        case .clickExpanded:
            withAnimation(NotchConfiguration.expandAnimation) {
                animatedWidth = measuredClickContentSize.width
                animatedHeight = measuredClickContentSize.height
                animatedCornerRadius = NotchConfiguration.clickExpandedCornerRadius
                autoContentOpacity = 0
                shadowOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeIn(duration: 0.6)) { clickContentOpacity = 1 }
            }

        case .autoExpanded:
            let isShrinking = measuredAutoContentSize.height < self.animatedHeight
            let animationToUse = isShrinking ? NotchConfiguration.collapseAnimation : NotchConfiguration.autoExpandAnimation

            
            withAnimation(animationToUse) {
                animatedWidth = measuredAutoContentSize.width
                animatedHeight = measuredAutoContentSize.height
                animatedCornerRadius = NotchConfiguration.autoExpandedCornerRadius
                widgetMode = .defaultWidgets
                shadowOpacity = 0
                autoContentOpacity = 1
            }
        }
    }
    
    private func handleWidgetModeChange(_ newMode: NotchWidgetMode) {
        guard notchState == .clickExpanded else { return }
        widgetChangeState = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            widgetChangeState = false
            if !isHovered { scheduleCollapse() }
        }
    }
    
    private func updateMouseEventHandling() {
        let isInteractive = notchState == .clickExpanded || isHovered
        notchWindow?.ignoresMouseEvents = !isInteractive
    }

    private func scheduleCollapse(after delay: TimeInterval = NotchConfiguration.collapseDelay) {
        collapseTimer?.invalidate()
        guard !isPinned else { return }
        collapseTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in if !self.isHovered { self.notchState = self.isLiveActivityActive ? .autoExpanded : .initial } }
    }

    final class KeyWindow: NSWindow {
        override var canBecomeKey: Bool { true }
        override var canBecomeMain: Bool { true }
    }

    private func openSettingsWindow() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let newWindow = KeyWindow(
            contentRect: NSRect(x: 0, y: 0, width: 950, height: 650),
            styleMask: [.borderless, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.center()
        newWindow.isMovableByWindowBackground = false
        newWindow.backgroundColor = .clear
        newWindow.isOpaque = false
        newWindow.hasShadow = true
        newWindow.isReleasedWhenClosed = false

        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView
            .environmentObject(settings)
            .environment(\.window, newWindow))
        hostingView.autoresizingMask = [.width, .height]
        newWindow.contentView = hostingView

        newWindow.makeKeyAndOrderFront(nil)
        newWindow.makeFirstResponder(hostingView)
        NSApp.activate(ignoringOtherApps: true)

        let delegate = SettingsWindowDelegate {
            self.settingsWindow = nil

        }
        newWindow.delegate = delegate
        self.settingsWindow = newWindow
        self.settingsDelegate = delegate
    }

}

fileprivate struct SubtleIconButton: View {
    let systemName: String
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(isHovering ? 1.0 : 0.7))
                .padding(12)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) { isHovering = hovering }
        }
        .scaleEffect(isHovering ? 1.1 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering)
    }
}


fileprivate extension View {
    func onSizeChange(of size: CGSize, perform action: @escaping (CGSize) -> Void) -> some View {
        self.onAppear { action(size) }
            .onChange(of: size) { newSize in action(newSize) }
    }
}
