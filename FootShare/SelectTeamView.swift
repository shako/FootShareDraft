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

    var body: some View {
        VStack {
                    List(selection: $selectedTeam) {
                        Section ("Your teams") {
                            ForEach(teams.filter {$0.isYourTeam == true}) { team  in
                                Text("\(team.name)").tag(team)
                            }
                        }
                        
                        Section ("Other teams") {
                            ForEach(teams.filter {$0.isYourTeam == false}) { team  in
                                Text("\(team.name)").tag(team)
                            }
                        }

                    }
            }      
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        newTeam = Team(name: "", isYourTeam: false)
                        showingAddTeam = true
    //                        showingNewTeamSheet = true
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
    for team in makeTeams() {
        container.mainContext.insert(team)
    }
    let participation = Participation(isHomeTeam: true, points: [])
    return NavigationStack {
        SelectTeamView(selectedTeam: .constant(participation.team)).modelContainer(container)
    }
}


func makeTeams() -> [Team] {
    let team = Team(name: "Westerlo", isYourTeam: true)
    team.colorHex = 16711680
    let teams = [team, Team(name: "Geel", isYourTeam: false), Team(name: "Kampenhout", isYourTeam: false), Team(name: "Brugge", isYourTeam: false)]
    return teams
}
