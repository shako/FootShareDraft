//
//  Game.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import Foundation

@Model
class Game {
    var date: Date
    @Relationship(deleteRule: .cascade) var clock: Clock
    @Relationship(deleteRule: .cascade, inverse: \Participation.game)  var participations: [Participation]
    
    init(date: Date, participations: [Participation], clock: Clock) {
        self.date = date
        self.participations = participations
        self.clock = clock
    }

    var points: [Point] {
        return participations.flatMap { participation in
            participation.points
        }.sorted(by: { p1, p2 in
            return p1.date > p2.date
        })
    }
    
}

extension Game {
    
    func clone(modelContext: ModelContext) -> Game {
        debugPrint("cloning game with \(self.participations.count) participations")
        let participations = self.participations.map { participation in
            let newParticipation = Participation.init(isHomeTeam: participation.isHomeTeam, points: [Point]())
            modelContext.insert(newParticipation)
            newParticipation.team = participation.team
            return newParticipation
        }
        let game = Game.init(date: Date.now, participations: [], clock: Clock.init())
        modelContext.insert(game)
        game.participations = participations
        return game
    }
    
    var readyToStart: Bool {
        return participations.teamsSelected
    }
    
    var isOngoing: Bool {
        if let lastSession = clock.lastSession, !clock.hasEnded {
            return true
        } else {
            return false
        }
    }
    
}
