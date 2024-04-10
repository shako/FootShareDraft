//
//  PointSubView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 21/03/2024.
//

import SwiftData
import SwiftUI

struct PointSubView: View {
    @Binding var points: [Point]
    
    let columns = [
//            GridItem(.fixed(4)),
            GridItem(.adaptive(minimum: 50, maximum: 55)),
        ]
    
    var body: some View {
//        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(points, id: \.self.id) { point in
                    Image(systemName: "soccerball")
                        .font(.system(size: CGFloat(50)))
                    Text("Dag Bert").fontWeight(.bold)
                }
            }
//        }


    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    
    return PointSubView(points: .constant([Point(date: .now), Point(date: .now),Point(date: .now),Point(date: .now),Point(date: .now),Point(date: .now),Point(date: .now),Point(date: .now),Point(date: .now)])).modelContainer(container)
}
