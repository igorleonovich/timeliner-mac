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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItemManager.setupMenuIcon()
        
        let mainViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainViewController") as! MainViewController
        
        statusItemManager.popover.contentViewController = mainViewController
        
        statusItemManager.setupEventMonitor()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
}
