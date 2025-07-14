//
//  LoginPromptView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-27.
//

import SwiftUI

struct LoginPromptView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("spotify-logo") 
                .resizable().aspectRatio(contentMode: .fit).frame(width: 80)
            
            Text("Connect to Spotify")
                .font(.title2).bold()
            
            Text("Log in to control playback, see your queue, and manage devices.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            
            Button("Log in with Spotify") {
                SpotifyAPIManager.shared.login()
            }
            .buttonStyle(.borderedProminent).tint(.green)
            
            Button("Not Now", action: onDismiss)
                .buttonStyle(.plain).foregroundColor(.secondary)
        }
        .padding(30)
    }
}
