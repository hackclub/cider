//
//  Home.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 17/08/2024.
//

import SwiftUI

struct Home: View {
    @State private var key = UUID()
    @State private var number = 0
    var body: some View {
        NavigationView {
            VStack {
                CalendarHeader()
                    .padding(.top, 12)
                Streak()
                    Text("How have you been doing with staying clear of your addiction?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .cornerRadius(12)
                    AddictionTrack(count: $number)
            }
            .navigationTitle("Home")
            .toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .onAppear(perform: {
            let _: Void = UserDefaults.standard.set(true, forKey: "firstTime")
        })
        .id(key)
        .onChange(of: number, {oldValue, newValue in
            reload()})
        .ignoresSafeArea()
    }
    func reload() {
        key = UUID()
    }
}

#Preview {
    Home()
}
