//
//  ReceiptyApp.swift
//  Receipty
//
//  Created by Muhammad Anas on 14/07/2024.
//

import SwiftUI

@main
struct ReceiptyApp: App {
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false

    init() {
        if !hasLaunchedBefore {
            UserDefaultsHelper.shared.initializeDefaultReceipts()
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                HomeView()
                    .environmentObject(HomeViewModel())
            } else {
                WelcomeView(hasLaunchedBefore: $hasLaunchedBefore)
                    .environmentObject(HomeViewModel())
            }
        }
    }
}
