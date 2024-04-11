//
//  Utils.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 11/04/2024.
//

import Foundation

func isLeftToRight() -> Bool {
    guard let languageIdentifier = Locale.current.language.languageCode?.identifier else { return true }
    let direction = Locale.Language(identifier: languageIdentifier).characterDirection
    return direction == .leftToRight || direction == .unknown
}
