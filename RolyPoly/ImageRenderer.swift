//
//  ImageRenderer.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa
import CoreImage

class ImageRenderer: NSObject {
    var gridSize = NSMakeSize(16, 9) {
        didSet {
            requiresRendering = true
        }
    }

    var inputImage: NSImage? {
        didSet {
            requiresRendering = true
        }
    }
    private (set) var outputImage: NSImage?
    private let filteringGroup = dispatch_group_create()
    private var requiresRendering = true

    func render(completion: (outputImage: NSImage?) -> Void) {
        if !requiresRendering {
            completion(outputImage: outputImage)
            return
        }

        guard let inputImage = inputImage else {
            completion(outputImage: nil)
            return
        }

        let availableFilters = CIFilter.filterNamesInCategory(kCICategoryBuiltIn)
        let filteredFilters = availableFilters.filter(){ return $0 == "CIAreaAverage"}

        guard filteredFilters.count > 0 else {
            completion(outputImage: nil)
            return
        }

        guard let tiffRepresentation = inputImage.TIFFRepresentation else {
            completion(outputImage: nil)
            return
        }

        guard let ciImage = CIImage(data: tiffRepresentation) else {
            completion(outputImage: nil)
            return
        }


        let kernelWidth = Int(ciImage.extent.width / gridSize.width)
        let kernelHeight = Int(ciImage.extent.height / gridSize.height)

        guard let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(ciImage.extent.width), pixelsHigh: Int(ciImage.extent.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bitmapFormat: NSBitmapFormat.NSAlphaFirstBitmapFormat, bytesPerRow: 0, bitsPerPixel: 0) else {
            completion(outputImage: nil)
            return
        }

        guard let nsGraphicscontext = NSGraphicsContext(bitmapImageRep: bitmapImageRep) else {
            completion(outputImage: nil)
            return
        }

        nsGraphicscontext.saveGraphicsState()
        NSGraphicsContext.setCurrentContext(nsGraphicscontext)

        let context = nsGraphicscontext.CGContext


        let drawRectangle = {(vector: CIVector, image: CIImage?) -> Void in

            guard let image = image else {
                return
            }
            let rect = CGRectMake(vector.X, vector.Y, vector.Z, vector.W)
            let rep = NSCIImageRep(CIImage: image)

            let nsImage = NSImage(size: rep.size)
            nsImage.addRepresentation(rep)

            let color = NSColor(patternImage: nsImage)
            color.setFill()
            CGContextFillRect(context, rect)
        }

        let group = dispatch_group_create()
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] () -> Void in
            guard let sself = self else {
                return
            }
            autoreleasepool {
                for y in 0...Int(sself.gridSize.height - 1) {
                    for x in 0...Int(sself.gridSize.width - 1) {
                        dispatch_group_async(group, dispatch_get_global_queue(0, 0), { () -> Void in
                            let vector = CIVector(CGRect: CGRectMake(CGFloat(x * kernelWidth), CGFloat(y * kernelHeight), CGFloat(kernelWidth), CGFloat(kernelHeight)))
                            if let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey : ciImage, kCIInputExtentKey : vector]) {
                                dispatch_group_async(group, dispatch_get_main_queue(), { () -> Void in
                                    drawRectangle(vector, filter.outputImage)
                                })
                            }
                        })

                    }
                }
            }

            dispatch_group_notify(group, dispatch_get_main_queue()) {[weak self] () -> Void in
                let outImage = NSImage(size: bitmapImageRep.size)
                outImage.addRepresentation(bitmapImageRep)

                completion(outputImage: outImage)
                self?.outputImage = outImage
                self?.requiresRendering = false
            }
        }



    }
}
