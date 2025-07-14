//
//  CalendarWidgetView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import SwiftUI


struct CenterDateInfo: Equatable {
    let date: Date
    let distance: CGFloat
}
struct CenterDatePreferenceKey: PreferenceKey {
    typealias Value = CenterDateInfo?
    static var defaultValue: Value = nil
    static func reduce(value: inout Value, nextValue: () -> Value) {
        guard let next = nextValue() else { return }
        if value == nil || next.distance < value!.distance {
            value = next
        }
    }
}


@available(macOS 14.0, *)
struct CalendarWidgetView: View {
    @StateObject private var viewModel = InteractiveCalendarViewModel()

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(viewModel.selectedMonthAbbreviated)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: 55, alignment: .leading)
                .padding(.top, 4)
                .id("Month-\(viewModel.selectedMonthAbbreviated)")
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: -10)),
                    removal: .opacity.combined(with: .offset(y: 10))
                ))

            VStack(alignment: .leading, spacing: 8) {
                interactiveCalendar()
                eventsView
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 240, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .foregroundColor(.white)
        .environmentObject(viewModel)
    }
    
    private func interactiveCalendar() -> some View {
        ScrollViewReader { proxy in
            GeometryReader { containerProxy in
                let itemWidth: CGFloat = 28
                let itemSpacing: CGFloat = 10
                let horizontalPadding = (containerProxy.size.width / 2) - (itemWidth / 2)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(viewModel.dates, id: \.self) { date in
                            DynamicDayView(
                                date: date,
                                containerMidX: containerProxy.frame(in: .global).midX
                            )
                            .id(date)
                            .onTapGesture {
                                
                                HapticManager.perform(.generic)
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    viewModel.selectDate(date)
                                    proxy.scrollTo(date, anchor: .center)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .onPreferenceChange(CenterDatePreferenceKey.self) { centerInfo in
                    if let newDate = centerInfo?.date, !newDate.isSameDay(as: viewModel.selectedDate) {
                        
                        HapticManager.perform(.alignment)
                        
                        withAnimation(.easeInOut(duration: 0.1)) {
                            viewModel.selectDate(newDate)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(viewModel.today, anchor: .center)
                }
            }
            .frame(height: 38)
        }
    }
    
    private var eventsView: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text("Nothing for today")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}



struct DynamicDayView: View {
    let date: Date
    let containerMidX: CGFloat
    
    @EnvironmentObject private var viewModel: InteractiveCalendarViewModel

    var body: some View {
        let isSelected = date.isSameDay(as: viewModel.selectedDate)
        let dayName = date.format(as: isSelected ? "EEE" : "EEEEE").uppercased()
        
        GeometryReader { itemProxy in
            let itemMidX = itemProxy.frame(in: .global).midX
            let distance = itemMidX - containerMidX
            
            let absDistance = abs(distance)
            let focusFactor = max(0, 1 - (absDistance / 80))
            
            let scale = 0.7 + (focusFactor * 0.7)
            let opacity = 0.5 + (focusFactor * 0.5)
            let blur = (1 - focusFactor) * 1.5
            let rotationAngle = Angle.degrees(Double(distance / 10))
            
            let baseColor = date.isWeekend ? Color.red.opacity(0.8) : Color.white.opacity(0.8)
            let finalColor = baseColor.lerp(to: .blue, t: focusFactor)
            let dayLetterColor = Color.gray.lerp(to: .blue, t: focusFactor)
            
            VStack(spacing: 3) {
                Text(dayName)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(dayLetterColor)
                    .id(dayName)
                    .transition(
                        .asymmetric(
                            insertion: .offset(y: 10).combined(with: .opacity),
                            removal: .offset(y: -10).combined(with: .opacity)
                        )
                    )
                
                Text(date.format(as: "d"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(finalColor)
            }
            .scaleEffect(scale)
            .blur(radius: blur)
            .opacity(opacity)
            .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .frame(width: itemProxy.size.width, height: itemProxy.size.height)
            .preference(key: CenterDatePreferenceKey.self, value: CenterDateInfo(date: date, distance: absDistance))
        }
        .frame(width: 28)
    }
}
