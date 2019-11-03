//
//  RecordingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation
import Aperture
import RealmSwift

enum RecordingState {
    case idle
    case recording
}

class RecordingManager {
    
    var state = RecordingState.idle
    var aperture: Aperture
    var splitterTimer: Timer?
    let currentFileURL = URL(fileURLWithPath: "current.mp4")
    var currentFileCreatedDate = Date()
    
    init() {
        do {
            aperture = try Aperture.init(destination: currentFileURL, framesPerSecond: 24, cropRect: nil, showCursor: true, highlightClicks: false)
        } catch {
            fatalError("Cannot initialize Aperture")
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func startRecording() {
        state = .recording
        aperture.start()
        if splitterTimer == nil {
            splitterTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                guard let `self` = self else { return }
                self.stopRecording()
                self.setupAperture()
                self.startRecording()
            }
        }
        currentFileCreatedDate = Date()
    }
    
    func stopRecording() {
        state = .idle
        aperture.stop()
        
        let fileManager = FileManager.default
        
        let realm = try! Realm()
        let screenRecord = ScreenRecord()
        
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
    }
}

private extension RecordingManager {
    
    // TODO: Remove the duplication
    func setupAperture() {
        do {
            aperture = try Aperture.init(destination: currentFileURL, framesPerSecond: 24, cropRect: nil, showCursor: true, highlightClicks: false)
        } catch {
            fatalError("Cannot initialize Aperture")
        }
    }
}
