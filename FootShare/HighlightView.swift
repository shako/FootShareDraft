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
        TabView {
            VStack {
                if clock.hasEnded {
                    VStack {
                        HighLightListView(clock: clock, points: points, groupBySession: true)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)

                } else {
                    VStack {
                        ClockView(clock: clock)
                        if let ongoingSession = clock.sessions.ongoing {
                            HighLightListView(clock: clock, points: points.madeDuring(ongoingSession))
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)

                }
            }
            .tabItem {
                if clock.hasEnded {
                    Label("", systemImage: "list.bullet")
                } else {
                    Label("Clock", systemImage: "timer")
                }
                
            }
            
            ForEach(relevantSessions(sessions: clock.sessions), id: \.self) { session in
                let sessionNumber = relevantSessions(sessions: clock.sessions).firstIndex(of: session) ?? 0
                
                VStack {
                    Text("Session \(relevantSessions(sessions: clock.sessions).count - sessionNumber)")
                        .font(.title)
                    HighLightListView(clock: clock, points: points.madeDuring(session))
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .tabItem { Label("", systemImage: "\(relevantSessions(sessions: clock.sessions).count - sessionNumber).square") }
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
    
    func relevantSessions(sessions: [Session]) -> [Session] {
        if (clock.hasEnded && sessions.count < 2) {
            debugPrint("Clock has ended and less than 2 sessions. showing no sessions")
            return [Session]()
        }
        if clock.hasEnded || clock.inBreak {
            debugPrint("clock has ended or is in break. showing all sessions")
            return clock.sessions.lastToFirst
        } else {
            debugPrint("showing all but latest sessions")
            return Array(clock.sessions.lastToFirst.dropFirst())
        }
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
    
    var clock: Clock
    var points: [Point]
    var groupBySession: Bool = false
    
    var body: some View {
        if !points.isEmpty {
//                                Text("Goals").font(.callout)

                List {
                    
                    if (groupBySession) {
                        ForEach(clock.sessions.lastToFirst.indices) { sessionIndex in
                            let session = clock.sessions.lastToFirst[sessionIndex]
                            Section {
                                ForEach(session.points, id: \.id) { point in
                                    HighlightEntryView(point: point)
                                }
                                if (session.points.isEmpty) {
                                    Text("No Highlights")
                                }
                            } header: {
                                Text("Session \(clock.sessions.count - sessionIndex)")
                                
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
