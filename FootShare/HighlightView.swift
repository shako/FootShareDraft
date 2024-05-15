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
    
    var body: some View {
        let allSessions = clock.sessions.lastToFirst
        let sessions = relevantSessions(sessions: allSessions)
 
        TabView {
            VStack {

                if (!clock.hasEnded) {
                    ClockView(clock: clock)
                }
                
                VStack {
                    HighLightListView(sessions: allSessions, points: points, groupBySession: true)
                }
                .frame(maxHeight: .infinity, alignment: .top)

            }
            .tabItem {
                if clock.hasEnded {
                    Label("", systemImage: "list.bullet")
                } else {
                    Label("Clock", systemImage: "timer")
                }
                
            }
            
            ForEach(Array(sessions.enumerated()), id: \.element) { index, session in
                let sessionNumber = sessions.count - index
                
                VStack {
                    Text("Session \(sessionNumber)")
                        .font(.title)
                    SessionSummaryView(session: binding(for: session))
                    HighLightListView(sessions: sessions, points: points.madeDuring(session))
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .tabItem { Label("", systemImage: "\(sessionNumber).square") }
            }

        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear(perform: {
            UIPageControl.appearance().currentPageIndicatorTintColor = .red.withAlphaComponent(0.8)
//            UIPageControl.appearance().pageIndicatorTintColor = .red
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.primary).withAlphaComponent(0.3)
        })
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

                List {
                    if (groupBySession) {
                        ForEach(sessions, id: \.id) { session in
                            let sessionPoints = points.madeDuring(session).lastToFirst
                            Section {
                                ForEach(sessionPoints, id: \.id) { point in
                                    HighlightEntryView(point: point)
                                }
                                if (sessionPoints.isEmpty) {
                                    Text("No Highlights")
                                }
                            } header: {
                                if let sessionIndex = sessions.firstIndex(of: session) {
//                                    if (clock.sessions.count > 1) {
                                    if (session.isPlaying) {
                                        Text("Session \(sessions.count - sessionIndex) - playing")
                                    } else {
                                        Text("Session \(sessions.count - sessionIndex)")
                                    }

//                                    }
                                }

                                
                                
                            }
                            
                        }

                    } else {
                        Section {
                            ForEach(points, id: \.id) { point in
                                HighlightEntryView(point: point)
                            }
                        }
                    }

    //                .onDelete(perform: removePoint)
    //                .deleteDisabled(game.clock.hasEnded)
                }
                    .listStyle(.inset)
            
        
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
        return NavigationStack {
            HighlightView(clock: .constant(game.clock), points: game.points).modelContainer(container)
            Spacer()
    }
}
