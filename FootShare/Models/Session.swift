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
    
    init(startTime: Date, endTime: Date? = nil) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
}

extension Array where Element : Session {
    
    var firstToLast: [Session] {
        self.sorted(by: { sessionl, sessionr in
            sessionl.startTime < sessionr.startTime
        })
    }
    
    var lastToFirst: [Session] {
        firstToLast.reversed()
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
        if let lastSession = self.last, lastSession.endTime == nil {
            return self.last!
        } else {
            return nil
        }
    }
    
}

extension Session {
    
    var hasEnded: Bool {
        return self.endTime != nil
    }
    
    var length: TimeInterval {
        return (self.endTime ?? Date.now) - self.startTime
    }
    
}
