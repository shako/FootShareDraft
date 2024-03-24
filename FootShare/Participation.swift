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
    @Relationship(inverse: \Section.participation) var sections: [Section]
    
    init(team: Team, isHomeTeam: Bool, sections: [Section]) {
        self.team = team
        self.isHomeTeam = isHomeTeam
        self.sections = sections
    }
    
    var score : Int {
        sections.map({$0.score}).reduce(0, +)
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
