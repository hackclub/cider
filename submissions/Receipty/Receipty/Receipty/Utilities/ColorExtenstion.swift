//
//  ColorExtenstion.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//


import SwiftUI

extension Color {
    static let primaryBackground = Color(hex: "#000000") // Full black background
    static let secondaryText = Color(hex: "#fdf0d5") // Soft beige for text and icons

    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b)
        } else {
            self.init(red: 0, green: 0, blue: 0) // Default to black if the hex string is invalid
        }
    }
}
