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
    
    var startTime: Date?
    var endTime: Date?
    @Relationship(deleteRule: .cascade) var breaks: [Break] = []
    var status: Status
    
    
    init(startTime: Date? = nil, endTime: Date? = nil, breaks: [Break] = []) {
        self.startTime = startTime
        self.endTime = endTime
        self.breaks = breaks
        self.status = Status.not_started
    }
    
}

extension Clock {
    
    func start() {
        self.startTime = Date.now
        self.status = .playing(since: self.startTime!)
    }
    
    func startBreak(newBreak: Break) {
        breaks.append(newBreak)
        self.status = .in_break(since: newBreak.startTime)
    }
    
    func resume() {
        breaks.chronological().last?.endTime = Date.now
        self.status = .playing(since: breaks.chronological().last?.endTime ?? .now)
    }
    
    func end() {
        self.endTime = Date.now
        self.status = .ended
    }
    
    var runningSince: Date? {
        switch status {
        case .playing(since: let since):
            return since
        case .in_break(since: let since):
            return since
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
    
    func calculateStatus() -> Status {
        if startTime == nil {
            return Status.not_started
        }
        if endTime != nil {
            return Status.ended
        }
        let lastBreak = breaks.chronological().last
        if lastBreak != nil && lastBreak!.ongoing == true  {
            debugPrint("state machine says we're in break!")
            return Status.in_break(since: lastBreak!.startTime)
        } else {
            return Status.playing(since: (lastBreak?.endTime ?? startTime!))
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
