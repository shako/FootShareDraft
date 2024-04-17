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

