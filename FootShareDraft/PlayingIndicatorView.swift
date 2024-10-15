//
//  PlayingIndicatorView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 16/08/2024.
//

import SwiftUI

struct PlayingIndicatorView: View {
    @State private var pulsate: Bool = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.green)
                .scaleEffect(scale)
                .onAppear {
                    pulsateAnimation(delay: false)
                }
            
//            Circle()
//                .foregroundStyle(Color.green.opacity(0.3))
//                .scaleEffect(scale)
//                .onAppear {
//                    pulsateAnimation(delay: true)
//                }
            
        }
        

    }
    
    private func pulsateAnimation(delay: Bool) {
        withAnimation(Animation.easeInOut(duration: 1.0).delay(delay ? 0 : 0.2)) {
            scale = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.interactiveSpring) {
                scale = 0.8
            }
            
            DispatchQueue.main.async {
                pulsateAnimation(delay: delay)
            }
        }
    }
}

#Preview {
    PlayingIndicatorView()
        .frame(width: 20, height: 20)
    
}
