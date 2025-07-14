//
//  LyricsFetcher.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-26.
//

import Foundation

class LyricsFetcher {

    
    func fetchSyncedLyrics(for title: String, artist: String, album: String) async -> [LyricLine]? {
        
        var components = URLComponents(string: "https://lrclib.net/api/get")!
        components.queryItems = [
            URLQueryItem(name: "track_name", value: title),
            URLQueryItem(name: "artist_name", value: artist),
            URLQueryItem(name: "album_name", value: album)
        ]
        
        guard let url = components.url else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            struct LrcLibResponse: Decodable {
                let syncedLyrics: String?
            }
            
            let response = try JSONDecoder().decode(LrcLibResponse.self, from: data)
            
            if let lrcString = response.syncedLyrics, !lrcString.isEmpty {
                return parseLRC(lrcString)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    private func parseLRC(_ lrcString: String) -> [LyricLine] {
        var lyrics: [LyricLine] = []
        let lines = lrcString.components(separatedBy: .newlines)
        
        for line in lines {
            if line.hasPrefix("[") && line.contains("]") {
                let components = line.components(separatedBy: "]")
                if components.count > 1 {
                    let timestampString = String(components[0].dropFirst())
                    let text = components[1].trimmingCharacters(in: .whitespaces)
                    
                    let timeComponents = timestampString.components(separatedBy: ":")
                    if timeComponents.count == 2,
                       let minutes = Double(timeComponents[0]),
                       let seconds = Double(timeComponents[1]) {
                        
                        let timestamp = (minutes * 60) + seconds
                        lyrics.append(LyricLine(text: text, timestamp: timestamp))
                    }
                }
            }
        }
        return lyrics.sorted { $0.timestamp < $1.timestamp }
    }

    
    func detectLanguage(for text: String) async -> String? {
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return nil
        }
        
        var components = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: "en"),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: trimmedText.prefix(500).description)
        ]
        
        guard let url = components.url else { return nil }

        struct UnofficialGoogleDetectionResponse: Decodable {
            let detectedLanguage: String?
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                _ = try? container.nestedUnkeyedContainer()
                _ = try? container.decode(String?.self)
                self.detectedLanguage = try? container.decode(String.self)
            }
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let unofficialResponse = try JSONDecoder().decode(UnofficialGoogleDetectionResponse.self, from: data)
            if let lang = unofficialResponse.detectedLanguage {
                return lang
            }
        } catch {
        }
        return nil
    }

    
    func translate(lyrics: inout [LyricLine], from sourceLanguage: String, to targetLanguage: String) async {

        struct UnofficialGoogleTranslateResponse: Decodable {
            let translatedText: String?
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                if var outerArray = try? container.nestedUnkeyedContainer(),
                   var firstInnerArray = try? outerArray.nestedUnkeyedContainer() {
                    self.translatedText = try? firstInnerArray.decode(String.self)
                } else {
                    self.translatedText = nil
                }
            }
        }

        for i in 0..<lyrics.count {
            let originalText = lyrics[i].text
            if originalText.isEmpty { continue }

            var components = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
            components.queryItems = [
                URLQueryItem(name: "client", value: "gtx"),
                URLQueryItem(name: "sl", value: sourceLanguage),
                URLQueryItem(name: "tl", value: targetLanguage),
                URLQueryItem(name: "dt", value: "t"),
                URLQueryItem(name: "q", value: originalText)
            ]
            
            guard let url = components.url else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let unofficialResponse = try JSONDecoder().decode(UnofficialGoogleTranslateResponse.self, from: data)
                if let translatedText = unofficialResponse.translatedText {
                    lyrics[i].translatedText = translatedText
                }
            } catch {
            }
        }
    }
}
