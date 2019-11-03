//
//  StatusItemManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Cocoa

class StatusItemManager {
    
    var eventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    
    // MARK: - Setup
    
    func setupMenuIcon() {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.flowViewTemplateName)
            button.action = #selector(toggle(_:))
        }
    }
    
    func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [weak self] event in
            guard let `self` = self else { return }
            if self.popover.isShown {
                self.close(event)
            }
        }
        eventMonitor?.start()
    }
    
    // MARK: - Actions
    
    @objc func toggle(_ sender: AnyObject?) {
        if popover.isShown {
            close(sender)
        } else {
            show(sender)
        }
    }
}

private extension StatusItemManager {
    
    func show(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    func close(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}
