//
//  Utils.swift
//  FootShare
//
//  Created by Steven Machtelinckx on 11/04/2024.
//

import UIKit
import Foundation
import SwiftUI

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

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

extension TimeInterval {

    var seconds: Int {
        return Int(self.rounded())
    }
    
}

extension Int {
    
    public func hmsFrom() -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    public func convertDurationToString() -> String {
        var duration = ""
        let (hour, minute, second) = self.hmsFrom()
        if (hour > 0) {
            duration = self.getHour(hour: hour)
        }
        return "\(duration)\(self.getMinute(minute: minute))\(self.getSecond(second: second))"
    }
    
    private func getHour(hour: Int) -> String {
        var duration = "\(hour):"
        if (hour < 10) {
            duration = "0\(hour):"
        }
        return duration
    }
    
    private func getMinute(minute: Int) -> String {
        if (minute == 0) {
            return "00:"
        }

        if (minute < 10) {
            return "0\(minute):"
        }

        return "\(minute):"
    }
    
    private func getSecond(second: Int) -> String {
        if (second == 0){
            return "00"
        }

        if (second < 10) {
            return "0\(second)"
        }
        return "\(second)"
    }
}

extension ShapeStyle where Self == Color 
{
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
