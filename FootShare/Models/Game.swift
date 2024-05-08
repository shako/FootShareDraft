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
    var createdAt: Date = Date.now
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
        var participations = self.participations.map { participation in
            var newParticipation = Participation.init(isHomeTeam: participation.isHomeTeam, points: [Point]())
            modelContext.insert(newParticipation)
            newParticipation.team = participation.team
            return newParticipation
        }
        var game = Game.init(date: self.date, participations: [], clock: Clock.init())
        modelContext.insert(game)
        game.participations = participations
        return game
    }
    
}

extension Array where Element : Game {
    
    var firstToLast: [Game] {
        self.sorted(by: { gamel, gamer in
            gamel.createdAt < gamer.createdAt
        })
    }
    
    var lastToFirst: [Game] {
        firstToLast.reversed()
    }
    
}
