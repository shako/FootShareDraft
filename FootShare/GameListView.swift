//
//  ContentView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameListView: View {
    @Query var games: [Game]
    @Environment(\.modelContext) var modelContext
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        ForEach(game.participations) {participation in
                            VStack() {
                                Text(participation.team?.name ?? "")
                                    .font(.title2)
                                Text("\(participation.score)")
                            }.frame(maxWidth: .infinity)
                        }
                    }
                }
                .onDelete(perform: deleteGames)
                
            }
            .navigationTitle("Games")
            .navigationDestination(for: Game.self) { game in
                GameView(game: game)//game: game
            }
            .toolbar {
                Button("Add") {
                    let participationHomeTeam = Participation(isHomeTeam: true, points: [])
                    let participationOutTeam = Participation(isHomeTeam: false, points: [])
                    let game = Game(date: .now, participations: [])
                    modelContext.container.mainContext.insert(game)
                    modelContext.container.mainContext.insert(participationHomeTeam)
                    modelContext.container.mainContext.insert(participationOutTeam)
                    participationHomeTeam.game = game
                    participationOutTeam.game = game
                    path.append(game)
                }
            }
                
        }

    }
    
    func deleteGames(at offsets: IndexSet) {
        for offset in offsets {
            let game = games[offset]
            modelContext.delete(game)
        }
    }
    
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    makeFakeData(container: container).forEach({data in container.mainContext.insert(data)})
    return GameListView().modelContainer(container)

}

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
    
    let game = Game(date: gameStartDate, participations: [])
    container.mainContext.insert(game)
    game.participations = participations
    
    return [game]
}

