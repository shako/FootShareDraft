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
        VStack {
            if (!clock.hasEnded) {
                time
                buttons
            }
            
        }
    }
    
    var time: some View {
        TimelineView(.periodic(from: clock.runningSince ?? .now, by: 1)) { context in
            Text("\(clock.value?.seconds.convertDurationToString() ?? "00:00")").font(.largeTitle)
        }
    }
    
    var buttons: some View {
        let startColor = Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
        let breakColor = Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
        let endColor = Color(#colorLiteral(red: 0.9529411793, green: 0, blue: 0.02332801142, alpha: 1))
        
        switch clock.status {
            case .not_started:
            return AnyView(ColoredButton(color: startColor, text: "Start Game", action: clock.start))
            case .playing:
            return AnyView(ColoredButton(color: breakColor, text: "Break", action: startBreak))
            case .in_break:
            return AnyView(HStack {
                ColoredButton(color: endColor, text: "End game", action: clock.end)
                ColoredButton(color: startColor, text: "Resume", action: clock.resume)
                }
            )
            case .ended:
            return AnyView(Group {
                
            })

        }
    }
        
    
    func startBreak()  {
        let newBreak = Break(startTime: Date.now)
        modelContext.insert(newBreak)
        clock.startBreak(newBreak: newBreak)
    }

    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Clock.self, configurations: config)
    
    let clocks = makeFakeClockData(container: container)

    return NavigationStack {
        ClockView(clock: clocks.first!).modelContainer(container)
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
                .padding(.all, 10)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .background(RoundedRectangle(cornerRadius: 10).fill(color))
                .shadow(color: color, radius: 2, x: 2, y: 2)
        })
    }
}
