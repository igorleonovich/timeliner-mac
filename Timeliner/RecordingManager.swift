//
//  RecordingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation
import Aperture

enum RecordingState {
    case idle
    case recording
}

class RecordingManager {
    
    var state = RecordingState.idle
    var aperture: Aperture
    
    init() {
        do {
            let fileURL = URL(fileURLWithPath: "rec.mp4")
            aperture = try Aperture.init(destination: fileURL, framesPerSecond: 24, cropRect: nil, showCursor: true, highlightClicks: false)
        } catch {
            fatalError("Cannot initialize Aperture")
        }
    }
    
    func startRecording() {
        state = .recording
        aperture.start()
    }
    
    func stopRecording() {
        state = .idle
        aperture.stop()
    }
}
