//
//  GameView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

struct GameView: View {
    @Bindable var game: Game
    
    var body: some View {

        VStack {
            VStack() {
                ZStack{
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("\(game.participations.home.team.name)").font(.largeTitle).foregroundStyle(.blue)
                            VStack {
                                Text("\(game.participations.home.score)").font(.system(size: 100))
                            }
                            //                    .foregroundStyle(.white)
                            
                            Button(action: {addPoint(participation: game.participations.home)}, label: {
                                
                                Image(systemName: "soccerball.inverse")
                                    .font(.system(size: CGFloat(50))).foregroundStyle(.blue)
                            })
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).border(.red)
                        
                        Rectangle().frame(height: 40).opacity(0)
                        
                        VStack(alignment: .leading) {
                            Button(action: {addPoint(participation: game.participations.out)}, label: {
                                Image(systemName: "soccerball.inverse")
                                    .font(.system(size: CGFloat(50))).foregroundStyle(.yellow)
                            })
                            
                            VStack {
                                Text("\(game.participations.out.score)").font(.system(size: 100))
                            }
                            
                            Text("\(game.participations.out.team.name)").font(.largeTitle).foregroundStyle(.yellow)

                            //                    .foregroundStyle(.white)
                            

                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading).border(.red)
                        
                    }.frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).border(.green)
                    
                    
                    VStack() {
                        Text("\(game.date.formatted(date: .abbreviated, time: .omitted))").foregroundStyle(.black)
                        Spacer()
                    }
                    
                }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).border(.black)
                
                .padding()
            }
            .foregroundStyle(.white)
            .background() {
                Image("soccer-field")
                    .rotationEffect(.degrees(90))
    //                    .scaledToFit()
                    
                    .scaleEffect(CGSize(width: 0.4, height: 0.4))
                    .opacity(0.9)
            }
                .navigationTitle("\(game.participations.home.team.name) - \(game.participations.out.team.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
//            .padding()
    }
    
    func addPoint(participation: Participation) {
//        
//        debugPrint(participation.sections.count)
//        debugPrint(participation.sections.last?.points.count ?? 0)
        participation.sections.last?.points.append(Point(date: .now))
        game.date = game.date
    }
    
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, configurations: config)
    let context = container.mainContext
    
    let games = makeFakeData()
    games.forEach({data in container.mainContext.insert(data)})
//    let games = makeFakeData()
//    debugPrint("\(games.first!.participations.count)")

    
        return NavigationStack {
        GameView(game: games.first!).modelContainer(container)
    }
    
    
}
