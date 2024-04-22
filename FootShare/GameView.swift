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
    
    @State var randomBallAngle = Double.random(in: 1..<45)
    @State var goalMarkerOffset: CGSize = CGSize.zero
    @State var movingGoalMarker: Bool = false
    
    @State private var reversedParticipationOrder = false
    
    @State private var selectedTeam: Team? = Team.emptyTeam
    @State private var participationToSelectTeamFor : Participation = Participation.emptyParticipation

    var body: some View {
 
        ZStack {
            VStack {
                HStack {

                    Image(systemName: "arrowshape.left.arrowshape.right.fill")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                        .onTapGesture {
                            withAnimation(Animation.easeOut) {
                                reversedParticipationOrder.toggle()
                            }
                        }
      
                }
                HStack(spacing: 8) {
                    Group {
                        ForEach(orderedParticipations.indices) { index in
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
                                                Text("\(isPreparingToScoreFor(index) ? "+1" :  String(participation.score))")
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
                            }.id("participation-\(index)")
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
                
                if !game.participations.teamsSelected {
                    (Text(Image(systemName: "arrow.up")) + Text(" Select both teams to start ") + Text(Image(systemName: "arrow.up"))).fontWeight(.semibold).padding(.top)
    //                    .frame(maxHeight: .infinity)
                    Spacer()
                } else {
                    ClockView(clock: game.clock)
                    VStack {
                        
                        
                            if !game.participations.teamsSelected {

                            } else if pointsSorted().isEmpty {
                                Text("No points scored!")
                            } else {
    //                            Text("Goals").font(.callout)
                                List {
                                    ForEach(pointsSorted(), id: \.id) { point in
                                        HighlightListView(point: point, clock: game.clock)
                                    }.onDelete(perform: removePoint)
                                        .deleteDisabled(game.clock.hasEnded)
                                }.listStyle(.inset)
                            }
                            
                        
                    }

                }
                Spacer()
                    
            }
        
        
//            if orderedParticipations.count > 1 {
//                HStack {
//                    VStack {
//                        Color(orderedParticipations.first?.team?.color ?? UIColor(Color.gray))
//                    }
//                    VStack {
//                        Color(orderedParticipations.last?.team?.color ?? UIColor(Color.gray))
//                    }
//                }
//                .ignoresSafeArea()
//                .frame(maxHeight: .infinity)
//                .opacity(movingGoalMarker ? 1 : 0)
//                .zIndex(1)
//            }

        }.navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(game.date.formatted(date: .abbreviated, time: .omitted))")
        
        
        if (game.clock.isRunning) {
            HStack {
                Image(systemName: "soccerball.inverse")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .background(Circle().fill(.red))
                    .foregroundStyle(.white)
                    .shadow(color: .red.opacity(0.3), radius: 5)
                    .rotationEffect(Angle(degrees: randomBallAngle))
                    .offset(goalMarkerOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if (!movingGoalMarker) {
                                    if (goalMarkerOffset.height < -50) {
                                        withAnimation {
                                            movingGoalMarker = true
                                        }
                                    }

                                } else {
                                    if (goalMarkerOffset.height >= -50) {
                                        withAnimation {
                                            movingGoalMarker = false
                                        }
                                    }
                                }
                                
                                withAnimation(.easeOut) {
                                    goalMarkerOffset = value.translation
                                }
                                
                            }
                            .onEnded { value in
                                withAnimation {
                                    if (isPreparingToScoreFor(0)) {
                                        addPoint(participation: orderedParticipations.first!)
                                    } else if (isPreparingToScoreFor(1)) {
                                        addPoint(participation: orderedParticipations.last!)
                                    }
                                    movingGoalMarker = false
                                }
                                
                                withAnimation(.bouncy) {
                                    goalMarkerOffset = .zero
                                }
                            }
                    )

                    
    //                .scaledToFill()
            }.frame(maxWidth: .infinity, alignment: .bottom)
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
            try? modelContext.save()
        }
        refreshScore()
    }
    
    func isScoreMarkerLocationLeft() -> Bool {
        return goalMarkerOffset.width <= 0
    }
    
    func isPreparingToScoreFor(_ index: Int) -> Bool {
        let isPointingLeft = isLeftToRight() && isScoreMarkerLocationLeft()
        let isLeftScoreBoard = index == 0
        if movingGoalMarker && ((isPointingLeft && isLeftScoreBoard) || (!isPointingLeft && !isLeftScoreBoard)) {
            return true
        }
        return false
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


struct HighlightListView: View {
    let point: Point
    let clock: Clock
    
    var body: some View {
        
        HStack {
            Image(systemName: "soccerball.inverse").rotationEffect(.degrees(Double(Int.random(in: 0...360))))
            Text("\(formatHighlightTime(seconds: calculateSecondsSinceGameStart())) - \(point.participation?.team?.name ?? "unknown")")
                .font(.callout)
        }
        .padding(.leading, -5)
    }
    
    func calculateSecondsSinceGameStart() -> Double {
        if let startTime = clock.startTime {
            let breaks = clock.breaks.filter({breakk in breakk.endTime != nil && breakk.endTime! <= point.date})
            let breakTime = breaks.reduce(0) {$0 + (($1.endTime ?? $1.startTime) - $1.startTime)}
            return (point.date - startTime - breakTime).rounded(.down)
        }
        return 0
    }
    
    func formatHighlightTime(seconds: Double) -> String {
        let minutes = Int(((seconds) / 60).rounded(.up))
        return "\(minutes)'" // (\(Int(seconds.rounded(.up))) secs)
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
    var teamEditInProgress: Team = Team.emptyTeam {
        didSet {
            print("currentTeam was set to: \(teamEditInProgress.name ?? "nil")")
        }
    }
    
}
