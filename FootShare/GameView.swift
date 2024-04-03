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
    
    @State private var showingSelectTeam = false
    @State private var selectedTeam: Team? = Team.emptyTeam
    @State private var selectedParticipation : Participation = Participation.emptyParticipation

    var body: some View {

        let gridColumns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        VStack {
//            Text().foregroundStyle(.black)
            HStack {
                LazyVGrid(columns: gridColumns, alignment: .center) {
                    ForEach($game.participations, id: \.id) { $participation in
                        if participation.team != nil {
                            VStack {
                                Text("\(participation.team?.name ?? "")").font(.largeTitle).foregroundStyle(.blue)
                                VStack {
                                    Text("\(participation.score)").font(.system(size: 100))
                                }
                                Button(action: {addPoint(participation: participation)}, label: {
                                    Image(systemName: "soccerball.inverse")
                                        .font(.system(size: CGFloat(50))).foregroundStyle(.blue)
                                })
                            }
                        } else {
                            VStack {
                                Button("Select team") {
                                    selectedParticipation = participation
                                    selectedTeam = nil
                                    showingSelectTeam = true
                                }

                            }
                        
                        }
                    }
                }
            }
            List {
                ForEach(pointsSorted(), id: \.id) { point in
                    HighlightListView(point: point, gameStart: game.date)
                }.onDelete(perform: removePoint)
                    
            }.foregroundStyle(.black).border(.black)
                
        } .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
        .sheet(isPresented: $showingSelectTeam) {
            NavigationStack {
                SelectTeamView(selectedTeam: $selectedTeam)
                    .navigationTitle("Choose Team")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Select") {
                                selectedParticipation.team = selectedTeam
                                showingSelectTeam = false
                            }
//                            .disabled(selectedTeam == nil)
                        }
                
                    }
            }
            
        }
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

#Preview("Two Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    let context = container.mainContext
    
    let games = makeFakeData()
    games.forEach({data in container.mainContext.insert(data)})

        return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

#Preview("No Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    let context = container.mainContext
    
    let games = makeFakeData()
    games.forEach({data in container.mainContext.insert(data)})
    
    games.forEach { game in
        debugPrint("game: \(game.id.id)")
        debugPrint("number of participations: \(game.participations.count)")
        game.participations.forEach { participation in
            participation.team = nil
            participation.points = []
        }
    }
    


    return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

struct HighlightListView: View {
    let point: Point
    let gameStart: Date
    
    var body: some View {
        Text("\(point.secondsSindsGameStart()) - \(point.participation?.team?.name ?? "unknown")")
    }
    
}
