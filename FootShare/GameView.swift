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
    
    @State var scoringTarget: ScoringTarget = .none
    
    @State private var reversedParticipationOrder = false
    
    @State private var selectedTeam: Team? = Team.emptyTeam
    @State private var participationToSelectTeamFor : Participation = Participation.emptyParticipation

    var body: some View {
        let _ = Self._printChanges()
        ZStack {
            VStack {
                HStack(spacing: 8) {
                    Group {
                        ForEach(orderedParticipations.indices, id: \.self) { index in
                            let participation = orderedParticipations[index]
                            
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
                                                Text("\(String(participation.score))")
                                                    .font(.system(size: 100))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .background(.regularMaterial)
                                                    .foregroundStyle(Color.primary)
                                                    
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .padding()
                                                    .background(Color(participation.team?.color ?? UIColor.red))
                                            }
                                        })
                                        .disabled(!game.participations.teamsSelected || !game.clock.isRunning)
                                        .zIndex(2)
                                        
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
                            .id("participation-\(index)")
                            .frame(maxWidth: .infinity, maxHeight: 200)
                                .background(.gray.opacity(0.15))
    //                            .background(.black)
                                .clipShape(
                                    .rect(cornerRadii: RectangleCornerRadii(
                                        topLeading: (10),
                                        bottomLeading: (10),
                                        bottomTrailing: (10),
                                        topTrailing: 10))
                                )
                                .padding(index == 0 ? .leading : .trailing, 8)

                        }

                        
                        //                }
                    }
                }
                .zIndex(-1)

                
                ZStack {
                    if !game.participations.teamsSelected {
                        (Text(Image(systemName: "arrow.up")) + Text(" Select both teams to start ") + Text(Image(systemName: "arrow.up"))).fontWeight(.semibold).padding(.top)
                        Spacer()
                    } else {

                        VStack {
                                if !game.participations.teamsSelected {
                                } else {
                                    HighlightView(clock: $game.clock, points: game.points)
                                        .padding(.bottom, 6)
                                        .ignoresSafeArea(.all, edges: .bottom)
                                }

                        }.zIndex(1)


                    }
                    
                    if scoringTarget == .leading || scoringTarget == .trailing {
                        HStack {
                            VStack {
                                Text(scoringTarget == .leading ? "+1" : "")
                                    .font(.system(size: 100))
                                    .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.regularMaterial)
                                    .foregroundStyle(Color.primary)
                                    
    //                                .clipShape(RoundedRectangle(cornerRadius: 10))
    //                                .padding()
                                    .background(Color(orderedParticipations.first!.team?.color ?? UIColor.red))
                                    .padding()
                                    .background(scoringTarget == .leading ?  (Color(orderedParticipations.first!.team?.color ?? UIColor.red)) : nil)
                            }
                            VStack {
                                Text(scoringTarget == .trailing ? "+1" : "")
                                    .font(.system(size: 100))
                                    .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.regularMaterial)
                                    .foregroundStyle(Color.primary)
                                    
    //                                .clipShape(RoundedRectangle(cornerRadius: 10))
    //                                .padding()
                                    .background(Color(orderedParticipations.last!.team?.color ?? UIColor.red))
                                    .padding()
                                    .background(scoringTarget == .trailing ? (Color(orderedParticipations.last!.team?.color ?? UIColor.red)) : nil)
                                    
                            }
                        }.frame(maxHeight: .infinity)
                            .zIndex(2)
                }


//                    Spacer()
                }

                
            }

            if (game.clock.isRunning) {
                VStack {
                    BallView(scoringTarget: $scoringTarget, scoreGoalFunction: scoreGoal)
                        .padding(.top, -10)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 25)
                }
            }
            

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
        .toolbar {
            ToolbarItem(placement: .principal) {
                iconToSwitchSides
            }
            
        }
        
    }
    

    func mockScoreGoalFunction(scoringTarget: ScoringTarget) {
        debugPrint("Scoring goal for: \(scoringTarget.rawValue)")
    }
    
    var iconToSwitchSides : some View {
        Button {
            reversedParticipationOrder.toggle()
        } label: {
            Image(systemName: "arrowshape.left.arrowshape.right")
        }

    }
    
    var orderedParticipations: [Participation] {
        var participations = game.participations.homeFirst()
        if reversedParticipationOrder {
            participations = participations.reversed()
        }
        return participations
    }
    
    func addPoint(participation: Participation) {
        participation.points.append(Point(date: .now, session: game.clock.sessions.ongoing))
        game.date = game.date // force refresh screen. Not needed in simulator, needed on real device
        refreshScore()
    }
    
    func scoreGoal(scoringTarget: ScoringTarget) {
        if case .leading = scoringTarget {
            addPoint(participation: orderedParticipations.first!)
        }
        if case .trailing = scoringTarget {
            addPoint(participation: orderedParticipations.last!)
        }
    }
    
    func refreshScore() {
        game.participations = game.participations
    }


    
}

#Preview("Two Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
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
    games.first!.clock = Clock()

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




struct EditableTeam: Identifiable {
    var id: Int
}

struct TeamHeader: View {
    let name: String
    let isLeft: Bool
    
    var body: some View {
        Text("\(name)")/*.font(.largeTitle)*/
            .foregroundStyle(.white)
            .lineLimit(1)
            .frame( maxWidth: .infinity)
            .fontWeight(.semibold)
//            .clipShape(
//                .rect(cornerRadii: RectangleCornerRadii(
//                    topLeading: (isLeft ? 0 : 10),
//                    bottomLeading: 0,
//                    bottomTrailing: 0,
//                    topTrailing: (!isLeft ? 0 : 10)))
//                
//            )
//            .scaledToFit()
            .padding(.horizontal, 4)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity).background(.black)
    }
}

@Observable
class TeamEditor {
    var isEditing = false
    var editingParticipation: Participation?
    var teamEditInProgress: Team = Team.emptyTeam
    
}
