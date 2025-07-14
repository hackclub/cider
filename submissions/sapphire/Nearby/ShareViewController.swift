//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Grishka on 12.09.2023.
//

import Foundation
import Cocoa
import NearbyShare
import QuickLookThumbnailing // <-- IMPORT ADDED

class ShareViewController: NSViewController, ShareExtensionDelegate {
    
    private var urls: [URL] = []
    private var foundDevices: [RemoteDeviceInfo] = []
    private var chosenDevice: RemoteDeviceInfo?
    private var lastError: Error?
    
    @IBOutlet var filesIcon: NSImageView?
    @IBOutlet var filesLabel: NSTextField?
    @IBOutlet var loadingOverlay: NSStackView?
    @IBOutlet var largeProgress: NSProgressIndicator?
    @IBOutlet var listView: NSCollectionView?
    @IBOutlet var listViewWrapper: NSView?
    @IBOutlet var contentWrap: NSView?
    @IBOutlet var progressView: NSView?
    @IBOutlet var progressDeviceIcon: NSImageView?
    @IBOutlet var progressDeviceName: NSTextField?
    @IBOutlet var progressProgressBar: NSProgressIndicator?
    @IBOutlet var progressState: NSTextField?
    @IBOutlet var progressDeviceIconWrap: NSView?
    @IBOutlet var progressDeviceSecondaryIcon: NSImageView?
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()
    
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            for attachment in attachments as NSArray {
                let provider = attachment as! NSItemProvider
                // Use public.url and public.file-url for broader compatibility
                let typeURL = "public.url"
                let typeFileURL = "public.file-url"

                provider.loadItem(forTypeIdentifier: typeURL, options: nil) { data, err in
                    self.handleAttachment(data: data, error: err, total: attachments.count)
                }
                provider.loadItem(forTypeIdentifier: typeFileURL, options: nil) { data, err in
                    self.handleAttachment(data: data, error: err, total: attachments.count)
                }
            }
        } else {
            cancelRequest()
            return
        }
        
        contentWrap!.addSubview(listViewWrapper!)
        contentWrap!.addSubview(loadingOverlay!)
        contentWrap!.addSubview(progressView!)
        progressView!.isHidden = true
        
        listViewWrapper!.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay!.translatesAutoresizingMaskIntoConstraints = false
        progressView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listViewWrapper!.widthAnchor.constraint(equalTo: contentWrap!.widthAnchor),
            listViewWrapper!.heightAnchor.constraint(equalTo: contentWrap!.heightAnchor),
            loadingOverlay!.widthAnchor.constraint(equalTo: contentWrap!.widthAnchor),
            loadingOverlay!.centerYAnchor.constraint(equalTo: contentWrap!.centerYAnchor),
            progressView!.widthAnchor.constraint(equalTo: contentWrap!.widthAnchor),
            progressView!.centerYAnchor.constraint(equalTo: contentWrap!.centerYAnchor)
        ])
        
        largeProgress!.startAnimation(nil)
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 75, height: 90)
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        listView!.collectionViewLayout = flowLayout
        listView!.dataSource = self
        
        progressDeviceIconWrap!.wantsLayer = true
        progressDeviceIconWrap!.layer!.masksToBounds = false
    }
    
    private func handleAttachment(data: NSSecureCoding?, error: Error?, total: Int) {
        if let url = data as? URL {
            DispatchQueue.main.async {
                if !self.urls.contains(url) {
                    self.urls.append(url)
                    if self.urls.count == total {
                        self.urlsReady()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NearbyConnectionManager.shared.startDeviceDiscovery()
        NearbyConnectionManager.shared.addShareExtensionDelegate(self)
    }
    
    override func viewWillDisappear() {
        if chosenDevice == nil {
            NearbyConnectionManager.shared.stopDeviceDiscovery()
        }
        NearbyConnectionManager.shared.removeShareExtensionDelegate(self)
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        if let device = chosenDevice {
            NearbyConnectionManager.shared.cancelOutgoingTransfer(id: device.id!)
        }
        cancelRequest()
    }
    
    private func cancelRequest() {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
    
    private func urlsReady() {
        for url in urls {
            if url.isFileURL {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    cancelRequest()
                    return
                }
            }
        }
        
        if urls.count == 1 {
            let url = urls[0]
            if url.isFileURL {
                filesLabel!.stringValue = url.lastPathComponent
                generateThumbnail(for: url) { [weak self] image in
                    self?.filesIcon?.image = image ?? NSWorkspace.shared.icon(forFile: url.path)
                }
            } else if ["http", "https"].contains(url.scheme) {
                filesLabel!.stringValue = url.absoluteString
                filesIcon!.image = NSImage(named: NSImage.networkName)
            }
        } else {
            filesLabel!.stringValue = String.localizedStringWithFormat(NSLocalizedString("NFiles", value: "%d files", comment: ""), urls.count)
            filesIcon!.image = NSImage(named: NSImage.multipleDocumentsName)
        }
    }
    
    /// Generates a thumbnail for a given file URL.
    private func generateThumbnail(for url: URL, completion: @escaping (NSImage?) -> Void) {
        let size = CGSize(width: 128, height: 128)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: view.window?.backingScaleFactor ?? 2.0, representationTypes: .all)
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            DispatchQueue.main.async {
                completion(thumbnail?.nsImage)
            }
        }
    }
    
    func addDevice(device: RemoteDeviceInfo) {
        if foundDevices.isEmpty { loadingOverlay?.animator().isHidden = true }
        foundDevices.append(device)
        listView?.animator().insertItems(at: [[0, foundDevices.count - 1]])
    }
    
    func removeDevice(id: String) {
        if chosenDevice != nil { return }
        if let i = foundDevices.firstIndex(where: { $0.id == id }) {
            foundDevices.remove(at: i)
            listView?.animator().deleteItems(at: [[0, i]])
        }
        if foundDevices.isEmpty { loadingOverlay?.animator().isHidden = false }
    }
    
    func connectionWasEstablished(pinCode: String) {
        progressState?.stringValue = String(format:NSLocalizedString("PinCode", value: "PIN: %@", comment: ""), arguments: [pinCode])
        progressProgressBar?.isIndeterminate = false
        progressProgressBar?.maxValue = 1000
        progressProgressBar?.doubleValue = 0
    }
    
    func connectionFailed(with error: Error) {
        progressProgressBar?.isIndeterminate = false; progressProgressBar?.maxValue = 1000; progressProgressBar?.doubleValue = 0
        lastError = error
        if let ne = (error as? NearbyError), case let .canceled(reason) = ne {
            switch reason {
            case .userRejected: progressState?.stringValue = NSLocalizedString("TransferDeclined", value: "Declined", comment: "")
            case .userCanceled: progressState?.stringValue = NSLocalizedString("TransferCanceled", value: "Canceled", comment: "")
            case .notEnoughSpace: progressState?.stringValue = NSLocalizedString("NotEnoughSpace", value: "Not enough disk space", comment: "")
            case .unsupportedType: progressState?.stringValue = NSLocalizedString("UnsupportedType", value: "Attachment type not supported", comment: "")
            case .timedOut: progressState?.stringValue = NSLocalizedString("TransferTimedOut", value: "Timed out", comment: "")
            }
            progressDeviceSecondaryIcon?.isHidden = false
            dismissDelayed()
        } else {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: view.window!) { _ in self.extensionContext!.cancelRequest(withError: error) }
        }
    }
    
    func transferAccepted() { progressState?.stringValue = NSLocalizedString("Sending", value: "Sending...", comment: "") }
    func transferProgress(progress: Double) { progressProgressBar!.doubleValue = progress * progressProgressBar!.maxValue }
    
    func transferFinished() {
        progressState?.stringValue = NSLocalizedString("TransferFinished", value: "Transfer finished", comment: "")
        dismissDelayed()
    }
    
    func selectDevice(device: RemoteDeviceInfo) {
        NearbyConnectionManager.shared.stopDeviceDiscovery()
        listViewWrapper?.animator().isHidden = true
        progressView?.animator().isHidden = false
        progressDeviceName?.stringValue = device.name
        progressDeviceIcon?.image = imageForDeviceType(type: device.type)
        progressProgressBar?.startAnimation(nil)
        progressState?.stringValue = NSLocalizedString("Connecting", value: "Connecting...", comment: "")
        chosenDevice = device
        NearbyConnectionManager.shared.startOutgoingTransfer(deviceID: device.id!, delegate: self, urls: urls)
    }
    
    private func dismissDelayed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let error = self.lastError { self.extensionContext!.cancelRequest(withError: error) }
            else { self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil) }
        }
    }
}

fileprivate func imageForDeviceType(type: RemoteDeviceInfo.DeviceType) -> NSImage {
    let imageName: String
    switch type {
    case .tablet: imageName = "com.apple.ipad"
    case .computer: imageName = "com.apple.macbookpro-13-unibody"
    default: imageName = "com.apple.iphone"
    }
    return NSImage(contentsOfFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/\(imageName).icns")!
}

extension ShareViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int { return 1 }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { return foundDevices.count }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeviceListCell"), for: indexPath)
        guard let collectionViewItem = item as? DeviceListCell else { return item }
        let device = foundDevices[indexPath.item]
        collectionViewItem.textField?.stringValue = device.name
        collectionViewItem.imageView?.image = imageForDeviceType(type: device.type)
        collectionViewItem.clickHandler = { self.selectDevice(device: device) }
        return collectionViewItem
    }
}
