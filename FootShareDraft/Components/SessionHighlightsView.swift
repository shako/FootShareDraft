//
//  SessionHighlightsView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 25/05/2024.
//

import SwiftData
import SwiftUI

struct SessionHighlightsView<Content: View>: View {
    @Binding var session: Session
    var header: Content
    
    var body: some View {
        
        Section {
            ForEach(session.points.firstToLast, id: \.id) { point in
                HighlightEntryView(point: point)
            }
            if (session.points.isEmpty) {
                Text("No Highlights")
            }
        } header: {
            header
        }
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
        return NavigationStack {
            List {
                SessionHighlightsView(session: .constant(game.clock.sessions.firstToLast.last!), header: Text("Session \(game.clock.sessions.firstToLast.last!.number)")).modelContainer(container)
            }

            Spacer()
    }
    
}
