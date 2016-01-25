//
//  SettingsController.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa

protocol SettingsControllerDelegate: NSObjectProtocol {
    func settingsController(controller: SettingsController, didSaveGridSize gridSize: NSSize) -> Void
    func settingsControllerDidCancel(controller: SettingsController)
}

class SettingsController: NSObject {

    @IBOutlet var window: NSWindow!
    @IBOutlet weak var horizontalField: NSTextField!
    @IBOutlet weak var verticalField: NSTextField!

    weak var delegate: SettingsControllerDelegate?

    @IBAction func clickSave(sender: AnyObject) {
        guard let horizontal = Int(horizontalField.stringValue), let vertical = Int(verticalField.stringValue) else {
            delegate?.settingsControllerDidCancel(self)
            return
        }
        guard horizontal >= 2 && vertical >= 2 else {
            delegate?.settingsControllerDidCancel(self)
            return
        }
        delegate?.settingsController(self, didSaveGridSize: NSMakeSize(CGFloat(horizontal), CGFloat(vertical)))
    }

    @IBAction func clickCancel(sender: AnyObject) {
        delegate?.settingsControllerDidCancel(self)
    }
}
