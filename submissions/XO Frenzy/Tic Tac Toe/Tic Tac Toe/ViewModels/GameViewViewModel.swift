//
//  GameView.swift
//  Tic Tac Toe
//
//  Created by Lai Hong Yu on 11/12/24.
//
import SwiftUI
import AVKit
import GameKit
import DataSave
import AudioToolbox
enum PlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please log in to Game Center"
    case authenticated = ""
    case error = "There was an error with Game Center"
    case restricted = "You are not allowed to play in multiplayer games"
        
}

class GameViewViewModel: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer!
    func addDelay(seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    @Published var isGameOver = true
    @Published var authenticationState = PlayerAuthState.authenticating
    @Published var musicChoice = "song 3"
    @Published var showWinningMessage = false
    @Published var player1Wins = 0
    @Published var player2Wins = 0
    @Published var draws = 0
    @Published var isPresented = false
    @Published var board: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)
    @Published var isPlayerXTurn: Bool = true
    @Published var gameResult: String? = nil
    @Published var showConfetti = false
    //Game Manager:
    var match: GKMatch?
    var player1 = GKLocalPlayer.local
    var player2: GKPlayer?
    var playerUUIDKey = UUID().uuidString
    var rootViewController: UIViewController?{
        let windowScence = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScence?.windows.first?.rootViewController
    }
    
    func authenticateUser(){
        GKLocalPlayer.local.authenticateHandler = {[self]vc, e in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error = e{
                authenticationState = .error
                print(error.localizedDescription)
                return
            }
            if player1.isAuthenticated{
                if player1.isMultiplayerGamingRestricted{
                    authenticationState = .restricted
                }else{
                    authenticationState = .authenticated
                }
            }else{
                authenticationState = .unauthenticated
            }
        }
    }
    
    init() {
        if let musicChoice1 = DataSave.retrieveFromUserDefaults(forKey: "musicChoice", as: String.self) {
            musicChoice = musicChoice1
        } else {
            print("No data found for the given key.")
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }

        if let soundPath = Bundle.main.path(forResource: musicChoice, ofType: "mp3") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                self.audioPlayer?.numberOfLoops = -1 // Set to loop forever
                self.audioPlayer?.play()
            } catch {
                print("Failed to initialize AVAudioPlayer: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found in bundle.")
        }
        
        
        }
    
    func checkGameResult() {
        for i in 0..<5 {
            // Check rows for 4 in a row
            for j in 0..<2 { 
                if board[i][j] != "" && board[i][j] == board[i][j + 1] && board[i][j + 1] == board[i][j + 2] && board[i][j + 2] == board[i][j + 3] {
                    if board[i][j] == "X" {
                        gameResult = "Player 1 Wins!"
                        player1Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    } else {
                        gameResult = "Player 2 Wins!"
                        player2Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    }
                    showConfetti.toggle()
                    if showConfetti{
                                    self.showWinningMessage = true

                                    
                                    actionButtonOne(SystemSoundID(kSystemSoundID_Vibrate))
                                   

                                }
                    return
                }
            }
            
            // Check columns for 4 in a row
            for j in 0..<2 {
                if board[j][i] != "" && board[j][i] == board[j + 1][i] && board[j + 1][i] == board[j + 2][i] && board[j + 2][i] == board[j + 3][i] {
                    if board[j][i] == "X" {
                        gameResult = "Player 1 Wins!"
                        player1Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    } else {
                        gameResult = "Player 2 Wins!"
                        player2Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    }
                    showConfetti.toggle()
                    if showConfetti{
                                    self.showWinningMessage = true

                                    
                                    actionButtonOne(SystemSoundID(kSystemSoundID_Vibrate))
                                   

                                }
                    return
                }
            }
        }

        // Check main diagonals for 4 in a row
        for i in 0..<2 {
            for j in 0..<2 {
                if board[i][j] != "" && board[i][j] == board[i + 1][j + 1] && board[i + 1][j + 1] == board[i + 2][j + 2] && board[i + 2][j + 2] == board[i + 3][j + 3] {
                    if board[i][j] == "X" {
                        gameResult = "Player 1 Wins!"
                        player1Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    } else {
                        gameResult = "Player 2 Wins!"
                        player2Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5)
                        isPlayerXTurn = true
                    }
                    showConfetti.toggle()
                    if showConfetti{
                                    self.showWinningMessage = true

                                    
                                    actionButtonOne(SystemSoundID(kSystemSoundID_Vibrate))
                                   

                                }
                    return
                }
            }
        }
        
        // Check anti-diagonals for 4 in a row
        for i in 0..<2 {
            for j in 3..<5 {
                if board[i][j] != "" && board[i][j] == board[i + 1][j - 1] && board[i + 1][j - 1] == board[i + 2][j - 2] && board[i + 2][j - 2] == board[i + 3][j - 3] {
                    if board[i][j] == "X" {
                        gameResult = "Player 1 Wins!"
                        player1Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5) // Reset board
                        isPlayerXTurn = true
                    } else {
                        gameResult = "Player 2 Wins!"
                        player2Wins += 1
                        board = Array(repeating: Array(repeating: "", count: 5), count: 5) // Reset board
                        isPlayerXTurn = true
                    }
                    showConfetti.toggle()
                    if showConfetti{
                                    self.showWinningMessage = true

                                    
                                    actionButtonOne(SystemSoundID(kSystemSoundID_Vibrate))
                                   

                                }
                    return
                }
            }
        }
        
        // Check for a draw
        if !board.flatMap({ $0 }).contains("") {
            gameResult = "It's a Draw!"
            draws += 1
            board = Array(repeating: Array(repeating: "", count: 5), count: 5)
            isPlayerXTurn = true
            showConfetti.toggle()
            self.showWinningMessage = true

            
            actionButtonOne(SystemSoundID(kSystemSoundID_Vibrate))
           
        }
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: "", count: 5), count: 5) // Updated to 5x5
        isPlayerXTurn = true
    }
    @IBAction func actionButtonOne(_ sender: Any) {
       AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    @IBAction func actionButtonTwo(_ sender: Any) {
       let generator = UIImpactFeedbackGenerator(style: .heavy)
       generator.impactOccurred()
    }
    @IBAction func actionButtonThree(_ sender: Any) {
       let generator = UIImpactFeedbackGenerator(style: .light)
       generator.impactOccurred()
    }
    @IBAction func actionButtonFour(_ sender: Any) {
       let generator = UIImpactFeedbackGenerator(style: .medium)
       generator.impactOccurred()
    }
}
