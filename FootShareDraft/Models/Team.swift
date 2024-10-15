//
//  Team.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI
import Foundation

@Model
class Team {
    
    var name: String
    var isYourTeam: Bool
    @Attribute(.transformable(by: UIColorValueTransformer.self)) var color: UIColor = UIColor(Color.gray.opacity(0.6))
    @Relationship(deleteRule: .cascade, inverse: \Participation.team) var participations: [Participation] = []
    
    init(name: String, isYourTeam: Bool, color: UIColor? = UIColor(Color.blue), participations: [Participation]? = [Participation]()) {
        self.name = name
        self.isYourTeam = isYourTeam
        self.color = color!
        self.participations = participations!
    }
}

extension Team {
    static var emptyTeam: Team {
        Team(name: "", isYourTeam: false)
    }

    func copy() -> Team {
        return Team(name: self.name, isYourTeam: self.isYourTeam, color: self.color)
    }
    
    func updateDetailsFrom(other: Team) {
        self.name = other.name
        self.color = other.color
        self.isYourTeam = other.isYourTeam
    }
}
