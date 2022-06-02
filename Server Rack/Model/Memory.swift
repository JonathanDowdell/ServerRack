//
//  Memory.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

/// Memory Data from Server
class Memory: ObservableObject {
    /// Total installed memory - MiB
    @Published var total: CGFloat = 0.0
    
    /// Unused memory - MiB
    @Published var free: CGFloat = 0.0
    
    /// Used memory - MiB
    @Published var used: CGFloat = 0.0
    
    /// Memory used by the page cache and slabs - MiB
    @Published var cache: CGFloat = 0.0
    
    var memoryUsed: CGFloat {
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    
    init() {}
    
    init(rawMemRow: String) {
        update(rawMemRow: rawMemRow)
    }
    
    func update(rawMemRow: String) {
        let cleanedMemData = removeWhiteSpaceAndNewLines(rawMemRow)
        self.total = parseData(cleanedMemData, regex: "\\d*.\\d*total")
        self.free = parseData(cleanedMemData, regex: "\\d*.\\d*free")
        self.used = parseData(cleanedMemData, regex: "\\d*.\\d*used")
        self.cache = parseData(cleanedMemData, regex: "\\d*.\\d*buff")
    }
    
    private func removeWhiteSpaceAndNewLines(_ data: String) -> String {
        return data
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func parseData(_ data: String, regex: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: regex).first,
            let raw = array.first?.trimmingCharacters(in: .letters),
            let data = Double(raw)
        else { return 0.0 }
        
        return data
    }
    
}
