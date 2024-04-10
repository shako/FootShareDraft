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

@MainActor func makeFakeData(container: ModelContainer) -> [Game] {
    let teamWesterlo = Team(name: "Westerlo", isYourTeam: true)
    let teamGeel = Team(name: "Geel", isYourTeam: false)
    container.mainContext.insert(teamWesterlo)
    container.mainContext.insert(teamGeel)
    
    var participationWesterlo: Participation
    

    let goalsWesterlo = [Point(date: .now + 1000), Point(date: .now + 10), Point(date: .now + 20), Point(date: .now + 60), Point(date: .now + 61)]
    goalsWesterlo.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    let goalsGeel = [Point(date: .now + 200)]
    goalsGeel.forEach { goal in
        container.mainContext.insert(goal)
    }
    
    participationWesterlo = Participation(isHomeTeam: true, points: [])
    container.mainContext.insert(participationWesterlo)
    participationWesterlo.team = teamWesterlo
    participationWesterlo.points = goalsWesterlo
    
    let participationGeel = Participation(isHomeTeam: false, points: [])
    container.mainContext.insert(participationGeel)
    participationGeel.team = teamGeel
    participationGeel.points = goalsGeel
    
    let participations = [participationWesterlo, participationGeel]
    
    let game = Game(date: .now, participations: [])
    container.mainContext.insert(game)
    game.participations = participations
    
    return [game]
}

func makeFakeDataWithoutTeams() -> [Game] {
    
    var participationWesterlo = Participation(isHomeTeam: true, points: [])
    let participationGeel = Participation(isHomeTeam: false, points: [])
    
    let participations = [participationWesterlo, participationGeel]
    
    let game = Game(date: .now, participations: participations)
    return [game]
}

