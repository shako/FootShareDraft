//
//  Clock.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 16/04/2024.
//

import SwiftData
import Foundation

@Model
class Clock {
    
    @Relationship(deleteRule: .cascade) var sessions: [Session] = []
    var status: Status = Status.not_started
    var isEnded: Bool = false

    init() {
        
    }
}

extension Clock {
    
    func start() {
        let session = Session(startTime: Date.now)
        self.sessions.append(session)
        self.status = .playing(since: session.startTime)
    }
    
    func startBreak() {
        let breakStart = Date.now
        sessions.last?.endTime = breakStart
        self.status = .in_break(since: breakStart)
    }
    
    func resume(newSession : Session) {
        self.sessions.append(newSession)
        self.status = .playing(since: newSession.startTime)
    }
    
    func end() {
        self.status = .ended
    }

    var isRunning: Bool {
        if case .playing = status {
            return true
        } else {
            return false
        }
    }
    
    var sessionNumber : Int? {
        if isRunning {
            return sessions.count
        } else {
            return nil
        }
    }
    
    var breakNumber : Int? {
        if inBreak {
            return sessions.count
        } else {
            return nil
        }
    }
    
    var runningSince: Date? {
        switch status {
        case .playing(since: let since):
            return since
        case .in_break:
            return nil
        default:
            return nil
        }
    }
    
    var value: TimeInterval? {
        switch status {
            case .playing(since: let since):
                return Date.now - since
        case .in_break(since: _):
                return TimeInterval(integerLiteral: 0)
            case .not_started:
                return TimeInterval(integerLiteral: 0)
            default:
                return nil
        }
    }
    
    var hasEnded : Bool {
        if case .ended = status {
            return true
        } else {
            return false
        }
    }
    
    var inBreak : Bool {
        if case .in_break = status {
            return true
        } else {
            return false
        }
    }
    
}

enum Status: Codable {
    case not_started
    case playing(since: Date)
    case in_break(since: Date)
    case ended
}

@MainActor func makeFakeClockData(container: ModelContainer) -> [Clock] {
    return [Clock()]
}
