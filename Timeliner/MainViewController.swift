//
//  MainViewController.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/2/19.
//

import Cocoa

class MainViewController: NSViewController {

    var recordingManager: RecordingManager!
    
    @IBOutlet weak var recButton: NSButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        updateRecButtonTitle()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - UI Actions

    @IBAction func recButtonAction(_ sender: Any) {
        switch recordingManager.state {
        case .idle:
            recordingManager.startRecording()
        case .recording:
            recordingManager.stopRecording()
        }
        updateRecButtonTitle()
    }
    
    @IBAction func closeButtonAction(_ sender: NSButton) {
        NSApp.terminate(self)
    }
    
    // MARK: - Helpers
    
    private func updateRecButtonTitle() {
        switch recordingManager.state {
        case .idle:
            recButton.title = "Rec"
        case .recording:
            recButton.title = "Stop"
        }
    }
}
