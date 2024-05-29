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
    
    let pointsWesterloSesssion2 = [Point(date: gameStartDate + 3)]
    let pointsWesterloSesssionOngoing = [Point(date: gameStartDate + 1000), Point(date: gameStartDate + 10), Point(date: gameStartDate + 59), Point(date: gameStartDate + 60), Point(date: gameStartDate + 61), Point(date: gameStartDate + 300)]
    pointsWesterloSesssion2.forEach { goal in
        container.mainContext.insert(goal)
    }
    pointsWesterloSesssionOngoing.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    let goalsGeelSessionOngoing = [Point(date: gameStartDate + 200)]
    goalsGeelSessionOngoing.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    participationWesterlo = Participation(isHomeTeam: true, points: [])
    container.mainContext.insert(participationWesterlo)
    if assignTeams {
        participationWesterlo.team = teamWesterlo
        participationWesterlo.points = Array([pointsWesterloSesssion2, pointsWesterloSesssionOngoing].joined())
    }
    
    let participationGeel = Participation(isHomeTeam: false, points: [])
    container.mainContext.insert(participationGeel)
    if assignTeams {
        participationGeel.team = teamGeel
        participationGeel.points = goalsGeelSessionOngoing
    }
    
    let participations = [participationWesterlo, participationGeel]

    let sessionClosed1 = Session(startTime: gameStartDate + 1, endTime: gameStartDate + 2)
    sessionClosed1.creationDate = Date.now
    container.mainContext.insert(sessionClosed1)
    let sessionClosed2 = Session(startTime: gameStartDate + 2, endTime: gameStartDate + 5)
    sessionClosed2.creationDate = sessionClosed1.creationDate + 1
    container.mainContext.insert(sessionClosed2)
    let sessionOngoing = Session(startTime: gameStartDate + 5)
    sessionOngoing.creationDate = sessionClosed2.creationDate + 1
    container.mainContext.insert(sessionOngoing)
    
    sessionClosed2.points.append(contentsOf: pointsWesterloSesssion2)
    sessionOngoing.points.append(contentsOf: pointsWesterloSesssionOngoing)
    sessionOngoing.points.append(contentsOf: goalsGeelSessionOngoing)
    
    let clock = Clock()
    clock.status = .playing(since: gameStartDate + 10)
    container.mainContext.insert(clock)
    
    clock.sessions.append(sessionClosed1)
    clock.sessions.append(sessionClosed2)
    clock.sessions.append(sessionOngoing)
    
    let game = Game(date: gameStartDate, participations: [], clock: Clock())
    container.mainContext.insert(game)
    
    game.participations = participations
    
    if assignTeams {
        game.clock = clock
    }

    
    return [game]
}
