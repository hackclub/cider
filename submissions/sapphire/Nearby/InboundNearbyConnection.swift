//
//  InboundNearbyConnection.swift
//  NearDrop
//
//  Created by Grishka on 08.04.2023.
//

import Foundation
import Network
import CryptoKit
import CommonCrypto
import System
import AppKit
import SwiftECC
import BigInt

protocol InboundNearbyConnectionDelegate {
    func obtainUserConsent(for transfer: TransferMetadata, from device: RemoteDeviceInfo, fileURLs: [URL])
    func connection(_ connection: InboundNearbyConnection, didUpdateProgress progress: Double)
    func connectionWasTerminated(connection: InboundNearbyConnection, error: Error?)
}

class InboundNearbyConnection: NearbyConnection {
    private var currentState: State = .initial
    public var delegate: InboundNearbyConnectionDelegate?
    private var cipherCommitment: Data?
    private var textPayloadID: Int64 = 0
    private var userAction: NearDropUserAction = .save

    enum State {
        case initial, receivedConnectionRequest, sentUkeyServerInit, receivedUkeyClientFinish, sentConnectionResponse, sentPairedKeyResult, receivedPairedKeyResult, waitingForUserConsent, receivingFiles, disconnecting, disconnected
    }

    override init(connection: NWConnection, id: String) {
        super.init(connection: connection, id: id)
    }

    override func handleConnectionClosure() {
        // If the connection is closed by the peer before the transfer is finished,
        // and we don't have a specific error, treat it as a cancellation.
        // This handles cases where the sender cancels the transfer from their device or it times out.
        if (currentState == .waitingForUserConsent || currentState == .receivingFiles) && lastError == nil {
            lastError = NearbyError.canceled(reason: .userCanceled)
        }

        super.handleConnectionClosure()
        currentState = .disconnected
        do { try deletePartiallyReceivedFiles() } catch { print("Error deleting partially received files: \(error)") }
        DispatchQueue.main.async { self.delegate?.connectionWasTerminated(connection: self, error: self.lastError) }
    }

    override internal func processReceivedFrame(frameData: Data) {
        do {
            switch currentState {
            case .initial: try processConnectionRequestFrame(try Location_Nearby_Connections_OfflineFrame(serializedData: frameData))
            case .receivedConnectionRequest: let msg = try Securegcm_Ukey2Message(serializedData: frameData); ukeyClientInitMsgData = frameData; try processUkey2ClientInit(msg)
            case .sentUkeyServerInit: try processUkey2ClientFinish(try Securegcm_Ukey2Message(serializedData: frameData), raw: frameData)
            case .receivedUkeyClientFinish: try processConnectionResponseFrame(try Location_Nearby_Connections_OfflineFrame(serializedData: frameData))
            default: try decryptAndProcessReceivedSecureMessage(try Securemessage_SecureMessage(serializedData: frameData))
            }
        } catch { lastError = error; print("Deserialization error: \(error) in state \(currentState)"); protocolError() }
    }

    override internal func processTransferSetupFrame(_ frame: Sharing_Nearby_Frame) throws {
        if frame.hasV1, frame.v1.hasType, case .cancel = frame.v1.type { print("Transfer canceled"); try sendDisconnectionAndDisconnect(); return }
        switch currentState {
        case .sentConnectionResponse: try processPairedKeyEncryptionFrame(frame)
        case .sentPairedKeyResult: try processPairedKeyResultFrame(frame)
        case .receivedPairedKeyResult: try processIntroductionFrame(frame)
        case .receivingFiles: break // This is expected after accepting
        default: print("Unexpected connection state in processTransferSetupFrame: \(currentState)\n\(frame)")
        }
    }

    override func isServer() -> Bool { return true }

    override func processFileChunk(frame: Location_Nearby_Connections_PayloadTransferFrame) throws {
        let id = frame.payloadHeader.id
        guard let fileInfo = transferredFiles[id] else { throw NearbyError.protocolError("File payload ID \(id) is not known") }
        let currentOffset = fileInfo.bytesTransferred
        guard frame.payloadChunk.offset == currentOffset else { throw NearbyError.protocolError("Invalid offset") }
        guard currentOffset + Int64(frame.payloadChunk.body.count) <= fileInfo.meta.size else { throw NearbyError.protocolError("File size mismatch") }
        
        if !frame.payloadChunk.body.isEmpty {
            fileInfo.fileHandle?.write(frame.payloadChunk.body)
            transferredFiles[id]!.bytesTransferred += Int64(frame.payloadChunk.body.count)
            fileInfo.progress?.completedUnitCount = transferredFiles[id]!.bytesTransferred
            let progress = Double(transferredFiles[id]!.bytesTransferred) / Double(fileInfo.meta.size)
            DispatchQueue.main.async {
                self.delegate?.connection(self, didUpdateProgress: progress)
            }
        }

        if (frame.payloadChunk.flags & 1) == 1 {
            try fileInfo.fileHandle?.close(); transferredFiles[id]!.fileHandle = nil; fileInfo.progress?.unpublish()

            if userAction == .copy {
                if let fileContents = try? String(contentsOf: fileInfo.destinationURL, encoding: .utf8) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(fileContents, forType: .string)
                }
                try? FileManager.default.removeItem(at: fileInfo.destinationURL)
            }
            
            transferredFiles.removeValue(forKey: id)
            if transferredFiles.isEmpty {
                currentState = .disconnecting
                try sendDisconnectionAndDisconnect()
            }
        }
    }

    override func processBytesPayload(payload: Data, id: Int64) throws -> Bool {
        if id == textPayloadID {
            guard let textContent = String(data: payload, encoding: .utf8) else {
                if userAction != .save { print("Received non-UTF8 payload for an action other than save. Saving as binary.") }
                try saveBinaryPayload(payload)
                return true
            }

            switch self.userAction {
            case .save:
                try saveTextPayload(textContent)
            case .open:
                if let url = extractURL(from: textContent) { NSWorkspace.shared.open(url) }
                else { print("Could not extract URL to open, saving as text instead."); try saveTextPayload(textContent) }
            case .copy:
                let textToCopy = extractURL(from: textContent)?.absoluteString ?? textContent
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(textToCopy, forType: .string)
            }
            
            currentState = .disconnecting
            try sendDisconnectionAndDisconnect()
            return true
        }
        return false
    }

    private func processConnectionRequestFrame(_ frame: Location_Nearby_Connections_OfflineFrame) throws {
        guard frame.hasV1, frame.v1.hasConnectionRequest, frame.v1.connectionRequest.hasEndpointInfo, case .connectionRequest = frame.v1.type else { throw NearbyError.protocolError("Invalid connection request frame") }
        let endpointInfo = frame.v1.connectionRequest.endpointInfo
        guard endpointInfo.count > 17 else { throw NearbyError.protocolError("Endpoint info too short") }
        let deviceNameLength = Int(endpointInfo[17]); guard endpointInfo.count >= deviceNameLength + 18 else { throw NearbyError.protocolError("Endpoint info too short for name") }
        guard let deviceName = String(data: endpointInfo[18..<(18 + deviceNameLength)], encoding: .utf8) else { throw NearbyError.protocolError("Device name is not valid UTF-8") }
        let rawDeviceType = Int(endpointInfo[0] & 7) >> 1
        remoteDeviceInfo = RemoteDeviceInfo(name: deviceName, type: .fromRawValue(value: rawDeviceType))
        currentState = .receivedConnectionRequest
    }

    private func processUkey2ClientInit(_ msg: Securegcm_Ukey2Message) throws {
        guard msg.hasMessageType, msg.hasMessageData, case .clientInit = msg.messageType else { sendUkey2Alert(type: .badMessageType); throw NearbyError.ukey2 }
        let clientInit = try Securegcm_Ukey2ClientInit(serializedData: msg.messageData)
        guard clientInit.version == 1 else { sendUkey2Alert(type: .badVersion); throw NearbyError.ukey2 }
        guard clientInit.random.count == 32 else { sendUkey2Alert(type: .badRandom); throw NearbyError.ukey2 }
        guard let commitment = clientInit.cipherCommitments.first(where: { $0.handshakeCipher == .p256Sha512 }) else { sendUkey2Alert(type: .badHandshakeCipher); throw NearbyError.ukey2 }
        cipherCommitment = commitment.commitment
        guard clientInit.nextProtocol == "AES_256_CBC-HMAC_SHA256" else { sendUkey2Alert(type: .badNextProtocol); throw NearbyError.ukey2 }
        
        let domain = Domain.instance(curve: .EC256r1); let (pubKey, privKey) = domain.makeKeyPair(); publicKey = pubKey; privateKey = privKey
        var serverInit = Securegcm_Ukey2ServerInit(); serverInit.version = 1; serverInit.random = Data.randomData(length: 32); serverInit.handshakeCipher = .p256Sha512
        var pkey = Securemessage_GenericPublicKey(); pkey.type = .ecP256; pkey.ecP256PublicKey.x = Data(pubKey.w.x.asSignedBytes()); pkey.ecP256PublicKey.y = Data(pubKey.w.y.asSignedBytes()); serverInit.publicKey = try pkey.serializedData()
        var serverInitMsg = Securegcm_Ukey2Message(); serverInitMsg.messageType = .serverInit; serverInitMsg.messageData = try serverInit.serializedData()
        let serverInitData = try serverInitMsg.serializedData(); ukeyServerInitMsgData = serverInitData; sendFrameAsync(serverInitData); currentState = .sentUkeyServerInit
    }

    private func processUkey2ClientFinish(_ msg: Securegcm_Ukey2Message, raw: Data) throws {
        guard msg.hasMessageType, msg.hasMessageData, case .clientFinish = msg.messageType else { throw NearbyError.ukey2 }
        var sha = SHA512(); sha.update(data: raw); guard cipherCommitment == Data(sha.finalize()) else { throw NearbyError.ukey2 }
        let clientFinish = try Securegcm_Ukey2ClientFinished(serializedData: msg.messageData)
        try finalizeKeyExchange(peerKey: try Securemessage_GenericPublicKey(serializedData: clientFinish.publicKey)); currentState = .receivedUkeyClientFinish
    }

    private func processConnectionResponseFrame(_ frame: Location_Nearby_Connections_OfflineFrame) throws {
        guard frame.hasV1, frame.v1.hasType, case .connectionResponse = frame.v1.type else { return }
        var resp = Location_Nearby_Connections_OfflineFrame(); resp.version = .v1; resp.v1.type = .connectionResponse; resp.v1.connectionResponse.response = .accept; resp.v1.connectionResponse.osInfo.type = .apple; sendFrameAsync(try resp.serializedData())
        encryptionDone = true; var pairedEncryption = Sharing_Nearby_Frame(); pairedEncryption.version = .v1; pairedEncryption.v1.type = .pairedKeyEncryption
        pairedEncryption.v1.pairedKeyEncryption.secretIDHash = Data.randomData(length: 6); pairedEncryption.v1.pairedKeyEncryption.signedData = Data.randomData(length: 72); try sendTransferSetupFrame(pairedEncryption); currentState = .sentConnectionResponse
    }

    private func processPairedKeyEncryptionFrame(_ frame: Sharing_Nearby_Frame) throws {
        guard frame.hasV1, frame.v1.hasPairedKeyEncryption else { throw NearbyError.requiredFieldMissing("shareNearbyFrame.v1.pairedKeyEncryption") }
        var pairedResult = Sharing_Nearby_Frame(); pairedResult.version = .v1; pairedResult.v1.type = .pairedKeyResult; pairedResult.v1.pairedKeyResult.status = .unable; try sendTransferSetupFrame(pairedResult); currentState = .sentPairedKeyResult
    }

    private func processPairedKeyResultFrame(_ frame: Sharing_Nearby_Frame) throws {
        guard frame.hasV1, frame.v1.hasPairedKeyResult else { throw NearbyError.requiredFieldMissing("shareNearbyFrame.v1.pairedKeyResult") }
        currentState = .receivedPairedKeyResult
    }

    private func processIntroductionFrame(_ frame: Sharing_Nearby_Frame) throws {
        guard frame.hasV1, frame.v1.hasIntroduction else { throw NearbyError.requiredFieldMissing("shareNearbyFrame.v1.introduction") }
        currentState = .waitingForUserConsent;
        var destinationURLs: [URL] = []
        let downloadsDirectory = (try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)).resolvingSymlinksInPath()
        var textDescription: String?
        
        if !frame.v1.introduction.fileMetadata.isEmpty {
            let files = frame.v1.introduction.fileMetadata
            for file in files {
                let dest = makeFileDestinationURL(downloadsDirectory.appendingPathComponent(file.name)); destinationURLs.append(dest)
                let info = InternalFileInfo(meta: .init(name: file.name, size: file.size, mimeType: file.mimeType), payloadID: file.payloadID, destinationURL: dest)
                transferredFiles[file.payloadID] = info
            }
            if files.count == 1, let firstFile = files.first, (firstFile.mimeType == "text/plain" || firstFile.name.lowercased().hasSuffix(".txt")) {
                textDescription = firstFile.name
            }
            let metadata = TransferMetadata(files: transferredFiles.values.map { $0.meta }, id: id, pinCode: pinCode, textDescription: textDescription)
            DispatchQueue.main.async { self.delegate?.obtainUserConsent(for: metadata, from: self.remoteDeviceInfo!, fileURLs: destinationURLs) }
        } else if let meta = frame.v1.introduction.textMetadata.first {
            textPayloadID = meta.payloadID
            let metadata = TransferMetadata(files: [], id: id, pinCode: pinCode, textDescription: meta.textTitle)
            DispatchQueue.main.async { self.delegate?.obtainUserConsent(for: metadata, from: self.remoteDeviceInfo!, fileURLs: []) }
        } else {
            rejectTransfer(with: .unsupportedAttachmentType)
        }
    }
    
    private func makeFileDestinationURL(_ initialDest: URL) -> URL {
        var dest = initialDest; var counter = 1
        if FileManager.default.fileExists(atPath: dest.path) {
            let ext = dest.pathExtension; let baseUrl = dest.deletingPathExtension()
            repeat { dest = URL(fileURLWithPath: "\(baseUrl.path) (\(counter))\(ext.isEmpty ? "" : ".\(ext)")"); counter += 1 } while FileManager.default.fileExists(atPath: dest.path)
        }
        return dest
    }

    func submitUserConsent(accepted: Bool, action: NearDropUserAction) {
        DispatchQueue.global(qos: .utility).async {
            if accepted { self.userAction = action; self.acceptTransfer() }
            else { self.rejectTransfer() }
        }
    }

    private func acceptTransfer() {
        do {
            if !transferredFiles.isEmpty {
                for (id, file) in transferredFiles {
                    FileManager.default.createFile(atPath: file.destinationURL.path, contents: nil)
                    let handle = try FileHandle(forWritingTo: file.destinationURL); transferredFiles[id]!.fileHandle = handle
                    let progress = Progress(); progress.fileURL = file.destinationURL; progress.totalUnitCount = file.meta.size; progress.kind = .file; progress.isPausable = false; progress.publish(); transferredFiles[id]!.progress = progress
                }
            }
            var frame = Sharing_Nearby_Frame(); frame.version = .v1; frame.v1.type = .response; frame.v1.connectionResponse.status = .accept; currentState = .receivingFiles; try sendTransferSetupFrame(frame)
        } catch { lastError = error; protocolError() }
    }

    private func rejectTransfer(with reason: Sharing_Nearby_ConnectionResponseFrame.Status = .reject) {
        var frame = Sharing_Nearby_Frame(); frame.version = .v1; frame.v1.type = .response; frame.v1.connectionResponse.status = reason
        do {
            try sendTransferSetupFrame(frame)
            if reason == .reject {
                self.lastError = NearbyError.canceled(reason: .userRejected)
            }
            try sendDisconnectionAndDisconnect()
        } catch {
            print("Error \(error)")
            protocolError()
        }
    }
    
    private func extractURL(from string: String) -> URL? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            if let match = detector.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
                return match.url
            }
        } catch {
            print("Error creating data detector: \(error.localizedDescription)")
        }
        return nil
    }

    private func saveTextPayload(_ text: String) throws {
        let downloadsDirectory = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let dest = makeFileDestinationURL(downloadsDirectory.appendingPathComponent("Nearby Text \(dateFormatter.string(from: Date())).txt"))
        try text.data(using: .utf8)?.write(to: dest)
    }

    private func saveBinaryPayload(_ data: Data) throws {
        let downloadsDirectory = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let dest = makeFileDestinationURL(downloadsDirectory.appendingPathComponent("Nearby Data \(dateFormatter.string(from: Date())).bin"))
        try data.write(to: dest)
    }

    private func deletePartiallyReceivedFiles() throws {
        for (_, file) in transferredFiles where file.created { try FileManager.default.removeItem(at: file.destinationURL) }
    }
}
