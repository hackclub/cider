//
//  OnBoard.swift
//  Addiction Free
//
//  Created by MasterbrosDev, Barnabás on 27/08/2024.
//

import SwiftUI

import SwiftUI

let screenSize = UIScreen.main.bounds.size

struct OnBoard: View {
    @State var landed = true

    var body: some View {
        if landed {
            NavigationView {
                ZStack {
                    VStack {
                        Spacer()
                            .frame(height: screenSize.height / 7)

                        Text("👋")
                            .font(.system(size: 175))

                        Spacer()

                        Text("Welcome to Addiction Free!")
                            .font(.system(size: 45))
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)

                        Spacer()
                            .frame(height: 20)

                        Text("This app will help you get over your addictions")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding([.leading, .bottom, .trailing])
                            .foregroundColor(Color.primary)

                        NavigationLink(destination: NextScreen(landed: $landed)) {
                            Text("Next")
                                .frame(width: screenSize.width * 0.55, height: screenSize.height * 0.05)
                                .foregroundColor(Color.secondary)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.primary)
                        .cornerRadius(20)
                    }
                }
            }
            .onAppear {
                UserDefaults.standard.set(false, forKey: "faceid")
            }
        } else {
            PincodeSet()
        }
    }
}

struct NextScreen: View {
    @Binding var landed: Bool

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: screenSize.height / 7)

                Text("🔐")
                    .font(.system(size: 175))

                Spacer()
                    .frame(height: 56)

                Text("Get over your addictions!")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)

                Spacer()
                    .frame(height: 10)

                Text("You can easily check your past failures directly within the app, all stored on your device. Now, let's set up your PIN code.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding([.leading, .bottom, .trailing])

                Spacer()

                Button(action: {
                    landed = false
                }) {
                    Text("Create PIN")
                        .frame(width: screenSize.width * 0.55, height: screenSize.height * 0.05)
                        .foregroundColor(Color.secondary)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.primary)
                .cornerRadius(20)
            }
        }
    }
}

#Preview {
    OnBoard()
}
