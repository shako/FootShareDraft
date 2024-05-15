//
//  BallView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 14/05/2024.
//

import SwiftUI

enum ScoringTarget: String {
    case leading, trailing, none
}

struct BallView: View {
    @State var goalMarkerOffset: CGSize = CGSize.zero
    @State var movingGoalMarker: Bool = false
    @State var randomBallAngle = Double.random(in: 1..<45)
    @Binding var scoringTarget: ScoringTarget
    var scoreGoalFunction: ((ScoringTarget) -> Void)
    
    var body: some View {
        Text("⚽️")
            .font(.system(size: 70))
            .rotationEffect(Angle(degrees: randomBallAngle))
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .shadow(color: .black.opacity(0.5), radius: 5, x: 1, y: 0.5)
            .offset(goalMarkerOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if (!movingGoalMarker) {
                            if (goalMarkerOffset.height < -50) {
                                withAnimation {
                                    movingGoalMarker = true
                                }
                            }

                        }
                        else {
                            if (goalMarkerOffset.height >= -50) {
                                scoringTarget = .none
                                withAnimation {
                                    movingGoalMarker = false
                                }
                            }
                            
                            if isPreparingToScoreFor(0) {
                                scoringTarget = .leading
                            } else if isPreparingToScoreFor(1) {
                                scoringTarget = .trailing
                            } else {
                                scoringTarget = .none
                            }
                        }
                        
                        withAnimation(.easeOut) {
                            goalMarkerOffset = value.translation
                        }
                        
                    }
                    .onEnded { value in
                        withAnimation {
                            scoreGoalFunction(scoringTarget)
                            scoringTarget = .none
                            movingGoalMarker = false
                        }
                        
                        withAnimation(.default) {
                            goalMarkerOffset = .zero
                        }
                    }
            )
    }
    
    func isScoreMarkerLocationLeft() -> Bool {
        return goalMarkerOffset.width <= 0
    }
    
    func isPreparingToScoreFor(_ index: Int) -> Bool {
        let isPointingLeft = isLeftToRight() && isScoreMarkerLocationLeft()
        let isLeftScoreBoard = index == 0
        if movingGoalMarker && ((isPointingLeft && isLeftScoreBoard) || (!isPointingLeft && !isLeftScoreBoard)) {
            return true
        }
        return false
    }
}

#Preview {
    @State var scoringTarget: ScoringTarget = .none
    return VStack {
        BallView(scoringTarget: $scoringTarget, scoreGoalFunction: mockScoreGoalFunction)
    }
    
    func mockScoreGoalFunction(scoringTarget: ScoringTarget) {
        debugPrint("Scoring goal for: \(scoringTarget.rawValue)")
    }

}
