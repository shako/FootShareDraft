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
    @Transient var currentSession: Session?
    
    init() {
        var latestSession = sessions.firstToLast.last
        debugPrint("initializing clock")
//        if (latestSession?.isPlaying == true) {
            currentSession = latestSession
        let _ = debugPrint("got a latestsession? \(latestSession != nil)")
//        }
    }
}

extension Clock {
    
    func start() {
        currentSession = Session(startTime: Date.now)
        self.sessions.append(currentSession!)
        self.status = .playing(since: currentSession!.startTime)
    }
    
    func startBreak() {
        guard let session = currentSession else {
            fatalError("Found no session to end")
//            return
        }
        let breakStart = Date.now
        session.endTime = breakStart
        self.status = .in_break(since: breakStart)
    }
    
    func resume(modelContext: ModelContext) {
        currentSession = Session(startTime: Date.now)
        modelContext.insert(currentSession!)
        self.sessions.append(currentSession!)
        self.status = .playing(since: currentSession!.startTime)
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
