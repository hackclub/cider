//
//  NumberFormatter+Currency.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import Foundation

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current // Use the device's current locale
        return formatter
    }
}
