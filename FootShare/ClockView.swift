//
//  ClockView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/04/2024.
//

import SwiftUI
import SwiftData

struct ClockView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var clock: Clock
    
    var body: some View {
        ZStack {
            if (!clock.hasEnded) {
                if (clock.inBreak) {
                    HStack() {
                        endGameButton
                        Spacer()
                    }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).padding(.horizontal, 10)
                }
                VStack {
                    time
                    if (clock.inBreak) {
                        clockStatus
                    }
                    
                }
            }
            HStack() {
                Spacer()
                startOrBreakButton
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).padding(.horizontal, 10)
            
        }
    }
    
    var time: some View {
        TimelineView(.periodic(from: clock.runningSince ?? .now, by: 1)) { context in
            Text("\(clock.value?.seconds.convertDurationToString() ?? "00:00")").font(.largeTitle)
        }
    }
    
    var clockStatus: some View {
        switch clock.status {
            case .not_started:
            return AnyView(Text(" ".capitalized))
            case .playing:
            return AnyView(Text("".capitalized))
            case .in_break:
            if let breakNumber = clock.breakNumber, clock.breakNumber! > 1 {
                return AnyView(Text("break \((breakNumber))".capitalized))
            } else {
                return AnyView(Text("break".capitalized))
            }
            case .ended:
            return AnyView(Group {})
        }
    }
    
    var endGameButton: some View {
        let endColor = Color(#colorLiteral(red: 0.9529411793, green: 0, blue: 0.02332801142, alpha: 1))
        
        return ColoredButton(color: endColor, text: "End game", action: clock.end)
    }
    
    var startOrBreakButton: some View {
        let startColor = Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
        let breakColor = Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))

        switch clock.status {
            case .not_started:
            return AnyView(ColoredButton(color: startColor, text: "Start Game", action: resumeClock))
            case .playing:
            return AnyView(ColoredButton(color: breakColor, text: "Break", action: clock.startBreak))
            case .in_break:
            return AnyView(ColoredButton(color: startColor, text: "Resume", action: resumeClock))
            case .ended:
            return AnyView(Group {})

        }
    }
    
    func resumeClock() {
        let session = Session(startTime: Date.now)
        modelContext.insert(session)
        clock.resume(newSession: session)
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Clock.self, configurations: config)
    
    let games = makeFakeData(container: container)
    let game = games.first!

    return NavigationStack {
        ClockView(clock: game.clock).modelContainer(container)
            .frame(maxWidth: .infinity, minHeight: 100).background(.gray.opacity(0.3))
    }
    
}

struct ColoredButton: View {
    let color: Color
    let text: String
    let action: () -> Void
    
    
    var body: some View {
        Button(action: action, label: {
            Text(text)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .background(RoundedRectangle(cornerRadius: 10).fill(color))
                .shadow(color: color, radius: 2, x: 2, y: 2)
        })
    }
}
