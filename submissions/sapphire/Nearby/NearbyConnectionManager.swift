//
//  NearbyConnectionManager.swift
//  NearDrop
//
//  Created by Grishka on 08.04.2023.
//

import Foundation
import Network
import System
import Combine

public enum NearDropUserAction {
    case save
    case open
    case copy
}

public struct RemoteDeviceInfo{
    public let name:String
    public let type:DeviceType
    public var id:String?
    
    init(name: String, type: DeviceType, id: String? = nil) {
        self.name = name
        self.type = type
        self.id = id
    }
    
    init(info:EndpointInfo){
        self.name=info.name
        self.type=info.deviceType
    }
    
    public enum DeviceType:Int32{
        case unknown=0
        case phone
        case tablet
        case computer
        
        public static func fromRawValue(value:Int) -> DeviceType{
            switch value {
            case 0:
                return .unknown
            case 1:
                return .phone
            case 2:
                return .tablet
            case 3:
                return .computer
            default:
                return .unknown
            }
        }
    }
}


public enum NearbyError:Error{
    case protocolError(_ message:String)
    case requiredFieldMissing(_ message:String)
    case ukey2
    case inputOutput
    case canceled(reason:CancellationReason)
    
    public enum CancellationReason{
        case userRejected, userCanceled, notEnoughSpace, unsupportedType, timedOut
    }
}

public struct TransferMetadata{
    public let files:[FileMetadata]
    public let id:String
    public let pinCode:String?
    public let textDescription:String?
    
    init(files: [FileMetadata], id: String, pinCode: String?, textDescription: String?=nil){
        self.files = files
        self.id = id
        self.pinCode = pinCode
        self.textDescription = textDescription
    }
}

public struct FileMetadata{
    public let name:String
    public let size:Int64
    public let mimeType:String
}

struct FoundServiceInfo{
    let service:NWBrowser.Result
    var device:RemoteDeviceInfo?
}

struct OutgoingTransferInfo{
    let service:NWBrowser.Result
    let device:RemoteDeviceInfo
    let connection:OutboundNearbyConnection
    let delegate:ShareExtensionDelegate
}

struct EndpointInfo{
    let name:String
    let deviceType:RemoteDeviceInfo.DeviceType
    
    init(name: String, deviceType: RemoteDeviceInfo.DeviceType){
        self.name = name
        self.deviceType = deviceType
    }
    
    init?(data:Data){
        guard data.count>17 else {return nil}
        let deviceNameLength=Int(data[17])
        guard data.count>=deviceNameLength+18 else {return nil}
        guard let deviceName=String(data: data[18..<(18+deviceNameLength)], encoding: .utf8) else {return nil}
        let rawDeviceType:Int=Int(data[0] & 7) >> 1
        self.name=deviceName
        self.deviceType=RemoteDeviceInfo.DeviceType.fromRawValue(value: rawDeviceType)
    }
    
    func serialize()->Data{
        var endpointInfo:[UInt8]=[UInt8(deviceType.rawValue << 1)]
        for _ in 0...15{
            endpointInfo.append(UInt8.random(in: 0...255))
        }
        var nameChars=[UInt8](name.utf8)
        if nameChars.count>255{
            nameChars=[UInt8](nameChars[0..<255])
        }
        endpointInfo.append(UInt8(nameChars.count))
        for ch in nameChars{
            endpointInfo.append(UInt8(ch))
        }
        return Data(endpointInfo)
    }
}

public protocol ShareExtensionDelegate:AnyObject{
    func addDevice(device:RemoteDeviceInfo)
    func removeDevice(id:String)
    func connectionWasEstablished(pinCode:String)
    func connectionFailed(with error:Error)
    func transferAccepted()
    func transferProgress(progress:Double)
    func transferFinished()
}

public protocol MainAppDelegate {
    func obtainUserConsent(for transfer: TransferMetadata, from device: RemoteDeviceInfo, fileURLs: [URL])
    func incomingTransfer(id: String, didUpdateProgress progress: Double)
    func incomingTransfer(id: String, didFinishWith error: Error?)
}

// A lightweight struct to decode only the settings we need.
fileprivate struct NeardropFrameworkSettings: Decodable {
    let neardropEnabled: Bool
    let neardropDeviceDisplayName: String
}

public class NearbyConnectionManager: NSObject, ObservableObject, NetServiceDelegate, InboundNearbyConnectionDelegate, OutboundNearbyConnectionDelegate {
    
    private var tcpListener: NWListener;
    public let endpointID: [UInt8] = generateEndpointID()
    private var mdnsService: NetService?
    private var activeConnections: [String: InboundNearbyConnection] = [:]
    private var foundServices: [String: FoundServiceInfo] = [:]
    private var shareExtensionDelegates: [ShareExtensionDelegate] = []
    private var outgoingTransfers: [String: OutgoingTransferInfo] = [:]
    public var mainAppDelegate: (any MainAppDelegate)?
    private var discoveryRefCount = 0
    private var browser: NWBrowser?
    
    @Published public var transfers: [TransferProgressInfo] = []
    @Published public var pendingTransfers: [String: TransferProgressInfo] = [:]
    private var cleanupTimers: [String: Timer] = [:]
    
    private let sharedDefaults: UserDefaults
    
    public static let shared = NearbyConnectionManager()
    
    override init() {
        let appGroupID = "group.com.shariq.sapphire.shared"
        self.sharedDefaults = UserDefaults(suiteName: appGroupID) ?? .standard
        tcpListener = try! NWListener(using: NWParameters(tls: .none))
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: sharedDefaults)
    }
    
    @objc private func userDefaultsDidChange() {
        DispatchQueue.main.async {
            self.updateServiceFromSettings()
        }
    }
    
    private func loadSettings() -> NeardropFrameworkSettings {
        if let data = sharedDefaults.data(forKey: "appSettings"),
           let settings = try? JSONDecoder().decode(NeardropFrameworkSettings.self, from: data) {
            return settings
        }
        return NeardropFrameworkSettings(neardropEnabled: true, neardropDeviceDisplayName: Host.current().localizedName ?? "My Mac")
    }
    
    public func becomeVisible() {
        print("[NCM] Attempting to become visible...")
        updateServiceFromSettings()
    }
    
    private func updateServiceFromSettings() {
        let settings = loadSettings()
        print("[NCM] Updating service based on settings. Neardrop Enabled: \(settings.neardropEnabled)")
        
        if settings.neardropEnabled {
            if tcpListener.port == nil {
                print("[NCM] TCP Listener not running. Starting now.")
                startTCPListener()
            }
        } else {
            if mdnsService != nil {
                print("[NCM] Neardrop is disabled. Stopping MDNS service.")
                mdnsService?.stop()
                mdnsService = nil
            }
        }
    }
    
    private func startTCPListener() {
        tcpListener.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .ready:
                if let port = self.tcpListener.port, port.rawValue > 0 {
                    print("[NCM] TCP Listener is ready on port \(port.rawValue). Initializing MDNS.")
                    self.initMDNS(on: port)
                } else {
                    print("❌ [NCM] TCP Listener is ready, but the port is invalid (0 or nil). Cannot start MDNS broadcast.")
                }
            case .failed(let error):
                print("❌ [NCM] TCP Listener failed to start: \(error.localizedDescription)")
                self.mdnsService?.stop()
                self.mdnsService = nil
            default:
                break
            }
        }
        
        tcpListener.newConnectionHandler = { [weak self] connection in
            let id = UUID().uuidString
            let conn = InboundNearbyConnection(connection: connection, id: id)
            self?.activeConnections[id] = conn
            conn.delegate = self
            conn.start()
        }
        
        tcpListener.start(queue: .global(qos: .utility))
    }
    
    private static func generateEndpointID() -> [UInt8] {
        var id: [UInt8] = []; let alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".compactMap { UInt8($0.asciiValue!) }
        for _ in 0...3 { id.append(alphabet[Int.random(in: 0..<alphabet.count)]) }
        return id
    }
    
    private func initMDNS(on port: NWEndpoint.Port) {
        print("[NCM] Initializing MDNS service...")
        let settings = loadSettings()
        let nameBytes: [UInt8] = [0x23] + endpointID + [0xFC, 0x9F, 0x5E, 0, 0]
        let name = Data(nameBytes).urlSafeBase64EncodedString()
        
        let rawDisplayName: String
        if settings.neardropDeviceDisplayName.isEmpty {
            rawDisplayName = Host.current().localizedName ?? "My Mac"
            print("[NCM] Custom name is empty, using system default: '\(rawDisplayName)'")
        } else {
            rawDisplayName = settings.neardropDeviceDisplayName
            print("[NCM] Using custom name from settings: '\(rawDisplayName)'")
        }
        
        let sanitizedNameData = rawDisplayName.data(using: .ascii, allowLossyConversion: true)
        let finalDisplayName = String(data: sanitizedNameData ?? Data(), encoding: .ascii) ?? "My Mac"
        print("[NCM] Sanitized final display name for broadcast: '\(finalDisplayName)'")
        
        let endpointInfo = EndpointInfo(name: finalDisplayName, deviceType: .computer)
        
        guard let servicePort = Int32(exactly: port.rawValue) else {
            print("❌ [NCM] Port value \(port.rawValue) is too large to be an Int32.")
            return
        }
        
        print("[NCM] Advertising service '\(name)' on port: \(servicePort) with device name '\(finalDisplayName)'")
        
        mdnsService = NetService(domain: "", type: "_FC9F5ED42C8A._tcp.", name: name, port: servicePort)
        mdnsService?.delegate = self
        mdnsService?.setTXTRecord(NetService.data(fromTXTRecord: ["n": endpointInfo.serialize().urlSafeBase64EncodedString().data(using: .utf8)!]))
        mdnsService?.publish()
    }
    
    // ... (rest of the file remains the same)
    
    func obtainUserConsent(for transfer: TransferMetadata, from device: RemoteDeviceInfo, fileURLs: [URL]) {
        let info = TransferProgressInfo(
            id: transfer.id,
            deviceName: device.name,
            fileDescription: fileDescription(for: transfer),
            direction: .incoming,
            iconName: iconName(for: transfer)
        )
        
        DispatchQueue.main.async {
            self.pendingTransfers[transfer.id] = info
        }
        
        mainAppDelegate?.obtainUserConsent(for: transfer, from: device, fileURLs: fileURLs)
    }

    func connection(_ connection: InboundNearbyConnection, didUpdateProgress progress: Double) {
        mainAppDelegate?.incomingTransfer(id: connection.id, didUpdateProgress: progress)
        DispatchQueue.main.async {
            if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                self.transfers[index].progress = progress
            }
        }
    }

    func connectionWasTerminated(connection: InboundNearbyConnection, error: Error?) {
        mainAppDelegate?.incomingTransfer(id: connection.id, didFinishWith: error)
        DispatchQueue.main.async {
            self.pendingTransfers.removeValue(forKey: connection.id)
            if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                if let error = error {
                    if case NearbyError.canceled(_) = error {
                        self.transfers[index].state = .canceled
                    } else {
                        self.transfers[index].state = .failed
                    }
                } else {
                    self.transfers[index].state = .finished
                }
                self.scheduleCleanup(for: connection.id)
            }
        }
        activeConnections.removeValue(forKey: connection.id)
    }
    
    public func submitUserConsent(transferID: String, accept: Bool, action: NearDropUserAction = .save) {
        activeConnections[transferID]?.submitUserConsent(accepted: accept, action: action)
        
        DispatchQueue.main.async {
            guard var info = self.pendingTransfers.removeValue(forKey: transferID) else {
                return
            }
            
            if accept {
                info.state = .inProgress
                self.transfers.insert(info, at: 0)
            }
        }
    }

    public func cancelIncomingTransfer(id: String) {
        if let connection = activeConnections[id] {
            connection.disconnect()
        }
    }
    
    public func startDeviceDiscovery() {
        if discoveryRefCount == 0 {
            foundServices.removeAll()
            browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_FC9F5ED42C8A._tcp.", domain: nil), using: .tcp)
            browser?.browseResultsChangedHandler = { _, changes in for change in changes { switch change { case let .added(res): self.maybeAddFoundDevice(service: res); case let .removed(res): self.maybeRemoveFoundDevice(service: res); default: break } } }
            browser?.start(queue: .main)
        }
        discoveryRefCount += 1
    }
    
    public func stopDeviceDiscovery() {
        discoveryRefCount -= 1; assert(discoveryRefCount >= 0)
        if discoveryRefCount == 0 { browser?.cancel(); browser = nil }
    }
    
    public func addShareExtensionDelegate(_ delegate: ShareExtensionDelegate) {
        shareExtensionDelegates.append(delegate)
        for service in foundServices.values { if let device = service.device { delegate.addDevice(device: device) } }
    }
    
    public func removeShareExtensionDelegate(_ delegate: ShareExtensionDelegate) { shareExtensionDelegates.removeAll { $0 === delegate } }
    public func cancelOutgoingTransfer(id: String) {
        outgoingTransfers[id]?.connection.cancel()
    }
    
    private func endpointID(for service: NWBrowser.Result) -> String? {
        guard case let .service(name: serviceName, _, _, _) = service.endpoint, let nameData = Data.dataFromUrlSafeBase64(serviceName), nameData.count >= 10,
              nameData[0] == 0x23, nameData.subdata(in: 5..<8) == Data([0xFC, 0x9F, 0x5E]) else { return nil }
        return String(data: nameData.subdata(in: 1..<5), encoding: .ascii)
    }
    
    private func maybeAddFoundDevice(service: NWBrowser.Result) {
        if service.interfaces.contains(where: { $0.type == .loopback }) { return }
        guard let endpointID = endpointID(for: service) else { return }
        var foundService = FoundServiceInfo(service: service)
        guard case let .bonjour(txtRecord) = service.metadata, let infoEncoded = txtRecord.dictionary["n"], let infoData = Data.dataFromUrlSafeBase64(infoEncoded), infoData.count >= 19 else { return }
        let nameLength = Int(infoData[17]); guard infoData.count >= nameLength + 18, let name = String(data: infoData.subdata(in: 18..<(18 + nameLength)), encoding: .utf8) else { return }
        let type = RemoteDeviceInfo.DeviceType.fromRawValue(value: (Int(infoData[0]) >> 1) & 7)
        let deviceInfo = RemoteDeviceInfo(name: name, type: type, id: endpointID)
        foundService.device = deviceInfo; foundServices[endpointID] = foundService
        for delegate in shareExtensionDelegates { delegate.addDevice(device: deviceInfo) }
    }
    
    private func maybeRemoveFoundDevice(service: NWBrowser.Result) {
        guard let endpointID = endpointID(for: service), foundServices.removeValue(forKey: endpointID) != nil else { return }
        for delegate in shareExtensionDelegates { delegate.removeDevice(id: endpointID) }
    }
    
    public func startOutgoingTransfer(deviceID: String, delegate: ShareExtensionDelegate, urls: [URL]) {
        guard let info = foundServices[deviceID] else { return }
        let tcp = NWProtocolTCP.Options(); tcp.noDelay = true
        let nwconn = NWConnection(to: info.service.endpoint, using: NWParameters(tls: .none, tcp: tcp))
        let conn = OutboundNearbyConnection(connection: nwconn, id: deviceID, urlsToSend: urls)
        conn.delegate = self
        outgoingTransfers[deviceID] = OutgoingTransferInfo(service: info.service, device: info.device!, connection: conn, delegate: delegate)
        
        let transferInfo = TransferProgressInfo(
            id: deviceID,
            deviceName: info.device!.name,
            fileDescription: urls.count == 1 ? urls[0].lastPathComponent : "\(urls.count) files",
            direction: .outgoing,
            iconName: "arrow.up.doc"
        )
        DispatchQueue.main.async {
            self.transfers.insert(transferInfo, at: 0)
        }
        
        conn.start()
    }
    
    func outboundConnectionWasEstablished(connection: OutboundNearbyConnection) {
        if let transfer = outgoingTransfers[connection.id] {
            DispatchQueue.main.async { transfer.delegate.connectionWasEstablished(pinCode: connection.pinCode!) }
        }
    }
    
    func outboundConnectionTransferAccepted(connection: OutboundNearbyConnection) {
        if let transfer = outgoingTransfers[connection.id] {
            DispatchQueue.main.async {
                transfer.delegate.transferAccepted()
                if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                    self.transfers[index].state = .inProgress
                }
            }
        }
    }
    
    func outboundConnection(connection: OutboundNearbyConnection, transferProgress: Double) {
        if let transfer = outgoingTransfers[connection.id] {
            DispatchQueue.main.async {
                transfer.delegate.transferProgress(progress: transferProgress)
                if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                    self.transfers[index].progress = transferProgress
                }
            }
        }
    }
    
    func outboundConnection(connection: OutboundNearbyConnection, failedWithError: Error) {
        if let transfer = outgoingTransfers.removeValue(forKey: connection.id) {
            DispatchQueue.main.async {
                transfer.delegate.connectionFailed(with: failedWithError)
                if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                    self.transfers[index].state = .failed
                    self.scheduleCleanup(for: connection.id)
                }
            }
        }
    }
    
    func outboundConnectionTransferFinished(connection: OutboundNearbyConnection) {
        if let transfer = outgoingTransfers.removeValue(forKey: connection.id) {
            DispatchQueue.main.async {
                transfer.delegate.transferFinished()
                if let index = self.transfers.firstIndex(where: { $0.id == connection.id }) {
                    self.transfers[index].state = .finished
                    self.scheduleCleanup(for: connection.id)
                }
            }
        }
    }
    
    // MARK: - Helpers & Delegate Methods
    
    public func netServiceDidPublish(_ sender: NetService) {
        print("✅ [NCM - NetService] Successfully published service: \(sender.name) on port \(sender.port)")
    }

    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("❌ [NCM - NetService] FAILED to publish service: \(sender.name). Error: \(errorDict)")
    }
    
    private func scheduleCleanup(for transferID: String) {
        cleanupTimers[transferID]?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.transfers.removeAll { $0.id == transferID }
                self.cleanupTimers.removeValue(forKey: transferID)
            }
        }
        cleanupTimers[transferID] = timer
    }

    private func fileDescription(for transfer: TransferMetadata) -> String {
        if let text = transfer.textDescription { return text }
        if transfer.files.count == 1 { return transfer.files[0].name }
        return "\(transfer.files.count) files"
    }
    
    private func iconName(for transfer: TransferMetadata) -> String {
        if let desc = transfer.textDescription {
             if let _ = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue).firstMatch(in: desc, options: [], range: NSRange(location: 0, length: desc.utf16.count)) {
                return "link"
            }
            return "text.quote"
        }
        guard let firstFile = transfer.files.first else { return "questionmark" }
        if transfer.files.count > 1 { return "doc.on.doc.fill" }
        
        let mimeType = firstFile.mimeType.lowercased()
        if mimeType.starts(with: "image/") { return "photo" }
        if mimeType.starts(with: "video/") { return "video.fill" }
        if mimeType.starts(with: "audio/") { return "music.note" }
        if mimeType.contains("pdf") { return "doc.richtext.fill" }
        if mimeType.contains("zip") || mimeType.contains("archive") { return "archivebox.fill" }
        
        return "doc.fill"
    }
}
