//
//  Section.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import Foundation

@Model
class Section {
    @Relationship(inverse: \Point.section) var points: [Point]
    var participation: Participation?
    
    init(points: [Point]) {
        self.points = points
    }
    
    var score: Int {
        return points.count
    }
}
