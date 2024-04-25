//
//  TestTabView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 24/04/2024.
//

import SwiftUI

struct TestTabView: View {
    
//    init() {
//       UIPageControl.appearance().currentPageIndicatorTintColor = .red
//       UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
//       }
    
    var body: some View {
        TabView {
            ForEach(0..<2) { number in
                Text("Test number \(number)")
                    .tabItem{
                        if (number == 0) {
                            Label("number: \(number)", systemImage: "list.bullet.circle.fill")
                        } else {
                            Label("number: \(number)", systemImage: "\(number).circle")
                        }
                    }
            }

            
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    TestTabView()
}
