//
//  PlayView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/05/2024.
//

import SwiftData
import SwiftUI

struct GamePlayView: View {
    
    @Bindable var game: Game
    
    @State private var reversedParticipationOrder = false
    @State var teamEditor = TeamEditor()
    @State var scoringTarget: ScoringTarget = .none
    var refreshAfterUpdateHighlightFunction: (() -> Void)?
    
    var body: some View {
//        NavigationStack {
            ZStack {
                VStack {
                    HStack(spacing: 8) {
                        Group {
                            ForEach(orderedParticipations.indices, id: \.self) { index in
                                let participation = orderedParticipations[index]
                                
//                                VStack {
//                                    
//                                }                                    .clipShape(
//                                    .rect(cornerRadii: RectangleCornerRadii(
//                                        topLeading: (10),
//                                        bottomLeading: (10),
//                                        bottomTrailing: (10),
//                                        topTrailing: 10))
//                                )
                                VStack(spacing: 0) {
                                    HStack() {
                                        (participation.team?.color != nil) ? Color(participation.team!.color) : Color.secondary
                                    }
                                    .frame(height: 12)
                                    
                                    
                                    Button {
                                        if participation.team != nil {
                                            teamEditor.editingParticipation = participation
                                            teamEditor.teamEditInProgress = participation.team!.copy()
                                            teamEditor.isEditing = true
                                        }
                                    } label: {
                                        TeamHeader(name: participation.team?.name ?? "", isLeft: index == 0)
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
                                                .background((participation.team?.color != nil && (!game.clock.inBreak && !game.clock.yetToStart)) ? Color(participation.team!.color) : Color.secondary.opacity(0.1))
                                        }
                                    })
                                    .disabled(!game.participations.teamsSelected || !game.clock.isRunning)
                                    .zIndex(2)

                                }
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

                        VStack {
                            ClockView(clock: game.clock)
                            if let session = game.clock.sessions.ongoing {
                                List {
                                    SessionHighlightsView(session: binding(for: session), header: SessionHeaderView(session: session))
    //                                        .padding(.bottom, 6)

                                }.listStyle(.grouped)

                            } else {
                                quote
                            }
                        }.zIndex(1)

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

                    
                }.frame(maxHeight: .infinity, alignment: .top)

                if (game.clock.isRunning) {
                    VStack {
                        BallView(scoringTarget: $scoringTarget, scoreGoalFunction: scoreGoal)
                            .padding(.top, -10)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, 25)
                    }
                }
            }

//        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
        .toolbar {
            ToolbarItem(placement: .principal) {
                iconToSwitchSides
            }
            
        }
    }
    
    private func binding(for session: Session) -> Binding<Session> {
        guard let index = game.clock.sessions.firstIndex(of: session) else {
            fatalError("Session not found in clock.sessions")
        }
        return $game.clock.sessions[index]
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
        refreshAfterUpdateHighlightFunction?()
    }
    
    func scoreGoal(scoringTarget: ScoringTarget) {
        if case .leading = scoringTarget {
            addPoint(participation: orderedParticipations.first!)
        }
        if case .trailing = scoringTarget {
            addPoint(participation: orderedParticipations.last!)
        }
    }
    
    var iconToSwitchSides : some View {
        Button {
            reversedParticipationOrder.toggle()
        } label: {
            Image(systemName: "arrowshape.left.arrowshape.right")
        }

    }
    
    var quote: some View {
        GeometryReader { geometry in
            ZStack {
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.secondary.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                let quote = "\"Cheer their effort, not just the score. Positivity fuels passion and growth.\""
                Text(quote)
                    .italic()
                    .foregroundColor(.primary.opacity(0.6))
                    .font(.system(size: min(geometry.size.width, geometry.size.height) / 10, weight: .bold, design: .serif))
                    .padding()
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
    
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
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.8))
    }
}

@Observable
class TeamEditor {
    var isEditing = false
    var editingParticipation: Participation?
    var teamEditInProgress: Team = Team.emptyTeam
    
}


#Preview("Playing") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    
    return NavigationStack {
        GamePlayView(game: games.first!).modelContainer(container)
    }
}

#Preview("New game") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
    game.clock.sessions = []
    game.clock.status = .not_started
    
    return NavigationStack {
        GamePlayView(game: games.first!).modelContainer(container)
    }
}
