//
//  RootView.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa

class RootView: NSView {

    @IBOutlet weak var imageWell: NSImageView!
    @IBOutlet weak var gridView: GridView!

    var gridColor = NSColor.redColor() {
        didSet {
            gridView.gridColor = gridColor
        }
    }

    var gridSize = NSMakeSize(10, 5.62) {
        didSet {
            gridView.gridSize = gridSize
        }
    }
    
}
