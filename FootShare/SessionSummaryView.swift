//
//  SectionSummaryView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 09/05/2024.
//

import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    
    @Binding var session: Session
    
    var body: some View {

        Section {
            Label {
                Text("\(formatDuration(session.duration))")
            } icon: {
                Image(systemName: "timer")
            }

            ForEach(session.participations.homeFirst()) { participation in
                Label {
                    Text("\(session.points.forParticipation(participation).count) - \(participation.team?.name ?? "")")
                } icon: {
                    Image(systemName: "soccerball")
                }

            }
            

        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.leading)
            
            

    }
    
    func formatDuration(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeInterval)!
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    
    return List {
        SessionSummaryView(session: .constant(games.first!.clock.sessions.firstToLast.last!)).listStyle(.grouped)
    }
}
