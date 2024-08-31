//
//  ContentView.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 16/08/2024.
//

import SwiftUI
import SwiftData


let isFirstTime = UserDefaults.standard.bool(forKey: "firstTime")
struct ContentView: View {
    @State private var isAuthenticated = false
    var body: some View {
        ZStack {
            if isAuthenticated {
                Home()
            } else {
                if isFirstTime {
                    PasswordView(isAuthenticated: $isAuthenticated)
                } else {
                    OnBoard()
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
