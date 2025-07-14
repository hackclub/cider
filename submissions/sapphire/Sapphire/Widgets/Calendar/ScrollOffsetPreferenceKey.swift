//
//  ScrollOffsetPreferenceKey.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import SwiftUI


struct DayFrame: Equatable {
    let id: Date
    let frame: CGRect
}


struct DayFramesPreferenceKey: PreferenceKey {
    static var defaultValue: [DayFrame] = []

    static func reduce(value: inout [DayFrame], nextValue: () -> [DayFrame]) {
        value.append(contentsOf: nextValue())
    }
}
