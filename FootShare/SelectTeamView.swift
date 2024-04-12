//
//  SelectTeamView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 27/03/2024.
//

import SwiftData
import SwiftUI

struct SelectTeamView: View {
    @Environment(\.modelContext) var modelContext
    
    @Environment(\.dismiss) var dismiss
    
    @Query var teams: [Team]
    @Binding var selectedTeam: Team?
    @State var newTeam: Team = Team.emptyTeam
    
    @State var showingAddTeam = false
    
    @State private var teamOwnerFilter = teamOwner.my

    enum teamOwner: String, Codable, CaseIterable {
        case all, my
    }
    
    var body: some View {
        VStack {
            Picker("owner", selection: $teamOwnerFilter) {
                ForEach(teamOwner.allCases, id: \.self) { teamOwner in
                    switch teamOwner {
                        case .all:
                            Text("all teams".capitalized)
                        case .my:
                            Text("my teams".capitalized)
                    }
                }
            }
            .pickerStyle(.segmented).padding()

            List(selection: $selectedTeam) {
                ForEach(teams.filter {team in teamOwnerFilter == .my ? team.isYourTeam == true : true}) { team  in
                    Text("\(team.name)").tag(team)
                }

            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    newTeam = Team(name: "", isYourTeam: false)
                    showingAddTeam = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $showingAddTeam) {
            
            NavigationStack {
                AddTeamView(team: $newTeam)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddTeam = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                modelContext.insert(newTeam)
                                selectedTeam = newTeam
                                showingAddTeam = false
                            }
                        }
                }
            }
        }
//            .sheet(isPresented: $showingNewTeamSheet, content: {
//                AddTeamView(team: $newTeam)
//            })
//            

        


    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Team.self, configurations: config)
    let teams = makeTeams(container: container)
    
    let participation = Participation(isHomeTeam: true, points: [])
    return NavigationStack {
        SelectTeamView(selectedTeam: .constant(participation.team)).modelContainer(container)
    }
}


@MainActor func makeTeams(container: ModelContainer) -> [Team] {
    let team1 = Team(name: "Westerlo", isYourTeam: true)
    let team2 = Team(name: "Geel", isYourTeam: false)
    let team3 = Team(name: "Kampenhout", isYourTeam: false)
    let team4 = Team(name: "Brugge", isYourTeam: false)
    
    team1.colorHex = 16711680
    let teams = [team1, team2 , team3, team4]
    
    teams.forEach { team in
        container.mainContext.insert(team)
    }
    
    return teams
}
