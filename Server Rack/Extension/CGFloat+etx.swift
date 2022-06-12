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
