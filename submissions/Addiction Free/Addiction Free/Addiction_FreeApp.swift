//
//  Addiction_FreeApp.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 16/08/2024.
//

import SwiftUI

@main
struct Addiction_FreeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Activity.self, Status.self])
                .accentColor(.primary)
        }
    }
}
