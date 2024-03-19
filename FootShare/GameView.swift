//
//  GameView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameView: View {
//    @Environment(\.modelContext) var modelContext
    @Bindable var game: Game
    
    var body: some View {

        HStack {
            Spacer()
            VStack {
                Text("\(game.participations.home.team.name)").font(.headline)
                Text("\(game.participations.home.score)").font(.largeTitle)
            }
            Spacer()
            VStack {
                Text(game.participations.out.team.name).font(.headline)
                Text("\(game.participations.out.score)").font(.largeTitle)
            }
            Spacer()
        }.padding(.horizontal)
            .navigationTitle("\(game.participations.home.team.name) - \(game.participations.out.team.name)")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    let context = container.mainContext
    
    let games = makeFakeData()
    games.forEach({data in container.mainContext.insert(data)})
//    let games = makeFakeData()
//    debugPrint("\(games.first!.participations.count)")

    
        return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
    
}
