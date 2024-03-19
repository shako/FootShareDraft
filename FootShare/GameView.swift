//
//  GameView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameView: View {
    @Bindable var game: Game
    
    var body: some View {

        HStack {
            Spacer()
            Button(action: {addPoint(participation: game.participations.home)}, label: {
                VStack {
                    Text("\(game.participations.home.team.name)").font(.headline)
                    Text("\(game.participations.home.score)").font(.largeTitle)
                }
            })
            

            Spacer()
            Button(action: {addPoint(participation: game.participations.out)}, label: {
                VStack {
                    Text("\(game.participations.out.team.name)").font(.headline)
                    Text("\(game.participations.out.score)").font(.largeTitle)
                }
            })
            Spacer()
        }.padding(.horizontal)
            .navigationTitle("\(game.participations.home.team.name) - \(game.participations.out.team.name)")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func addPoint(participation: Participation) {
//        
//        debugPrint(participation.sections.count)
//        debugPrint(participation.sections.last?.points.count ?? 0)
        participation.sections.last?.points.append(Point(date: .now))
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
