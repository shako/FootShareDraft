//
//  GameView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var game: Game
    
    @State var teamEditor = TeamEditor()
    
    @State private var selectedTab = "play"
    @State private var lastSessionIsPlaying = false
    
    @State private var showingInitGame = false

    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
//            if (game.readyToStart) {
                TabView(selection: $selectedTab) {
                    if (!game.clock.hasEnded) {
                        GamePlayView(game: game, refreshAfterUpdateHighlightFunction: refreshGame)
                            .tag("play")
                            .tabItem {
                                Label("Clock", systemImage: "timer")
                            }
                    }

                    if (game.clock.sessions.closed.count > 0 || lastSessionIsPlaying) {
                        GameHighlightsView(sessions: $game.clock.sessions)
                            .tag("summary")
                            .tabItem {
                                Label("", systemImage: "list.bullet")
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .onAppear(perform: {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .red
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.primary).withAlphaComponent(0.8)

                    calculateTabSelection()
                    calculateShowHighlightsAndStats()
                })
                .onChange(of: game.clock.isRunning) { _, _ in
                    debugPrint("Change of clock.isRunning")
                    withAnimation(.snappy) {
                        calculateShowHighlightsAndStats()
                    }
                }
                .onChange(of: game.clock.hasEnded) { _, _ in
                    debugPrint("Change of clock.hasEnded")
                    calculateTabSelection()
                }
                
//            }
        }
        .onAppear(perform: {
            calculateShowingInitGame()
        })
        .sheet(isPresented: $showingInitGame) {
            ConfigureGame(game: game)
                .onDisappear(perform: {
                    calculateShowHighlightsAndStats()
                    refreshGame()
                })
        }

    }
    
    func refreshGame() {
        game.participations = game.participations
        game.clock = game.clock
    }
    
    func calculateShowHighlightsAndStats() {
        lastSessionIsPlaying = (!game.clock.hasEnded && ((game.clock.lastSession?.isPlaying) == true))
        debugPrint("last sessing is playing? \(lastSessionIsPlaying)")
    }
    
    func calculateTabSelection() {
        if (game.clock.hasEnded) {
            selectedTab = "play"
        } else {
            selectedTab = "current"
        }
    }
    
    func calculateShowingInitGame() {
        showingInitGame = !game.readyToStart
        debugPrint("will show init game? \(showingInitGame)")
    }
    
}
    


#Preview("Two Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

#Preview("One Team") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    games.first!.participations.home!.team = nil
    games.first!.participations.home!.points = []
    games.first!.participations.out!.points = []
    games.first!.participations.out!.team?.name = "short"
    games.first!.clock = Clock()

    return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}

#Preview("No Teams") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container, assignTeams: false)
    
    games.forEach({data in container.mainContext.insert(data)})

    return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
}




struct EditableTeam: Identifiable {
    var id: Int
}
