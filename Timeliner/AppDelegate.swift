//
//  AppDelegate.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/2/19.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItemManager = StatusItemManager()
    let recordingManager = RecordingManager()
    let processingManager = ProcessingManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItemManager.setupMenuIcon()
        
        let mainViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainViewController") as! MainViewController
        mainViewController.recordingManager = recordingManager
        recordingManager.processingManager = processingManager
        
        statusItemManager.popover.contentViewController = mainViewController
        
        statusItemManager.setupEventMonitor()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
}
