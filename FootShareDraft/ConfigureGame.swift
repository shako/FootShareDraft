//
//  ConfigureGame.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 27/05/2024.
//

import SwiftData
import SwiftUI

struct ConfigureGame: View {
    
    @Bindable var game: Game
    
    @State private var participationToSelectTeamFor : Participation = Participation.emptyParticipation
    @State private var showingSelectTeam = false
    @State private var selectedTeam: Team? = Team.emptyTeam
    @State private var isConfigurationCompleted = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                ForEach(game.participations.homeFirst()) { participation in
                    if (participation.team != nil) {
                        Text("\(participation.team!.name)")
                    } else {
                        Button {
                            participationToSelectTeamFor = participation
                            showingSelectTeam = true
                        } label: {
                            let image = participation.isHomeTeam ? "house.fill" : "suitcase.fill"
                            let text = participation.isHomeTeam ? "Home" : "Away"
                            Label("\(text) team", systemImage: image)
                        }
                        .sheet(isPresented: $showingSelectTeam) {
                            NavigationStack {
                                SelectTeamView(selectedTeam: $selectedTeam)
                                    .navigationTitle("Choose Team")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        ToolbarItem(placement: .topBarTrailing) {
                                            Button("Select") {
                                                participationToSelectTeamFor.team = selectedTeam
                                                showingSelectTeam = false
                                                calculateIsConfigurationCompleted()
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            } header: {
                Text("Teams")
            }
            
            Button("Complete") {
                dismiss()
            }
            .disabled(!isConfigurationCompleted)
            
        }
        .interactiveDismissDisabled(!isConfigurationCompleted)
        
            
    }
    
    func calculateIsConfigurationCompleted() {
        isConfigurationCompleted = game.readyToStart
        debugPrint("configuration is completed? \(isConfigurationCompleted)")
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container, assignTeams: false)
    
    games.forEach({data in container.mainContext.insert(data)})

    return NavigationStack {
        ConfigureGame(game: games.first!).modelContainer(container)
    }
}
