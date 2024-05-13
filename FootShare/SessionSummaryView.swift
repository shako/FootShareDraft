//
//  SectionSummaryView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 09/05/2024.
//

import SwiftUI
import SwiftData

struct SectionSummaryView: View {
    
    @Binding var session: Session
    
    var body: some View {
        HStack {
            VStack {
                Label("Duration: 15m3s", systemImage: "clock")
                Label("Goals Westerlo: 15m3s", systemImage: "clock")
            }.frame(alignment: .leading)

        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    
    return SectionSummaryView(session: .constant(games.first!.clock.sessions.first!))
}
