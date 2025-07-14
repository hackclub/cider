//
//  DeviceListCell.swift
//  ShareExtension
//
//  Created by Grishka on 20.09.2023.
//

import Cocoa

class DeviceListCell: NSCollectionViewItem {
    public var clickHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let btn = view as? NSButton {
            btn.isEnabled = true
            btn.setButtonType(.momentaryPushIn)
            btn.action = #selector(onClick)
            btn.target = self
        }
    }
    
    @IBAction func onClick(_ sender: Any?) {
        clickHandler?()
    }
}
