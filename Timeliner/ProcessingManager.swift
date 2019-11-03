//
//  ProcessingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation
import RealmSwift

class ProcessingManager {
    
    func process() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "processed == false")
        let unprocessedRecords = realm.objects(ScreenRecord.self).filter(predicate)
        unprocessedRecords.forEach { screenRecord in
            
        }
    }
}
