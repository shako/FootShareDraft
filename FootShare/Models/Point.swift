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

extension Point {
    
    func madeDuring(_ session: Session) -> Bool {
        var madeDuringSession =  self.date >= session.startTime && (session.endTime != nil ? self.date <= session.endTime! : true)
        debugPrint("point with date \(date.formatted()) made during session with startdate \(session.startTime.formatted()) and enddate \(session.endTime?.formatted() ?? "NONE")? -> \(madeDuringSession)")
        return madeDuringSession
    }
    
}

extension Array where Element : Point {
    
    func madeDuring(_ session: Session) -> [Point] {
        self.filter {$0.madeDuring(session)}
    }
    
}
