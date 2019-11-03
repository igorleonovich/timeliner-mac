//
//  RecordingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation

enum RecordingState {
    case idle
    case recording
}

class RecordingManager {
    
    var state = RecordingState.idle
    
    func startRecording() {
        state = .recording
    }
    
    func stopRecording() {
        state = .idle
    }
}
