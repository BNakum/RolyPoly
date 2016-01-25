//
//  AppDelegate.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }


}

