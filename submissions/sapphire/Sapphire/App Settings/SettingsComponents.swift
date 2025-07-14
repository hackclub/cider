//
//  SettingsComponents.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI



struct InfoContainer: View {
    let text: String
    let iconName: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(color)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

struct GeneralSettingToggleRowView: View {
    let setting: GeneralSettingType
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: setting.systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(setting.iconColor)
                .frame(width: 36, height: 36)
                .background(setting.iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(setting.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

struct WidgetRowView: View {
    let widgetType: WidgetType
    @EnvironmentObject var settings: SettingsModel

    private var isEnabledBinding: Binding<Bool> {
        switch widgetType {
        case .weather: return $settings.settings.weatherWidgetEnabled
        case .calendar: return $settings.settings.calendarWidgetEnabled
        case .shortcuts: return $settings.settings.shortcutsWidgetEnabled
        case .music: return $settings.settings.musicWidgetEnabled
        }
    }

    var body: some View {
        HStack {
            Text(widgetType.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: isEnabledBinding)
                .labelsHidden()
                .toggleStyle(.switch)
            
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.leading, 8)
        }
        .padding(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20))
    }
}

struct LiveActivityRowView: View {
    let activityType: LiveActivityType
    @EnvironmentObject var settings: SettingsModel
    
    private var isEnabledBinding: Binding<Bool> {
        switch activityType {
        case .music: return $settings.settings.musicLiveActivityEnabled
        case .weather: return $settings.settings.weatherLiveActivityEnabled
        case .calendar: return $settings.settings.calendarLiveActivityEnabled
        case .timers: return $settings.settings.timersLiveActivityEnabled
        case .battery: return $settings.settings.batteryLiveActivityEnabled
        case .eyeBreak: return $settings.settings.eyeBreakLiveActivityEnabled
        case .desktop: return $settings.settings.desktopLiveActivityEnabled
        
        case .focus: return $settings.settings.focusLiveActivityEnabled
        }
    }

    var body: some View {
        HStack {
            Text(activityType.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: isEnabledBinding)
                .labelsHidden()
                .toggleStyle(.switch)
            
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.leading, 8)
        }
        .padding(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20))
    }
}


struct NotificationToggleRowView: View {
    let source: NotificationSource
    @EnvironmentObject var settings: SettingsModel

    private var isEnabledBinding: Binding<Bool> {
        switch source {
        case .iMessage: return $settings.settings.iMessageNotificationsEnabled
        case .faceTime: return $settings.settings.faceTimeNotificationsEnabled
        case .airDrop: return $settings.settings.airDropNotificationsEnabled
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: source.systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(source.iconColor)
                .frame(width: 36, height: 36)
                .background(source.iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(source.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: isEnabledBinding)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    }
}

struct SystemAppRowView: View {
    let app: SystemApp
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(app.name)
                .font(.system(size: 13))
                .foregroundStyle(.white)

            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
}

struct ReorderableVStack<Item: Identifiable & Equatable, Content: View>: View {
    @Binding var items: [Item]
    @ViewBuilder var content: (Item) -> Content
    
    @State private var draggingItem: Item?
    @State private var dragOffset: CGSize = .zero

    init(items: Binding<[Item]>, @ViewBuilder content: @escaping (Item) -> Content) {
        self._items = items
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                content(item)
                    .offset(y: draggingItem == item ? dragOffset.height : 0)
                    .opacity(draggingItem == item ? 0.75 : 1)
                    .zIndex(draggingItem == item ? 1 : 0)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .global)
                            .onChanged { value in
                                if draggingItem == nil {
                                    draggingItem = item
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                if let draggingItem = draggingItem {
                                    moveItem(draggedItem: draggingItem, with: value)
                                }
                                withAnimation {
                                    draggingItem = nil
                                    dragOffset = .zero
                                }
                            }
                    )
                
                if item.id != items.last?.id {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 1)
                }
            }
        }
    }

    private func moveItem(draggedItem: Item, with value: DragGesture.Value) {
        guard let fromIndex = items.firstIndex(of: draggedItem) else { return }
        
        let rowHeight: CGFloat = 61.0
        let verticalTranslation = value.translation.height
        let moveOffset = Int((verticalTranslation / rowHeight).rounded())
        
        var toIndex = fromIndex + moveOffset
        toIndex = max(0, min(items.count - 1, toIndex))
        
        if fromIndex != toIndex {
            withAnimation(.spring()) {
                let itemToMove = items.remove(at: fromIndex)
                items.insert(itemToMove, at: toIndex)
            }
        }
    }
}

struct CustomBatterySlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    private let horizontalPadding: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let thumbSize: CGFloat = 40
            
            let trackUsableWidth = totalWidth - (2 * horizontalPadding)
            let thumbUsableWidth = trackUsableWidth - thumbSize
            
            let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            
            let clampedProgress = max(0.0, min(1.0, progress))
            
            let thumbX = (clampedProgress * thumbUsableWidth) + horizontalPadding + (thumbSize / 2)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .padding(.horizontal, horizontalPadding)
                
                Circle()
                    .fill(Color(white: 0.8))
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Text("\(Int(value.rounded()))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    )
                    .position(x: thumbX, y: geometry.size.height / 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gestureValue in
                        let newX = min(max(gestureValue.location.x, horizontalPadding), totalWidth - horizontalPadding)
                        let newProgress = (newX - horizontalPadding) / thumbUsableWidth
                        var newValue = (range.upperBound - range.lowerBound) * Double(newProgress) + range.lowerBound
                        
                        newValue = max(range.lowerBound, min(range.upperBound, newValue))
                        
                        self.value = newValue
                    }
            )
        }
    }
}

struct CustomSliderRowView: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let specifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: specifier, value))
            }
            Slider(value: $value, in: range)
        }
        .padding()
    }
}


struct SettingsContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.black.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

struct SettingsGroup<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        VStack(spacing: 0) { content }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.background.opacity(0.15))
            )
    }
}

struct SettingsDetailRow<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack { content }.foregroundStyle(.secondary)
        }.padding(.vertical, 10)
    }
}
