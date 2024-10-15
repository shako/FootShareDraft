//
//  TestView.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 22/03/2024.
//

import SwiftUI

let rows = [
    GridItem(.adaptive(minimum: .infinity, maximum: .infinity)),
    GridItem(.adaptive(minimum: .infinity, maximum: .infinity)),
//    GridItem(.flexible(minimum: .infinity, maximum: .infinity)),
//    GridItem(.flexible(minimum: .infinity, maximum: .infinity)),
//    GridItem(.flexible()),
//    GridItem(.flexible()),
//        GridItem(.flexible(minimum: 10, maximum: 1000)),
    ]

struct TestView: View {
    var body: some View {
        VStack {
            GeometryReader { geo in
                LazyHGrid(rows: rows, alignment: .center) {
                    GridRow {
                        Color.blue
                    }
                    GridRow {
                        Color.red
                    }
                    
                }.frame(maxWidth: .infinity)
            }
            
        }
    }
}

#Preview {
    TestView()
}
