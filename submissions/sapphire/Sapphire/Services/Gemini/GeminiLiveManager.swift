//
//  GeminiLiveManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import Foundation
import ScreenCaptureKit
import AVFoundation
import Combine
import CoreImage
import AppKit

@MainActor
class GeminiLiveManager: NSObject, ObservableObject, SCStreamOutput, SCStreamDelegate {

    @Published var isSessionRunning = false
    @Published var isMicMuted = true {
        didSet {
        }
    }

    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private var sessionTask: Task<Void, Never>?

    
    private let playbackEngine = AVAudioEngine()
    private var captureEngine: AVAudioEngine?
    private let audioPlayer = AVAudioPlayerNode()
    private let geminiAudioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 24000, channels: 1, interleaved: false)!
    private var playerAudioFormat: AVAudioFormat!
    private var audioConverter_Playback: AVAudioConverter!
    private let audioProcessingQueue = DispatchQueue(label: "com.sapphire.AudioProcessingQueue")
    
    
    private var isSendingUserAudio = false
    private let vadThreshold: Float = 0.01 

    
    private var stream: SCStream?
    private let videoFrameOutputQueue = DispatchQueue(label: "com.sapphire.VideoOutputQueue")
    private let imageContext = CIContext()
    
    let sessionDidEndPublisher = PassthroughSubject<Void, Never>()

    override init() {
        super.init()
        setupPlaybackEngine()
    }

    func startSession(with filter: SCContentFilter) {
        guard !isSessionRunning else { return }
        isSessionRunning = true
        isMicMuted = true
        isSendingUserAudio = false 
        
        guard let url = GeminiAPI.webSocketURL() else {
            isSessionRunning = false
            return
        }
        
        webSocketTask = self.urlSession.webSocketTask(with: url)

        sessionTask = Task {
            do {
                if !self.playbackEngine.isRunning {
                    try self.playbackEngine.start()
                    if !self.audioPlayer.isPlaying { self.audioPlayer.play() }
                }
                
                try self.startCaptureAudio()
                
                webSocketTask?.resume()
                
                try await Task.sleep(for: .milliseconds(100))
                
                try await self.sendSetupMessage()
                
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask { try await self.receiveMessages() }
                    group.addTask { try await self.captureAndSendScreen(with: filter) }
                    try await group.waitForAll()
                }

            } catch {
                if !(error is CancellationError) {
                }
                await self.cleanupSession()
            }
        }
    }
    
    public func signalEndOfUserTurn() {
        Task {
            do {
                
                self.isMicMuted = true
                self.isSendingUserAudio = false
                
                let finalPart = GeminiWebSocketMessage.ContentInput.Part(text: "That's all, please respond based on what you've seen and heard.")
                let turn = GeminiWebSocketMessage.ContentInput.Turn(parts: [finalPart])
                let payload = GeminiWebSocketMessage.ContentInput.Payload(turns: [turn], turnComplete: true)
                let message = GeminiWebSocketMessage.ContentInput(clientContent: payload)
                try await send(message: message)
            } catch {
            }
        }
    }

    func stopSession() async {
        sessionTask?.cancel()
        await cleanupSession()
    }
    
    private func cleanupSession() async {
        if isSessionRunning {
            isSessionRunning = false
            webSocketTask?.cancel(with: .goingAway, reason: nil)
            webSocketTask = nil
            
            if let stream = stream { try? await stream.stopCapture() }
            stream = nil
            
            stopCaptureAudio()
            
            audioPlayer.stop()
            audioPlayer.reset()
            playbackEngine.stop()
            playbackEngine.reset()
            
            sessionDidEndPublisher.send()
        }
    }

    

    private func send<T: Encodable>(message: T) async throws {
        guard let webSocketTask = webSocketTask, webSocketTask.closeCode == .invalid else {
            return
        }

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(message)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        try await webSocketTask.send(.string(jsonString))
    }

    private func sendSetupMessage() async throws {
        let payload = GeminiWebSocketMessage.Setup.Payload(model: GeminiAPI.modelName)
        let message = GeminiWebSocketMessage.Setup(setup: payload)
        try await send(message: message)
    }

    private func sendContentPart(_ part: GeminiWebSocketMessage.ContentInput.Part) async throws {
        let turn = GeminiWebSocketMessage.ContentInput.Turn(parts: [part])
        let payload = GeminiWebSocketMessage.ContentInput.Payload(turns: [turn], turnComplete: false)
        let message = GeminiWebSocketMessage.ContentInput(clientContent: payload)
        try await send(message: message)
    }

    private func receiveMessages() async throws {
        guard let webSocketTask = webSocketTask else { return }
        
        while !Task.isCancelled {
            do {
                let message = try await webSocketTask.receive()
                switch message {
                case .data(let data):
                    try self.handleReceivedJSONData(data)
                case .string(let text):
                    try self.handleReceivedJSONData(Data(text.utf8))
                @unknown default:
                    fatalError("Received unknown WebSocket message type.")
                }
            } catch {
                if !Task.isCancelled {
                    await cleanupSession()
                }
                break
            }
        }
    }
    
    private func handleReceivedJSONData(_ data: Data) throws {
        let decoder = JSONDecoder()
        if (try? decoder.decode(ServerSetupComplete.self, from: data)) != nil {
            Task {
                let initialPart = GeminiWebSocketMessage.ContentInput.Part(text: "Please say 'Hi, what can I help you with?'")
                let turn = GeminiWebSocketMessage.ContentInput.Turn(parts: [initialPart])
                let payload = GeminiWebSocketMessage.ContentInput.Payload(turns: [turn], turnComplete: true)
                let message = GeminiWebSocketMessage.ContentInput(clientContent: payload)
                try await self.send(message: message)
            }
        } else if let audioOutput = try? decoder.decode(ServerAudioOutput.self, from: data),
                  let audioDataB64 = audioOutput.serverContent.modelTurn.parts.first?.inlineData.data,
                  let audioData = Data(base64Encoded: audioDataB64) {
            self.playAudioData(audioData)
        
        } else if let interruptedMessage = try? decoder.decode(ServerInterrupted.self, from: data),
                  interruptedMessage.serverContent.interrupted {
            self.stopAndClearPlayback()
            
        } else if let turnComplete = try? decoder.decode(ServerTurnComplete.self, from: data) {
            if turnComplete.serverContent.turnComplete {
                
                self.isMicMuted = false
                self.isSendingUserAudio = false
            }
        } else {
            let jsonString = String(data: data, encoding: .utf8) ?? "Undecodable binary"
        }
    }

    
    
    private func setupPlaybackEngine() {
        playerAudioFormat = AVAudioFormat(standardFormatWithSampleRate: geminiAudioFormat.sampleRate, channels: geminiAudioFormat.channelCount)!
        audioConverter_Playback = AVAudioConverter(from: geminiAudioFormat, to: playerAudioFormat)!
        playbackEngine.attach(audioPlayer)
        playbackEngine.connect(audioPlayer, to: playbackEngine.outputNode, format: playerAudioFormat)
        playbackEngine.prepare()
    }
    
    private func playAudioData(_ data: Data) {
        guard let geminiBuffer = data.toPCMBuffer(format: geminiAudioFormat) else { return }
        let playerBuffer = AVAudioPCMBuffer(pcmFormat: playerAudioFormat, frameCapacity: geminiBuffer.frameCapacity)!
        isMicMuted = true
        do {
            try audioConverter_Playback.convert(to: playerBuffer, from: geminiBuffer)
            if !playbackEngine.isRunning { try playbackEngine.start() }
            if !audioPlayer.isPlaying { audioPlayer.play() }
            audioPlayer.scheduleBuffer(playerBuffer)
        } catch { print("[ERROR] Playback audio conversion error: \(error)") }
    }

    private func stopAndClearPlayback() {
        isMicMuted = false
        audioPlayer.stop()
        audioPlayer.reset()
    }
    
    private func startCaptureAudio() throws {
        captureEngine = AVAudioEngine()

        guard let captureEngine = captureEngine else { return }
        
        let inputNode = captureEngine.inputNode

        
        
        








        let sourceFormat = inputNode.outputFormat(forBus: 0)
        let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 48000, channels: 1, interleaved: false)!
        
        guard let converter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
            throw NSError(domain: "GeminiLiveManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio converter"])
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: sourceFormat) { [weak self] inputBuffer, _ in
            guard let self = self else { return }
            self.audioProcessingQueue.async {
                guard self.isSessionRunning, !self.isMicMuted else { return }
                
                
                if self.isSendingUserAudio {
                    
                    self.convertAndSend(buffer: inputBuffer, using: converter)
                } else {
                    
                    let level = self.calculateRMSAudioLevel(fromBuffer: inputBuffer)
                    if level > self.vadThreshold {
                        self.isSendingUserAudio = true
                        self.convertAndSend(buffer: inputBuffer, using: converter)
                    }
                }
            }
        }
        captureEngine.prepare()
        try captureEngine.start()
    }

    private func convertAndSend(buffer: AVAudioPCMBuffer, using converter: AVAudioConverter) {
        let targetFormat = converter.outputFormat
        let ratio = targetFormat.sampleRate / buffer.format.sampleRate
        let outputFrameCount = AVAudioFrameCount(ceil(Double(buffer.frameLength) * ratio))
        
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outputFrameCount) else {
            return
        }
        
        var error: NSError?
        var providedInput = false
        
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            if providedInput {
                outStatus.pointee = .noDataNow
                return nil
            }
            outStatus.pointee = .haveData
            providedInput = true
            return buffer
        }
        
        let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)

        
        if status == .error {
            if let e = error {
            }
            return
        }

        
        guard let pcmData = outputBuffer.toData(), !pcmData.isEmpty else { return }
        
        let base64String = pcmData.base64EncodedString()
        let chunk = GeminiWebSocketMessage.AudioInput.MediaChunk(mimeType: "audio/pcm;rate=16000", data: base64String)
        let payload = GeminiWebSocketMessage.AudioInput.Payload(mediaChunks: [chunk])
        let message = GeminiWebSocketMessage.AudioInput(realtimeInput: payload)
        
        Task {
            do {
                try await self.send(message: message)
            } catch {
            }
        }
    }
    
    private func stopCaptureAudio() {
        guard let captureEngine = captureEngine else { return }
        captureEngine.stop()
        captureEngine.inputNode.removeTap(onBus: 0)
        self.captureEngine = nil
    }
    
    
    
    private func captureAndSendScreen(with filter: SCContentFilter) async throws {
        let config = SCStreamConfiguration()
        config.width = 1024; config.height = 768
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
        config.queueDepth = 5
        stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: videoFrameOutputQueue)
        try await stream?.startCapture()
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, sampleBuffer.isValid, isSessionRunning else { return }
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = imageContext.createCGImage(ciImage, from: ciImage.extent),
              let jpegData = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [.compressionFactor: 0.7]) else { return }
        
        let base64String = jpegData.base64EncodedString()
        let inlineData = GeminiWebSocketMessage.ContentInput.InlineData(mimeType: "image/jpeg", data: base64String)
        let part = GeminiWebSocketMessage.ContentInput.Part(inlineData: inlineData)
        
        Task {
            try? await self.sendContentPart(part)
        }
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        Task { await cleanupSession() }
    }
    
    
    private func calculateRMSAudioLevel(fromBuffer buffer: AVAudioPCMBuffer) -> Float {
        guard let floatChannelData = buffer.floatChannelData else {
            
            
            return 0.0
        }

        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        
        var rms: Float = 0.0
        for channel in 0..<channelCount {
            var sum: Float = 0.0
            let data = floatChannelData[channel]
            for i in 0..<frameLength {
                sum += (data[i] * data[i])
            }
            rms += sqrt(sum / Float(frameLength))
        }
        return rms / Float(channelCount)
    }
}


fileprivate extension Data {
    func toPCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCapacity = UInt32(self.count) / format.streamDescription.pointee.mBytesPerFrame
        guard frameCapacity > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
        buffer.frameLength = frameCapacity
        self.withUnsafeBytes { srcBuffer in
            if let baseAddress = srcBuffer.baseAddress, let dest = buffer.int16ChannelData?[0] {
                memcpy(dest, baseAddress, self.count)
            }
        }
        return buffer
    }
}

fileprivate extension AVAudioPCMBuffer {
    func toData() -> Data? {
        
        let frameLength = Int(self.frameLength)
        let channelCount = Int(self.format.channelCount)
        let bytesPerFrame = Int(self.format.streamDescription.pointee.mBytesPerFrame)
        let dataSize = frameLength * bytesPerFrame
        
        guard dataSize > 0, channelCount == 1, let channelData = self.int16ChannelData else { return nil }
        
        return Data(bytes: channelData[0], count: dataSize)
    }
}
