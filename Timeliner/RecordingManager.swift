//
//  RecordingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation
import RealmSwift
import AVFoundation

enum RecordingState {
    case idle
    case recording
}

class RecordingManager {
    
    var screenRecorder: ScreenRecorder
    var processingManager: ProcessingManager!
    var state = RecordingState.idle
    let currentFileURL = URL(fileURLWithPath: "current.mp4")
    var currentFileCreatedDate = Date()
    var splitterTimer: Timer?
    
    init() {
        do {
            screenRecorder = try ScreenRecorder.init(destination: currentFileURL, framesPerSecond: 24, cropRect: nil, showCursor: true, highlightClicks: false)
        } catch {
            fatalError("Cannot initialize Aperture")
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func startRecording() {
        state = .recording
        screenRecorder.start()
        currentFileCreatedDate = Date()
        if splitterTimer == nil {
            splitterTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                guard let `self` = self else { return }
                self.stopRecording()
                self.setupScreenRecorder()
                self.startRecording()
            }
        }
    }
    
    func stopRecording() {
        state = .idle
        screenRecorder.stop()
        
        let fileManager = FileManager.default
        
        let realm = try! Realm()
        let screenRecord = ScreenRecord()
        screenRecord.created = currentFileCreatedDate
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
            try fileManager.moveItem(at: currentFileURL, to: URL(fileURLWithPath: "\(dateFormatter.string(from: currentFileCreatedDate)).mp4"))
        } catch {
            print("Can't rename current file")
        }
        
        try! realm.write {
            realm.add(screenRecord)
        }
        processingManager.process()
    }
}

private extension RecordingManager {
    
    // TODO: Remove the duplication
    func setupScreenRecorder() {
        do {
            screenRecorder = try ScreenRecorder.init(destination: currentFileURL, framesPerSecond: 24, cropRect: nil, showCursor: true, highlightClicks: false)
        } catch {
            fatalError("Cannot initialize Aperture")
        }
    }
}
