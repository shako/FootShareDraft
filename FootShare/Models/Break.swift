//
//  Break.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/04/2024.
//

import Foundation
import SwiftData

@Model
class Break {
    var startTime: Date
    var endTime: Date?
    
    init(startTime: Date, endTime: Date? = nil) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
}

extension Break {
    
    var ongoing: Bool {
        return self.endTime == nil
    }
    
}

extension Array where Element : Break {
    
    func chronological() -> [Break] {
        self.sorted(by: { break_entryl, break_entryr in
            break_entryl.startTime < break_entryr.startTime
        })
    }
    
}
