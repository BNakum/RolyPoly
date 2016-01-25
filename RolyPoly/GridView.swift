//
//  GridView.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa

class GridView: NSView {

    override var opaque: Bool {
        return false
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func layout() {
        super.layout()

        setNeedsDisplayInRect(bounds)
    }

    var gridColor = NSColor.redColor() {
        didSet {
            setNeedsDisplayInRect(window?.frame ?? CGRectZero)
        }
    }

    var gridSize = NSMakeSize(16, 9) {
        didSet {
            setNeedsDisplayInRect(window?.frame ?? CGRectZero)
        }
    }


    override func drawRect(dirtyRect: NSRect) {

        guard let context = NSGraphicsContext.currentContext()?.CGContext else {
            return
        }

        CGContextSetStrokeColorWithColor(context, NSColor.redColor().CGColor)
        CGContextSetLineWidth(context, 1.0)

        let imageBounds: CGRect = NSRectToCGRect(self.bounds)
        let xIncrement = imageBounds.size.width / gridSize.width
        let yIncrement = imageBounds.size.height / gridSize.height

        let drawLine = {(from: CGPoint, to: CGPoint) -> Void in
            CGContextMoveToPoint(context, from.x, from.y)
            CGContextAddLineToPoint(context, to.x, to.y)
            CGContextStrokePath(context)
        }

        // Draw the vertical lines
        for line in 0...Int(gridSize.width) {
            let x = imageBounds.origin.x + (CGFloat(line) * xIncrement)
            drawLine(CGPointMake(x, imageBounds.origin.y), CGPointMake(x, imageBounds.origin.y + imageBounds.size.height))
        }

        // Draw the horizontal lines
        for line in 0...Int(gridSize.height) {
            let y = imageBounds.origin.y + (CGFloat(line) * yIncrement)
            drawLine(CGPointMake(imageBounds.origin.x, y), CGPointMake(imageBounds.origin.x + imageBounds.size.width, y))
        }
        
    }
    
}
