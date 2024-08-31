//
//  Color.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 26/08/2024.
//

import Foundation
import SwiftUI

extension Color {
    static var secondary: Color {
        if UITraitCollection.current.userInterfaceStyle == .light {
            return .white
        } else {
            return .black
        }
    }
}
