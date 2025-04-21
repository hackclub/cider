//
//  SettingsView.swift
//  Tic Tac Toe
//
//  Created by Lai Hong Yu on 11/12/24.
//

import Foundation
import SwiftUICore
import DataSave
import UIKit
import AVKit
class SettingsViewViewModel: ObservableObject{
    @Published var popAudioPlayer: AVAudioPlayer!
    @Published var AIOPlayer: String = "off"
    @Published var xImageName: String = "xmark"
    @Published var oImageName: String = "circle"
    @Published var generator = UINotificationFeedbackGenerator()
    @Published var colour : Color = Color(red: 27/255.0, green: 20/255.0, blue: 100/255.0).opacity(1)
    @Published var musicChoice: String = "song 3"
    init(){
        if let savedx = DataSave.retrieveFromUserDefaults(forKey: "firstIcon", as: String.self) {
            xImageName = savedx
        } else {
            print("No data found for the given key.")
        }
        if let savedy = DataSave.retrieveFromUserDefaults(forKey: "secondIcon", as: String.self) {
            oImageName = savedy
        } else {
            print("No data found for the given key.")
        }
        if let musicChoice1 = DataSave.retrieveFromUserDefaults(forKey: "musicChoice", as: String.self) {
            musicChoice = musicChoice1
        } else {
            print("No data found for the given key.")
        }
        if let savedColourRGBA = DataSave.retrieveFromUserDefaults(forKey: "colour", as: [String: CGFloat].self ){
            colour = Color(rgba: savedColourRGBA) ?? Color(red: 27/255.0, green: 20/255.0, blue: 100/255.0).opacity(1)
        }
        
    }
    func playPop() {
        if let soundPath = Bundle.main.path(forResource: "pop", ofType: "mp3") {
            do {
                let newPopAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                newPopAudioPlayer.volume = 2
                newPopAudioPlayer.play()
                
                self.popAudioPlayer = newPopAudioPlayer
            } catch {
                print("Failed to play pop sound: \(error.localizedDescription)")
            }
        } else {
            print("Pop sound file not found in bundle.")
        }
    }
    
    func save(){
        generator.notificationOccurred(.success)
        let firstIcon = xImageName
        let secondIcon = oImageName
        let colours = colour
        let musicChoiceSaved = DataSave.saveToUserDefaults(musicChoice, forKey: "musicChoice")
        let firstIconSaved = DataSave.saveToUserDefaults(firstIcon, forKey: "firstIcon")
        let secondIconSaved = DataSave.saveToUserDefaults(secondIcon, forKey: "secondIcon")
        let colourRGBA = colour.toRGBA()
        let coloursSaved = DataSave.saveToUserDefaults(colourRGBA, forKey: "colour")

    }
    
}
