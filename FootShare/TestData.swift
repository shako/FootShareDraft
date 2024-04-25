//
//  TestData.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 25/04/2024.
//

import UIKit
import SwiftData
import SwiftUI
import Foundation

@MainActor func makeFakeData(container: ModelContainer, assignTeams: Bool = true) -> [Game] {
    let gameStartDate = Date.now - 1500
    
    let teamWesterlo = Team(name: "KVC Westerlo U9", isYourTeam: true)
    let teamGeel = Team(name: "Het heultje of iets met lange naam", isYourTeam: false)
//    teamGeel.colorHex = 15253504
    teamWesterlo.color = UIColor(Color.yellow)
    teamGeel.color = UIColor.blue
    container.mainContext.insert(teamWesterlo)
    container.mainContext.insert(teamGeel)
    
    var participationWesterlo: Participation
    
    let goalsWesterlo = [Point(date: gameStartDate + 1000), Point(date: gameStartDate + 10), Point(date: gameStartDate + 59), Point(date: gameStartDate + 60), Point(date: gameStartDate + 61), Point(date: gameStartDate + 300)]
    goalsWesterlo.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    let goalsGeel = [Point(date: gameStartDate + 200)]
    goalsGeel.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    participationWesterlo = Participation(isHomeTeam: true, points: [])
    container.mainContext.insert(participationWesterlo)
    if assignTeams {
        participationWesterlo.team = teamWesterlo
        participationWesterlo.points = goalsWesterlo
    }
    
    let participationGeel = Participation(isHomeTeam: false, points: [])
    container.mainContext.insert(participationGeel)
    if assignTeams {
        participationGeel.team = teamGeel
        participationGeel.points = goalsGeel
    }
    
    
    let participations = [participationWesterlo, participationGeel]
    
    let session = Session(startTime: gameStartDate + 5)
    container.mainContext.insert(session)
    
    let clock = Clock()
    clock.status = .playing(since: gameStartDate + 10)
    container.mainContext.insert(clock)
    
    clock.sessions.append(session)
    
    let game = Game(date: gameStartDate, participations: [], clock: Clock())
    container.mainContext.insert(game)
    
    game.participations = participations
    
    if assignTeams {
        game.clock = clock
    }

    
    return [game]
}
