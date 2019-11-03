//
//  ScreenRecord.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation
import RealmSwift

class ScreenRecord: Object {
    @objc dynamic var created = Date()
    @objc dynamic var processed = false
}
