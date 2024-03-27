//
//  Participation.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 16/03/2024.
//

import SwiftData
import Foundation

@Model
class Participation {
    var team: Team
    var isHomeTeam: Bool
    @Relationship(inverse: \Point.participation) var points: [Point]
    
    init(team: Team, isHomeTeam: Bool, points: [Point]) {
        self.team = team
        self.isHomeTeam = isHomeTeam
        self.points = points
    }
    
    var score : Int {
        points.count
    }
}

extension Array where Element : Participation {
    var home: Participation {
        return self.filter({participation in participation.isHomeTeam}).first!
    }
    
    var out: Participation {
        return self.filter({participation in !participation.isHomeTeam}).first!
    }
}
