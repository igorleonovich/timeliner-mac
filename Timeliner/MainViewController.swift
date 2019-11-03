//
//  MainViewController.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/2/19.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func closeButtonAction(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}
