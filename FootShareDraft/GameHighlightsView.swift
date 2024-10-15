//
//  HighlightView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/04/2024.
//

import SwiftData
import SwiftUI

struct GameHighlightsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var sessions: [Session]
    var refreshAction: (() -> Void)?
    
    @State private var infoType = "highlights"
    @State private var lastSessionIsPlaying = false
    
    var body: some View {
 
        let _ = GameHighlightsView._printChanges()
        
        VStack {
            infoTypeTitle
            chooseInfoType
            List{
                if (infoType == "statistics") {
                    ForEach(sessions.byCreationDateAsc, id: \.id) { session in
                        Section {
                            SessionSummaryView(session: binding(for: session))
                        } header: {
                            if (session.isPlaying) {
                                Text("Session \(session.number) - playing")
                            } else {
                                Text("Session \(session.number)")
                            }
                        }
                    }
                } else {
                    HighLightListView(sessions: $sessions)
                        .frame(maxHeight: .infinity)
                }
            }.listStyle(.grouped)
        }
        .toolbar {}
        
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
    
    func relevantSessions(sessions: [Session]) -> [Session] {
        if (sessions.count > 1) {
            return sessions
        }
        
        return [Session]()
    }
    
    
    private func binding(for session: Session) -> Binding<Session> {
        guard let index = sessions.firstIndex(of: session) else {
            fatalError("Session not found in clock.sessions")
        }
        return $sessions[index]
    }
    
}


struct HighLightListView: View {
    
    @Binding var sessions: [Session]
    
    var body: some View {
        ForEach(sessions.byCreationDateAsc, id: \.id) { session in
            SessionHighlightsView(session: binding(for: session), header: SessionHeaderView(session: session))
        }
    }
    
    private func binding(for session: Session) -> Binding<Session> {
        guard let index = sessions.firstIndex(of: session) else {
            fatalError("Session not found in clock.sessions")
        }
        return $sessions[index]
    }
}

struct SessionHeaderView: View {
    
    var session: Session
    
    var body: some View {
        let sessionTitle = session.isPlaying ? "Session \(session.number) - playing" : "Session \(session.number)"
        Text(sessionTitle)
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

#Preview() {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
        return NavigationStack {
            GameHighlightsView(sessions: .constant(game.clock.sessions)).modelContainer(container)
//            Spacer()
    }
}

