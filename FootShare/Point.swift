//
//  Point.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 18/03/2024.
//

import SwiftData
import Foundation

@Model
class Point {
    var date: Date
    var participation: Participation?
    
    init(date: Date) {
        self.date = date
    }
    
    func secondsSindsGameStart() -> Double {
        return date.timeIntervalSinceReferenceDate - (participation?.game?.date.timeIntervalSinceReferenceDate ?? date.timeIntervalSinceReferenceDate)
    }
}
