//
//  GeminiAPI.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-06.
//

import Foundation


struct GeminiAPI {
    static func webSocketURL() -> URL? {
        
        let settings = SettingsModel()
        let apiKey = settings.settings.geminiApiKey

        guard !apiKey.isEmpty else {
            return nil
        }
        
        let host = "preprod-generativelanguage.googleapis.com"
        let urlString = "wss://\(host)/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=\(apiKey)"
        return URL(string: urlString)
    }
    static let modelName = "models/gemini-2.0-flash-exp"
}





enum GeminiWebSocketMessage {
    
    
    
    struct Setup: Encodable {
        let setup: Payload
        struct Payload: Encodable {
            let model: String
        }
    }

    
    
    struct AudioInput: Encodable {
        let realtimeInput: Payload
        struct Payload: Encodable {
            let mediaChunks: [MediaChunk]
        }
        struct MediaChunk: Encodable {
            let mimeType: String
            let data: String 
        }
    }

    
    
    
    struct ContentInput: Encodable {
        let clientContent: Payload
        
        struct Payload: Encodable {
            let turns: [Turn]
            let turnComplete: Bool
        }
        
        struct Turn: Encodable {
            let role: String = "user"
            let parts: [Part]
        }

        struct Part: Encodable {
            let text: String?
            let inlineData: InlineData?
            
            
            private enum CodingKeys: String, CodingKey { case text, inlineData }
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                if let text = text {
                    try container.encode(text, forKey: .text)
                } else if let inlineData = inlineData {
                    try container.encode(inlineData, forKey: .inlineData)
                }
            }

            init(text: String) { self.text = text; self.inlineData = nil }
            init(inlineData: InlineData) { self.text = nil; self.inlineData = inlineData }
        }

        struct InlineData: Encodable {
            let mimeType: String
            let data: String 
        }
    }
}




struct ServerSetupComplete: Decodable {
    var setupComplete: EmptyObject
    struct EmptyObject: Decodable {}
}

struct ServerAudioOutput: Decodable {
    var serverContent: ServerContent
    struct ServerContent: Decodable {
        var modelTurn: ModelTurn
        struct ModelTurn: Decodable {
            var parts: [Part]
            struct Part: Decodable {
                var inlineData: PartInlineData
                struct PartInlineData: Decodable { var data: String }
            }
        }
    }
}

struct ServerInterrupted: Decodable {
    var serverContent: ServerContent
    struct ServerContent: Decodable {
        var interrupted: Bool
    }
}

struct ServerTurnComplete: Decodable {
    var serverContent: ServerContent
    struct ServerContent: Decodable {
        var turnComplete: Bool
    }
    var usageMetadata: UsageMetadata
    struct UsageMetadata: Decodable {
        var promptTokenCount: Int
        var responseTokenCount: Int
    }
}
