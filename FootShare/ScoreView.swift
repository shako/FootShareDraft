//
//  ScoreView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 16/03/2024.
//

import SwiftData
import SwiftUI

struct ScoreView: View {
//    @Bindable var participation: Participation
    @Bindable var testclass: TestClass
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    let games = makeFakeData()
    var participation = games.first!.participations
    
    
//    return ScoreView(participation: participation)
//    return ScoreView(participation: participation).modelContainer(container)
    
    return ScoreView(testclass: TestClass(name: "Steven", age: 39))/*.modelContainer(container)*/
}
