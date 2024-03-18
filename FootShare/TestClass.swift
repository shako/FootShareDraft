//
//  TestClass.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 16/03/2024.
//

import Foundation

@Observable
class TestClass {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
