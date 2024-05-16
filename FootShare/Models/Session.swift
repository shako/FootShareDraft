//
//  Session.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/04/2024.
//

import Foundation
import SwiftData

@Model
class Session {
    var startTime: Date
    var endTime: Date?
    @Relationship(deleteRule: .cascade, inverse: \Point.session) var points: [Point]
    
    init(startTime: Date, endTime: Date? = nil, points: [Point] = [Point]()) {
        self.startTime = startTime
        self.endTime = endTime
        self.points = points
    }
    
    var isPlaying: Bool {
        return endTime == nil
    }
}

extension Array where Element : Session {
    
    var firstToLast: [Session] {
        debugPrint("\(Date.now.formatted(date: .complete, time: .complete)) Reading all sessions - firstToLast")
        return self.sorted(by: { sessionl, sessionr in
            sessionl.startTime < sessionr.startTime
        })
    }
    
    var lastToFirst: [Session] {
        debugPrint("\(Date.now.formatted(date: .complete, time: .complete)) Reading all sessions - lastToFirst")
        return firstToLast.reversed()
    }
    
    func playTimeUpTo(date: Date) -> Double {
        let sessions = self.filter({session in session.startTime <= date})
        let timeInSessions = sessions.reduce(0) {$0 + ($1.hasEnded && date < $1.endTime! ? $1.length : (date - $1.startTime) ) }
        return timeInSessions
    }
    
    var past: [Session] {
        self.filter { session in session.endTime != nil }
    }
    
    var ongoing: Session? {
        if let lastSession = self.firstToLast.last, lastSession.endTime == nil {
            debugPrint("Found last session with starttime \(lastSession.startTime.formatted()) and endtime \(lastSession.endTime?.formatted() ?? "NONE")")
            return lastSession
        } else {
            debugPrint("Didn't find a last session")
            return nil
        }
    }
    
    var closed: [Session] {
        return self.filter{ $0.hasEnded }
    }
    
}

extension Session {
    
    var hasEnded: Bool {
        return self.endTime != nil
    }
    
    var length: TimeInterval {
        return (self.endTime ?? Date.now) - self.startTime
    }
    
    var participations: [Participation] {
        return Array(Set(self.points.filter { point in
            point.participation != nil
        }
        .map { point in
            point.participation!
        }))
    }
    
    var duration: TimeInterval {
        (self.endTime ?? Date.now) - self.startTime
    }
    
}
