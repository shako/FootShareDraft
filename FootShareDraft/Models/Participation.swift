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
    var team: Team?
    var isHomeTeam: Bool
    @Relationship(deleteRule: .cascade, inverse: \Point.participation) var points: [Point]
    var game: Game?
    
    init(isHomeTeam: Bool, points: [Point]) {
        self.isHomeTeam = isHomeTeam
        self.points = points
    }
    
    var score : Int {
        points.count
    }
}

extension Array where Element : Participation {
    var home: Participation? {
        return self.filter({participation in participation.isHomeTeam}).first
    }
    
    var out: Participation? {
        return self.filter({participation in !participation.isHomeTeam}).first
    }
}

extension Array where Element: Participation {
    func homeFirst() -> [Participation] {
        self.sorted(by: { participationl, participationr in
            participationl.isHomeTeam == true
        })
    }
    
    var teamsSelected: Bool {
        self.filter {participation in
            participation.team == nil
        }.count == 0
    }
    
}

extension Participation {
    static var emptyParticipation: Participation {
        Participation(isHomeTeam: false, points: [])
    }
}
