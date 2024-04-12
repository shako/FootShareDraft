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
//    var colorHex: Int?
    @Attribute(.transformable(by: UIColorValueTransformer.self)) var color: UIColor = UIColor(Color.gray.opacity(0.6))
    @Relationship(deleteRule: .cascade, inverse: \Participation.team) var participations: [Participation] = []
    
    init(name: String, isYourTeam: Bool) {
        self.name = name
        self.isYourTeam = isYourTeam
    }
}

extension Team {
    static var emptyTeam: Team {
        Team(name: "", isYourTeam: false)
    }
}
