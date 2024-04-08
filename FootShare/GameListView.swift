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
                            VStack {
                                Text(participation.team?.name ?? "")
                                    .font(.title2)
                                Text("\(participation.score)")
                            }
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
                    let game = Game(date: .now, participations: [Participation(isHomeTeam: true, points: []), Participation(isHomeTeam: false, points: [])])
                    modelContext.container.mainContext.insert(game)
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
    makeFakeData().forEach({data in container.mainContext.insert(data)})
    return GameListView().modelContainer(container)

}

func makeFakeData() -> [Game] {
    let teamWesterlo = Team(name: "Westerlo", isYourTeam: true)
    let teamGeel = Team(name: "Geel", isYourTeam: false)
    
    var participationWesterlo: Participation
    
    let point1 = Point(date: .now + 1000)
    let goalsWesterlo = [point1, Point(date: .now + 10), Point(date: .now + 20), Point(date: .now + 60), Point(date: .now + 61)]
    let goalsGeel = [Point(date: .now + 200)]

    
    participationWesterlo = Participation(isHomeTeam: true, points: goalsWesterlo)
    participationWesterlo.team = teamWesterlo
    
    let participationGeel = Participation(isHomeTeam: false, points: goalsGeel)
    participationGeel.team = teamGeel
    
    let participations = [participationWesterlo, participationGeel]
    
    let game = Game(date: .now, participations: participations)
    return [game]
}

func makeFakeDataWithoutTeams() -> [Game] {
    
    var participationWesterlo = Participation(isHomeTeam: true, points: [])
    let participationGeel = Participation(isHomeTeam: false, points: [])
    
    let participations = [participationWesterlo, participationGeel]
    
    let game = Game(date: .now, participations: participations)
    return [game]
}

