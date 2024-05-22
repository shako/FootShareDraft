//
//  HighlightView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/04/2024.
//

import SwiftData
import SwiftUI

struct HighlightView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var clock: Clock
    var points: [Point]
    var refreshAction: (() -> Void)?
    
    @State private var selectedTab = "current"
    @State private var infoType = "highlights"
    @State private var lastSessionIsPlaying = false
    
    var body: some View {
        let allSessions = clock.sessions.firstToLast
        let sessions = relevantSessions(sessions: allSessions)
        let closedSessions = allSessions.closed
 
        let _ = Self._printChanges()
        
        
        TabView(selection: $selectedTab) {
            
            if (!clock.hasEnded) {
                VStack
                {
                    if (lastSessionIsPlaying) {
                        infoTypeTitle
                        chooseInfoType
                    }
                    
                    ClockView(clock: clock)

                    if (lastSessionIsPlaying) {
                        
                        List{
                            let session = clock.lastSession!
                            
                            
                            Section {

                                if (infoType == "statistics") {
                              
                                    SessionSummaryView(session: binding(for: session))
                   
                                } else {
                                    HighLightListView(sessions: sessions, points: session.points)
                                        .frame(maxHeight: .infinity)
                                    
                                    
                                    if (session.points.isEmpty) {
                                        Text("No Highlights")
                                    }
         
                                }
                                
                            } header: {
                                Text("Session \(clock.sessions.count)")
                                    .foregroundStyle(.blue)
                            }
                            
                        }.listStyle(.grouped)
                        


                    }
                        
                        
                        
                    
            }
                
                .frame(maxHeight: .infinity, alignment: .top)
                .tag("current")
                .tabItem {
                    Label("Clock", systemImage: "timer")
                }
            }
            
            if (closedSessions.count > 0) {
                VStack() {
                    infoTypeTitle
                    chooseInfoType
                    VStack {
                        
                        List {
                            if (infoType == "statistics") {
                                ForEach(Array(clock.sessions.firstToLast.enumerated()), id: \.element) { index, session in
                                    var sessionNumber = index + 1
                                    
                                    Section {
                                        SessionSummaryView(session: binding(for: session))
                                        
                                    } header: {
                                        if (session.isPlaying) {
                                            Text("Session \(sessionNumber) - playing")
                                                .foregroundStyle(.blue)
                                        } else {
                                            Text("Session \(sessionNumber)")
                                                .foregroundStyle(.blue)
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            } else {
                               
                                HighLightListView(sessions: allSessions, points: points, groupBySession: true)
              
                            }
                        }
                        .listStyle(.grouped)
                        


                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .tag("summary")
                .tabItem {
                    Label("", systemImage: "list.bullet")
                }
            }

        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear(perform: {
            UIPageControl.appearance().currentPageIndicatorTintColor = .red.withAlphaComponent(0.8)
//            UIPageControl.appearance().pageIndicatorTintColor = .red
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.primary).withAlphaComponent(0.3)
            calculateTabSelection()
            calculateShowHighlightsAndStats()
        })
        .onChange(of: clock.hasEnded) { _, _ in
            calculateTabSelection()
        }
        .onChange(of: clock.inBreak) { _, _ in
            withAnimation(.snappy) {
                calculateShowHighlightsAndStats()
            }
        }
    }
    
    func calculateShowHighlightsAndStats() {
        lastSessionIsPlaying = (!clock.hasEnded && ((clock.lastSession?.isPlaying) == true))
    }
    
    var infoTypeTitle: some View {
        Text("\(infoType)".capitalized)
            .fontWeight(.semibold)
    }
    
    var chooseInfoType: some View {
        Picker("Info type", selection: $infoType) {
            Image(systemName: "list.bullet").tag("highlights")
            Image(systemName: "chart.bar").tag("statistics")
        }.pickerStyle(.segmented).padding(.horizontal)
    }
    
    func calculateTabSelection() {
        if (clock.hasEnded) {
            selectedTab = "summary"
        } else {
            selectedTab = "current"
        }
    }
    
    private func binding(for session: Session) -> Binding<Session> {
        guard let index = clock.sessions.firstIndex(of: session) else {
            fatalError("Session not found in clock.sessions")
        }
        return $clock.sessions[index]
    }
    
    func relevantSessions(sessions: [Session]) -> [Session] {
        if (sessions.count > 1) {
//            debugPrint("Returning all sessions")
            return sessions
        }
        
//        debugPrint("Returning no sessions")
        return [Session]()
//        if (clock.hasEnded && sessions.count < 2) {
//            debugPrint("Clock has ended and less than 2 sessions. showing no sessions")
//            return [Session]()
//        }
//        if clock.hasEnded || clock.inBreak {
//            debugPrint("clock has ended or is in break. showing all sessions")
//            return clock.sessions.lastToFirst
//        } else {
//            debugPrint("showing all but latest sessions")
//            return Array(clock.sessions.lastToFirst.dropFirst())
//        }
    }
    
    func removePoint(indexSet: IndexSet) {
        for index in indexSet {
            let point = pointsSorted()[index]
            modelContext.delete(point)
            try? modelContext.save()
        }
        refreshAction?()
    }
    
    func pointsSorted() -> [Point] {
        points.sorted(by: { pointl, pointr in
            pointl.date > pointr.date
        })
    }
}

struct HighLightListView: View {
    
    var sessions: [Session]
    var points: [Point]
    var groupBySession: Bool = false
    
    var body: some View {

//                                Text("Goals").font(.callout)


                    if (groupBySession) {
                        ForEach(sessions, id: \.id) { session in
                            let sessionPoints = points.madeDuring(session).firstToLast
                            Section {
                                ForEach(sessionPoints, id: \.id) { point in
                                    HighlightEntryView(point: point)
                                }
                                if (sessionPoints.isEmpty) {
                                    Text("No Highlights")
                                }
                            } header: {
                                if (sessions.count < 2) {
                                    
                                } else if let sessionIndex = sessions.firstIndex(of: session) {
//                                    if (clock.sessions.count > 1) {
                                    if (session.isPlaying) {
                                        Text("Session \(sessionIndex + 1) - playing")
                                            .foregroundStyle(.blue)
                                    } else {
                                        Text("Session \(sessionIndex + 1)")
                                            .foregroundStyle(.blue)
                                    }

//                                    }
                                }

                                
                                
                            }
                            
                        }

                    } else {
                        Section {
                            ForEach(points.lastToFirst, id: \.id) { point in
                                HighlightEntryView(point: point)
                            }
                        }
                    }

    //                .onDelete(perform: removePoint)
    //                .deleteDisabled(game.clock.hasEnded)

            
        
    }
}

struct HighlightEntryView: View {
    let point: Point
    
    var body: some View {
        
        HStack {
            Image(systemName: "soccerball.inverse").rotationEffect(.degrees(Double(Int.random(in: 0...360))))
            Text("\(formatHighlightTime(seconds: point.participation!.game!.clock.sessions.playTimeUpTo(date: point.date))) - \(point.participation?.team?.name ?? "unknown")")
                .font(.callout)
        }
        .padding(.leading, -5)
    }
    
    func formatHighlightTime(seconds: Double) -> String {
        let minutes = Int(((seconds) / 60).rounded(.up))
        return "\(minutes)'" // (\(Int(seconds.rounded(.up))) secs)
    }
    
}

#Preview("Playing game") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
        return NavigationStack {
            HighlightView(clock: .constant(game.clock), points: game.points).modelContainer(container)
            Spacer()
    }
}

#Preview("Ended game") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
    game.clock.end()
        return NavigationStack {
            HighlightView(clock: .constant(game.clock), points: game.points).modelContainer(container)
            Spacer()
    }
}

