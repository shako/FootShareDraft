//
//  HighlightView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/04/2024.
//

import SwiftData
import SwiftUI

struct HighlightView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var clock: Clock
    var points: [Point]
    var refreshAction: (() -> Void)?
    
    var body: some View {
        TabView {
            if clock.hasEnded {
                
                VStack {
                    Text("All Sessions")
                    HighLightListView(clock: clock, points: points)
                }
                .tabItem { Label("", systemImage: "list.bullet") }

                ForEach(clock.sessions.lastToFirst.indices, id: \.self) { index in
                    let session = clock.sessions.firstToLast[index]
                    
                    HighLightListView(clock: clock, points: points.madeDuring(session))
                        .tabItem { Label("", systemImage: "\(index + 1).square") }
                }

            } else {
                
                VStack {
                    Text("Session \(clock.sessions.count)")
                    ClockView(clock: clock)
                    if let ongoingSession = clock.sessions.ongoing {
                        HighLightListView(clock: clock, points: points.madeDuring(ongoingSession))
                    }
                }.tabItem { Label("Clock", systemImage: "timer") }
                
                ForEach(clock.sessions.past.firstToLast.indices, id: \.self) { index in
                    let session = clock.sessions.past.firstToLast[index]
                    
                    VStack {
                        Text("Session \(index + 1)")
                        HighLightListView(clock: clock, points: points.madeDuring(session))
                    }
                        .tabItem { Label("", systemImage: "\(index + 1).square") }
                }
                
            }

        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear(perform: {
            UIPageControl.appearance().currentPageIndicatorTintColor = .red
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        })
    }
    
    func removePoint(indexSet: IndexSet) {
        for index in indexSet {
            let point = pointsSorted()[index]
            modelContext.delete(point)
            try? modelContext.save()
        }
        refreshAction?()
    }
    
    func pointsSorted() -> [Point] {
        points.sorted(by: { pointl, pointr in
            pointl.date > pointr.date
        })
    }
}

struct HighLightListView: View {
    
    var clock: Clock
    var points: [Point]
    
    var body: some View {
        if points.isEmpty {
            AnyView(Text("No points scored!"))
        } else {

//                                Text("Goals").font(.callout)
            AnyView(
                List {
                    ForEach(points, id: \.id) { point in
                        HighlightEntryView(point: point, clock: clock)
                    }
    //                .onDelete(perform: removePoint)
    //                .deleteDisabled(game.clock.hasEnded)
                }.listStyle(.inset)
            )
        }
    }
}

struct HighlightEntryView: View {
    let point: Point
    let clock: Clock
    
    var body: some View {
        
        HStack {
            Image(systemName: "soccerball.inverse").rotationEffect(.degrees(Double(Int.random(in: 0...360))))
            Text("\(formatHighlightTime(seconds: clock.sessions.playTimeUpTo(date: point.date))) - \(point.participation?.team?.name ?? "unknown")")
                .font(.callout)
        }
        .padding(.leading, -5)
    }
    
    func formatHighlightTime(seconds: Double) -> String {
        let minutes = Int(((seconds) / 60).rounded(.up))
        return "\(minutes)'" // (\(Int(seconds.rounded(.up))) secs)
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!
        return NavigationStack {
            HighlightView(clock: .constant(game.clock), points: game.participations.first!.points).modelContainer(container)
            Spacer()
    }
}
