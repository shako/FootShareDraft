//
//  AddTeamView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 27/03/2024.
//

import SwiftData
import UIKit
import SwiftUI

struct AddTeamView: View {
    @Environment(\.dismiss) var dismiss
    
    enum FocusedField {
        case teamName
    }
    
    @Binding var team: Team
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        let colorBinding = Binding(
            get: { Color(team.color) },
            set: { team.color = UIColor($0) }
        )
        
        VStack {
            Form {
                TextField("Team name", text: $team.name)
                    .focused($focusedField, equals: .teamName)
                    .autocorrectionDisabled()
                    .font(.largeTitle)
                ColorPicker(selection: colorBinding) {
                    Text("Team color")
                }
                Toggle(isOn: $team.isYourTeam) {
                    Text("This is my team")
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
    let teams = makeTeams(container: container)
    return NavigationStack {
        AddTeamView(team: .constant(teams.first!)).modelContainer(container)
    }
}



