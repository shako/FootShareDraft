//
//  FootShareApp.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 15/03/2024.
//

import SwiftData
import SwiftUI

@main
struct FootShareApp: App {
    init() {
            ValueTransformer.setValueTransformer(UIColorValueTransformer(), forName: NSValueTransformerName("UIColorValueTransformer"))
        }
    
    var body: some Scene {
        WindowGroup {
            GameListView()
        }
        .modelContainer(for: Game.self)
    }
}
