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
    @State private var participationToSelectTeamFor : Participation = Participation.emptyParticipation

    var body: some View {

        let gridColumns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        VStack {
            HStack() {
                Group {
                    ForEach(game.participations, id: \.id) { participation in
                        if participation.team != nil {
                            VStack {
                                Text("\(participation.team?.name ?? "")").font(.largeTitle).foregroundStyle(.blue)

                                Button(action: {addPoint(participation: participation)}, label: {
                                    VStack {
                                        VStack {
                                            Text("\(participation.score)").font(.system(size: 100))
                                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                        
//                                        Image(systemName: "soccerball.inverse")
//                                            .font(.system(size: CGFloat(50))).foregroundStyle(.blue)
                                    }

                                })
                            }
                        } else {
                            VStack {
                                Button {
                                    participationToSelectTeamFor = participation
                                    selectedTeam = nil
                                    showingSelectTeam = true
                                } label: {
                                    Text("Select Team")
                                        .font(.largeTitle)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                
                            }
                            
                        }
                    }.padding().frame(maxWidth: .infinity, maxHeight: 200).background(.gray.opacity(0.3))
                    //                }
                }
            }
            List {
                if pointsSorted().isEmpty {
                    Text("No points scored yet")
                } else {
                    ForEach(pointsSorted(), id: \.id) { point in
                        HighlightListView(point: point, gameStart: game.date)
                    }.onDelete(perform: removePoint)
                }

                    
            }.foregroundStyle(.black)
                
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
                                participationToSelectTeamFor.team = selectedTeam
                                refreshScore()
                                showingSelectTeam = false
                            }
//                            .disabled(selectedTeam == nil)
                        }
                
                    }
            }
            
        }
    }
    
    func addPoint(participation: Participation) {
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
    
    let games = makeFakeData(container: container)
//    games.forEach({data in container.mainContext.insert(data)})

        return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

#Preview("No Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeDataWithoutTeams()
    
    games.forEach({data in container.mainContext.insert(data)})


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
