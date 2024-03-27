//
//  GameView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var game: Game
    
    
    var body: some View {

        var gridColumns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        VStack {
//            Text().foregroundStyle(.black)
            HStack {
                LazyVGrid(columns: gridColumns, alignment: .center) {
                    VStack {
                        Text("\(game.participations.home.team.name)").font(.largeTitle).foregroundStyle(.blue)
                        VStack {
                            Text("\(game.participations.home.score)").font(.system(size: 100))
                        }
                        Button(action: {addPoint(participation: game.participations.home)}, label: {

                            Image(systemName: "soccerball.inverse")
                                .font(.system(size: CGFloat(50))).foregroundStyle(.blue)
                        })
                    }
//                    .border(.red)
                    VStack {
                        Text("\(game.participations.out.team.name)").font(.largeTitle).foregroundStyle(.yellow)
                        VStack {
                            Text("\(game.participations.out.score)").font(.system(size: 100))
                        }
                        Button(action: {addPoint(participation: game.participations.out)}, label: {
                            Image(systemName: "soccerball.inverse")
                                .font(.system(size: CGFloat(50))).foregroundStyle(.yellow)
                        })
                    }
//                    .border(.red)
                }
            }
    //        debugPrint("\(game.participations.first!.sections.count)")
                List {
                    ForEach(pointsSorted(), id: \.id) { point in
                        Text("\(point.date.formatted(date: .omitted, time: .shortened)) - \(point.participation?.team.name ?? "unknown")")
                    }.onDelete(perform: removePoint)
                        
                }.foregroundStyle(.black).border(.black)
                
        } .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
    }
    
    func addPoint(participation: Participation) {
//        
//        debugPrint(participation.sections.count)
//        debugPrint(participation.sections.last?.points.count ?? 0)
        participation.points.append(Point(date: .now))
        refreshScore()
    }
    
    func refreshScore() {
        game.date = game.date
    }
    
    func removePoint(indexSet: IndexSet) {

        for index in indexSet {
            let point = pointsSorted()[index]
            modelContext.delete(point)
            refreshScore()
        }

    }
    
    func pointsSorted() -> [Point] {
        game.points.sorted(by: { pointl, pointr in
            pointl.date > pointr.date
        })
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
