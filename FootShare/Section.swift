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
    var score: Int
    
    init(score: Int) {
        self.score = score
    }
}
