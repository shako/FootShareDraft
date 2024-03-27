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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        HStack {
                            VStack {
                                Text(game.participations.home.team.name)
                                    .font(.title2)
                                Text("\(game.homeTeamScore)")
                            }

                            Spacer()
                            VStack {
                                Text(game.participations.out.team.name)
                                    .font(.title2)
                                Text("\(game.outTeamScore)")
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
                    makeFakeData().forEach({data in modelContext.container.mainContext.insert(data)})
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
    
    let point1 = Point(date: .now)
    let goalsWesterlo = [point1, Point(date: .now), Point(date: .now), Point(date: .now), Point(date: .now)]
    let goalsGeel = [Point(date: .now)]

    
    participationWesterlo = Participation(team: teamWesterlo, isHomeTeam: true, points: goalsWesterlo)
//    point1.participation = participationWesterlo
    
    let participationGeel = Participation(team: teamGeel, isHomeTeam: false, points: goalsGeel)
    
    let participations = [participationWesterlo, participationGeel]
    
    let game = Game(date: .now, participations: participations)
    return [game]
}

