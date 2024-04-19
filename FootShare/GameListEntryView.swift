//
//  GameListEntryView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 19/04/2024.
//

import SwiftData
import SwiftUI

struct GameListEntryView: View {
    var participations: [Participation]
    
    var body: some View {
        VStack {
            let homeParticipation = participations.homeFirst().first
            let outParticipation = participations.homeFirst().last
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(homeParticipation?.team?.name ?? "")
                        .overlay(
                                GeometryReader { proxy in
                                    Rectangle()
                                        .fill(Color(homeParticipation?.team?.color ?? UIColor(Color.accentColor)))
                                        .offset(x: -7)
                                        .offset(y: -7)
                                        .frame(width: proxy.size.width + 7, height: 7)
                                }
                        )
                        .font(.callout)
//                        .underline(pattern: .solid, color: .red)
//                        .fontWeight(.semibold)
                        .frame(alignment: .leading)

                }
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)

            
            HStack {
                Text("\(String(homeParticipation?.score ?? 0))").font(.title)
                Text("-").font(.title)
                Text("\(String(outParticipation?.score ?? 0))").font(.title)
            }
            
            HStack {
                Text(outParticipation?.team?.name ?? "")
                    .overlay(
                            GeometryReader { proxy in
                                Rectangle()
                                    .fill(Color(outParticipation?.team?.color ?? UIColor(Color.accentColor)))
//                                    .offset(x: 18)
                                    .offset(y: 22)
                                    .frame(width: proxy.size.width, height: 7)
                            }
                    )
                    .font(.callout)
//                    .font(.title2)
//                    .underline(pattern: .solid, color: .green)
//                    .fontWeight(.semibold)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
            
        }.frame(maxWidth: .infinity)
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    
    let games = makeFakeData(container: container)
        return NavigationStack {
            GameListEntryView(participations: games.first!.participations).modelContainer(container)
                .padding().background(Color.gray.opacity(0.2))


    }
}

//                        .overlay(
//                                GeometryReader { proxy in
//                                    Rectangle()
//                                        .fill(.red)
//                                        .offset(x: -7)
//                                        .offset(y: -7)
//                                        .frame(width: proxy.size.width + 7, height: 4)
//                                }
//                        )
//                        .overlay(
//                                GeometryReader { proxy in
//                                    Rectangle()
//                                        .fill(.red)
//                                        .offset(x: -7)
//                                        .offset(y: -7)
//                                        .frame(width: 4, height: proxy.size.height + 7)
//                                }
//                        )
