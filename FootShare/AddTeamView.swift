//
//  AddTeamView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 27/03/2024.
//

import SwiftData
import SwiftUI

struct AddTeamView: View {
    @Environment(\.dismiss) var dismiss
    
    enum FocusedField {
        case teamName
    }
    
    @Binding var team: Team
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
         
        VStack {
            Form {
                TextField("Team name", text: $team.name)
                    .focused($focusedField, equals: .teamName)
                    .autocorrectionDisabled()
                    .font(.largeTitle)
                Toggle(isOn: $team.isYourTeam) {
                    Text("Is your team")
                }
            }
            .onAppear {
                focusedField = .teamName
            }

            
            Spacer()
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Team.self, configurations: config)
    let teams = makeTeams()
    for team in teams {
        container.mainContext.insert(team)
    }
    return NavigationStack {
        AddTeamView(team: .constant(teams.first!)).modelContainer(container)
    }
}



