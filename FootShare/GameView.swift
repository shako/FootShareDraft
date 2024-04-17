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
    @State var teamEditor = TeamEditor()
    
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
                                    Button {
                                        debugPrint("I'm clicked!")
                                        teamEditor.editingParticipation = participation
                                        teamEditor.teamEditInProgress = participation.team!.copy()
                                        teamEditor.isEditing = true
                                    } label: {
                                        TeamHeader(name: participation.team!.name, isLeft: index == 0)
                                    }
//                                    .sheet(item: $teamEditor.currentTeam) { team in
                                    .sheet(isPresented: $teamEditor.isEditing) {
                                        NavigationStack {
                                            AddTeamView(team: $teamEditor.teamEditInProgress)
                                            .toolbar {
                                                ToolbarItem(placement: .cancellationAction) {
                                                    Button("Cancel") {
                                                        teamEditor.isEditing = false
                                                    }
                                                }
                                                ToolbarItem(placement: .confirmationAction) {
                                                    Button("Done") {
                                                        teamEditor.editingParticipation!.team?.updateDetailsFrom(other: teamEditor.teamEditInProgress)
                                                        teamEditor.isEditing = false
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Button(action: {addPoint(participation: participation)}, label: {
                                        // todo: move to seperate method, but make sure that after deleting a goal the score gets updated
                                        VStack {
                                                Text("\(participation.score)")
                                                .font(.system(size: 100))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .background(.regularMaterial)
                                                .foregroundStyle(Color.primary)
                                                
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .padding()
                                                .background(Color(participation.team?.color ?? UIColor.red))
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
                                        ((participation.isHomeTeam ? Text("Home ") : Text("Out ")) + Text("Team"))
                                            .font(.title2)
                                            .padding()
                                            .background(.white)
                                            .foregroundColor(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            
                                    }
                                    
                                }.background(content: {
                                    Image(systemName: participation.isHomeTeam ? "house" : "figure.run")
                                        .resizable()
                                        .padding()
                                        .scaledToFill()
                                        .foregroundStyle(.black.opacity(0.1))
                                        
                                })
                                
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
                                                }
                                            }
                                    }
                                }
                                
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 200)
                            .background(.gray.opacity(0.15))
//                            .background(.black)
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
                (Text(Image(systemName: "arrow.up")) + Text(" Select both teams to start ") + Text(Image(systemName: "arrow.up"))).fontWeight(.semibold).padding(.top)
//                    .frame(maxHeight: .infinity)
                Spacer()
            } else {
                ClockView(clock: game.clock)
                List {
                    if !game.participations.teamsSelected {

                    } else if pointsSorted().isEmpty {
                        Text("No points scored!")
                    } else {
                        ForEach(pointsSorted(), id: \.id) { point in
                            HighlightListView(point: point, gameStart: game.date)
                        }.onDelete(perform: removePoint)
                    }
                    
                }
            }
                
        } .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
        

    }
    
    func addPoint(participation: Participation) {
        participation.points.append(Point(date: .now))
        game.date = game.date // force refresh screen. Not needed in simulator, needed on real device
        refreshScore()
    }
    
    func refreshScore() {
        game.participations = game.participations
    }
    
    func removePoint(indexSet: IndexSet) {
        for index in indexSet {
            let point = pointsSorted()[index]
            modelContext.delete(point)
        }
        refreshScore()
    }
    
    func pointsSorted() -> [Point] {
        game.points.sorted(by: { pointl, pointr in
            if (pointl.date > pointr.date) {
                return true
            } else if (pointl.date < pointr.date) {
                return false
            } else {
                return pointl.id.hashValue > pointr.id.hashValue
            }
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
    games.first!.participations.out!.team?.name = "short"

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
        
        HStack {
            Image(systemName: "soccerball.inverse").rotationEffect(.degrees(Double(Int.random(in: 0...360))))
            Text("\(formatHighlightTime(seconds: point.secondsSindsGameStart())) - \(point.participation?.team?.name ?? "unknown")")
        }.padding(.leading, -5)
    }
    
    func formatHighlightTime(seconds: Double) -> String {
        let minutes = Int(((seconds) / 60).rounded(.up))
        return "\(minutes)'"
    }
    
}

struct EditableTeam: Identifiable {
    var id: Int
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
//            .clipShape(
//                .rect(cornerRadii: RectangleCornerRadii(
//                    topLeading: (isLeft ? 0 : 10),
//                    bottomLeading: 0,
//                    bottomTrailing: 0,
//                    topTrailing: (!isLeft ? 0 : 10)))
//                
//            )
            .scaledToFit()
            .padding(.vertical)
            .frame(maxWidth: .infinity).background(.black)
    }
}

@Observable
class TeamEditor {
    var isEditing = false
    var editingParticipation: Participation?
    var teamEditInProgress: Team = Team.emptyTeam {
        didSet {
            print("currentTeam was set to: \(teamEditInProgress.name ?? "nil")")
        }
    }
    
}
