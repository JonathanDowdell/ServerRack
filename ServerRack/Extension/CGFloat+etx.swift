//
//  CGFloat+etx.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/9/22.
//

import SwiftUI

extension CGFloat {
    func humanizeMiBMemory() -> String {
        if self > 953.674 {
            let gb = self * 0.001048576
            return String(format: "%.1f", gb)
        } else {
            return String(Int(self))
        }
    }
    
    func humanizeMiBMemoryMetric() -> String {
        if self > 953.674 {
            return "G"
        } else {
            return "M"
        }
    }
    
    
    
}

extension Int {

    func suffixNumber () -> String {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        
        let abbreviations:[Abbrevation] = [
            (0, 1, ""),
            (1000.0, 1000.0, "K"),
            (100_000.0, 1_000_000.0, "M"),
            (100_000_000.0, 1_000_000_000.0, "B")
        ]

        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber (value:value))!
    }
}
