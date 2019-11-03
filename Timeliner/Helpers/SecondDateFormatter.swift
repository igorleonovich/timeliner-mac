
//
//  SecondDateFormatter.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Foundation

class SecondDateFormatter: DateFormatter {
    override init() {
        super.init()
        dateFormat = "yyyy-MM-dd HH-mm-ss"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
