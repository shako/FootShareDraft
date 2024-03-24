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
    var participations: [Participation]
    var dummyScore: Int = 0
    
    init(date: Date, participations: [Participation]) {
        self.date = date
        self.participations = participations
    }
    
    var homeTeamScore: Int {
        participations.filter({participation in participation.isHomeTeam}).first!.score
    }
    
    var outTeamScore: Int {
        participations.filter({participation in !participation.isHomeTeam}).first!.score
    }

    var points: [Point] {
        participations.flatMap { participation in
            participation.sections.flatMap { section in
                section.points
            }
        }
    }
    
}
