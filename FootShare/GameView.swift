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

        VStack {
            HStack() {
                Group {
                    ForEach(game.participations.homeFirst().indices) { index in
                        let participation = game.participations.homeFirst()[index]
                        Group {
                            if participation.team != nil {
                                VStack(spacing: 0) {
                                    
                                    TeamHeader(name: participation.team!.name, isLeft: index == 0)

                                    Button(action: {addPoint(participation: participation)}, label: {
                                        // todo: move to seperate method, but make sure that after deleting a goal the score gets updated
                                        VStack {
                                                Text("\(participation.score)")
                                                .font(.system(size: 100))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .background(.regularMaterial)
                                                .foregroundStyle(.black)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .padding()
                                                .background(Color.init(hex: participation.team?.colorHex ?? 16711680))
                                        }
                                    })
                                    .disabled(!game.participations.teamsSelected)
                                    
                                }
                                
                                
                            } else {
                                VStack {
                                    Button {
                                        participationToSelectTeamFor = participation
                                        selectedTeam = nil
                                        showingSelectTeam = true
                                    } label: {
                                        (Text("Select ") + (participation.isHomeTeam ? Text(Image(systemName: "house")) : Text(Image(systemName: "figure.run"))) + Text(" Team"))
                                            .font(.title2)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    
                                }
                                
                            }
                        }.frame(maxWidth: .infinity, maxHeight: 200).background(.gray.opacity(0.15))
                            .clipShape(
                                .rect(cornerRadii: RectangleCornerRadii(
                                    topLeading: (index == 0 ? 0 : 10),
                                    bottomLeading: (index == 0 ? 0 : 10),
                                    bottomTrailing: (index == 1 ? 0 : 10),
                                    topTrailing: (index == 1 ? 0 : 10)))
                            )

                    }
                    //                }
                }
            }
            if !game.participations.teamsSelected {
                (Text(Image(systemName: "arrow.up")) + Text(" Select teams to start ") + Text(Image(systemName: "arrow.up"))).frame(maxHeight: .infinity)
//                Spacer()
            } else {
                List {
                    if !game.participations.teamsSelected {
                        Text(Image(systemName: "arrow.up")) + Text(" Select teams to start ") + Text(Image(systemName: "arrow.up"))
                    } else if pointsSorted().isEmpty {
                        Text("No points scored!")
                    } else {
                        ForEach(pointsSorted(), id: \.id) { point in
                            HighlightListView(point: point, gameStart: game.date)
                        }.onDelete(perform: removePoint)
                    }
                    
                }.foregroundStyle(.black)
            }
                
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

#Preview("One Team") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    games.first!.participations.home!.team = nil
    games.first!.participations.home!.points = []
    games.first!.participations.out!.points = []
//    games.forEach({data in container.mainContext.insert(data)})

        return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

#Preview("No Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container, assignTeams: false)
    
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

struct TeamHeader: View {
    let name: String
    let isLeft: Bool
    
    var body: some View {
        Text("\(name)")/*.font(.largeTitle)*/
            .foregroundStyle(.white)
            .frame( maxWidth: .infinity)
            .font(.title3)
            .fontWeight(.semibold)
            .scaledToFit()
            .padding()
            .background(.black)
            .clipShape(
                .rect(cornerRadii: RectangleCornerRadii(
                    topLeading: (isLeft ? 0 : 10),
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: (!isLeft ? 0 : 10)))
            )
    }
}
