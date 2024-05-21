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
    var sessionNumber: Int
    
    var body: some View {

        Section {
            Label {
                Text("\(formatDuration(session.duration))")
            } icon: {
                Image(systemName: "clock")
                    .foregroundColor(.accentColor)
            }

            ForEach(session.participations.homeFirst()) { participation in
                Label {
                    Text("\(session.points.forParticipation(participation).count) - \(participation.team?.name ?? "")")
                } icon: {
                    Image(systemName: "soccerball")
                        .foregroundColor(.accentColor)
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

/// Create a Label with a custom image which can have its color updated using the
/// `.foregroundColor(_)` funtion.
struct LabelWithImageIcon: View {
   /// The title which will be passed to the title attribute of the Label View.
   let title: String
   /// The name of the image to pass into the Label View.
   let image: String
   
   var body: some View {
       Label(title: {
           Text(self.title)
       }, icon: {
           Image(self.image)
               .renderingMode(.template)
       } )
   }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    
    return SessionSummaryView(session: .constant(games.first!.clock.sessions.firstToLast.last!), sessionNumber: 2)
}
