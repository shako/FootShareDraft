//
//  Utils.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 11/04/2024.
//

import UIKit
import Foundation

func isLeftToRight() -> Bool {
    guard let languageIdentifier = Locale.current.language.languageCode?.identifier else { return true }
    let direction = Locale.Language(identifier: languageIdentifier).characterDirection
    return direction == .leftToRight || direction == .unknown
}

@objc(UIColorValueTransformer) // The solution is adding this line
final class UIColorValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    
    // return data
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            return nil
        }
    }
    
    // return UIColor
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
            return color
        } catch {
            return nil
        }
    }
}
