//
//  AppController.swift
//  RolyPoly
//
//  Created by Harshad on 22/01/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Cocoa

class AppController: NSObject, SettingsControllerDelegate {

    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var rootView: RootView!
    @IBOutlet weak var saveItem: NSMenuItem!
    @IBOutlet var settingsController: SettingsController!

    private var gridSize = NSMakeSize(16 * 3, 9 * 3) {
        didSet {
            rootView.gridSize = gridSize
            renderer.gridSize = gridSize
        }
    }

    private let renderer = ImageRenderer()

    private var inputImage: NSImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        renderer.inputImage = rootView.imageWell.image
        renderer.gridSize = self.gridSize
        settingsController.delegate = self
        guard let image = rootView.imageWell.image else {
            return
        }
        mainWindow.aspectRatio = NSMakeSize(image.size.width / image.size.height, 1.0)
        mainWindow.setFrame(NSMakeRect(mainWindow.frame.origin.x, mainWindow.frame.origin.y, (image.size.width) * 400 / (image.size.height + 20), 400), display: true)
    }

    @IBAction func clickGridSize(sender: AnyObject) {
        mainWindow.beginSheet(settingsController.window, completionHandler: nil)
    }

    @IBAction func clickGridColor(sender: AnyObject) {

    }

    @IBAction func imageChanged(sender: AnyObject) {
        renderer.inputImage = rootView.imageWell.image
        guard let image = rootView.imageWell.image else {
            return
        }
        mainWindow.aspectRatio = NSMakeSize(image.size.width / (image.size.height + 20), 1.0)
//        let frameOrigin = NSMakePoint(0, (NSScreen.mainScreen()?.frame.size.height ?? 0) + 20)
        mainWindow.setFrame(NSMakeRect(mainWindow.frame.origin.x, mainWindow.frame.origin.y, (image.size.width) * 400 / (image.size.height + 20), 400), display: true)
    }

    @IBAction func clickInput(sender: AnyObject) {
        rootView.imageWell.image = renderer.inputImage
        rootView.gridView.hidden = false
    }

    @IBAction func clickOutput(sender: AnyObject) {

        renderer.render { (outputImage) -> Void in
            guard let outputImage = outputImage else {
                return
            }
            self.rootView.imageWell.image = outputImage
            self.rootView.gridView.hidden = true
            self.saveItem.enabled = true
        }
    }

    @IBAction func clickSave(sender: AnyObject) {
        guard let bitmapRep = renderer.outputImage?.representations.first as? NSBitmapImageRep else {
            return
        }
        guard let downloadsDir: NSString = NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true).first else {
            return
        }
        var fileName = "rolypoly"
        let fileManager = NSFileManager.defaultManager()
        var path = downloadsDir.stringByAppendingPathComponent(fileName + ".png")
        var index = 1
        while fileManager.fileExistsAtPath(path) {
            fileName += String(stringInterpolationSegment: index) + ".png"
            path = downloadsDir.stringByAppendingPathComponent(fileName)
            ++index
        }

        let data = bitmapRep.representationUsingType(.NSPNGFileType, properties: [:])
        data?.writeToFile(path, atomically: true)

    }

    func settingsController(controller: SettingsController, didSaveGridSize gridSize: NSSize) {
        self.gridSize = gridSize
        mainWindow.endSheet(controller.window)
    }

    func settingsControllerDidCancel(controller: SettingsController) {
        mainWindow.endSheet(controller.window)
    }
}
