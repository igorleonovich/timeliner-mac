//
//  StatusItemManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Cocoa

class StatusItemManager {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    // MARK: - Setup
    
    func setupMenuIcon() {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.flowViewTemplateName)
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
    }
    
    func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [weak self] event in
            guard let `self` = self else { return }
            if self.popover.isShown {
                self.closePopover(event)
            }
       }
       eventMonitor?.start()
    }
    
    // MARK: - UI Actions
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

private extension StatusItemManager {
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}
