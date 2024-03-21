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

        VStack {
            
        }
        ZStack() {

            HStack {
                Image("soccer-field")
//                    .scaledToFill()
//                    .scaledToFit()
                    .scaleEffect(CGSize(width: 0.6, height: 1.0))
            }
            
            HStack(spacing: 0) {
                
                VStack {
                    Text("\(game.participations.home.team.name)").font(.largeTitle)
                    VStack {
                        Text("\(game.participations.home.score)").font(.system(size: 100))
                    }
//                    .foregroundStyle(.white)
                    
                    Button(action: {addPoint(participation: game.participations.home)}, label: {

                        Image(systemName: "soccerball.inverse")
                            .font(.system(size: CGFloat(50)))
                    })
                }
                .foregroundStyle(.white)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.regularMaterial)
                
                VStack {
                    Text("\(game.participations.out.team.name)").font(.largeTitle)
                    VStack {
                        Text("\(game.participations.out.score)").font(.system(size: 100))
                    }
//                    .foregroundStyle(.white)
                    
                    Button(action: {addPoint(participation: game.participations.out)}, label: {
                        Image(systemName: "soccerball.inverse")
                            .font(.system(size: CGFloat(50)))
                    })
                }
                .foregroundStyle(.white)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.blue.opacity(0.5))
                
                
            }
        
            
            
            VStack() {
                Text("\(game.date.formatted(date: .abbreviated, time: .omitted))")
                Spacer()
            }
            

            
        }
            .navigationTitle("\(game.participations.home.team.name) - \(game.participations.out.team.name)")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func addPoint(participation: Participation) {
//        
//        debugPrint(participation.sections.count)
//        debugPrint(participation.sections.last?.points.count ?? 0)
        participation.sections.last?.points.append(Point(date: .now))
        game.date = game.date
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
