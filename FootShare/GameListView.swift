//
//  ContentView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameListView: View {
    @Query(sort: \Game.date, order: .reverse) var games: [Game]
    @Environment(\.modelContext) var modelContext
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        GameEntry(game: game, cloneGameFunction: {cloneGame(game: game)})
                    }
                }
                .onDelete(perform: deleteGames)
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Game.self) { game in
                GameView(game: game)//game: game
            }
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    EditButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    newGameButton
                }

            }
                
        }

    }

    
    func cloneGame(game: Game) {
        withAnimation {
            modelContext.insert(game.clone(modelContext: modelContext))
            try? modelContext.save()
        }

    }
    
    func deleteGames(at offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                let game = games[offset]
                modelContext.delete(game)
            }
        }
    }
    
    @MainActor
    var newGameButton: some View {
        Button {
            let participationHomeTeam = Participation(isHomeTeam: true, points: [])
            let participationOutTeam = Participation(isHomeTeam: false, points: [])
            let game = Game(date: .now, participations: [], clock: Clock())
            modelContext.container.mainContext.insert(game)
            modelContext.container.mainContext.insert(participationHomeTeam)
            modelContext.container.mainContext.insert(participationOutTeam)
            participationHomeTeam.game = game
            participationOutTeam.game = game
            path.append(game)
        } label: {
            Image(systemName: "plus")
        }
    }
    
}

struct GameEntry: View {
    
    var game: Game
    var cloneGameFunction: () -> Void
    
    var body: some View {
        GameListEntryView(participations: game.participations)
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button(action: {cloneGameFunction()}, label: {
                    HStack {
                        Image(systemName: "arrow.circlepath")
                            .resizable()
                            .scaledToFill()
                        Text("Play Again")
                    }.font(.title)
                    
                })
                .tint(.blue)
            }
    }
    
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    makeFakeData(container: container).forEach({data in container.mainContext.insert(data)})
    return GameListView().modelContainer(container)

}

