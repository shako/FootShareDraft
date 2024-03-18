//
//  Team.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import Foundation

@Model
class Team {
    var name: String
    var isYourTeam: Bool
    
    init(name: String, isYourTeam: Bool) {
        self.name = name
        self.isYourTeam = isYourTeam
    }
}
