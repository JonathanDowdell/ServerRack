//
//  Swap.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

class Swap: ObservableObject {
    @Published var total: CGFloat = 0.0
    @Published var free: CGFloat = 0.0
    @Published var used: CGFloat = 0.0
    @Published var cache: CGFloat = 0.0
    
    var swapUsed: CGFloat {
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    init() {}
    
    init(rawSwapRow: String) {
        update(rawSwapRow: rawSwapRow)
    }
    
    func update(rawSwapRow: String) {
        let cleanedSwapRow = removeWhiteSpaceAndNewLines(rawSwapRow)
        
        self.total = parseData(cleanedSwapRow, regex: "\\d*.\\d*total")
        self.free = parseData(cleanedSwapRow, regex: "\\d*.\\d*free")
        self.used = parseData(cleanedSwapRow, regex: "\\d*.\\d*used")
        self.cache = parseData(cleanedSwapRow, regex: "\\d*.\\d*avail")
    }
    
    func cache(id: UUID) {
        if ServerCache.shared.cache[id.uuidString] == nil {
            ServerCache.shared.cache[id.uuidString] = .init()
        }
        
        ServerCache.shared.cache[id.uuidString]?["total"] = self.total
        ServerCache.shared.cache[id.uuidString]?["free"] = self.free
        ServerCache.shared.cache[id.uuidString]?["used"] = self.used
        ServerCache.shared.cache[id.uuidString]?["cache"] = self.cache
        ServerCache.shared.cache[id.uuidString]?["swapUsed"] = self.swapUsed
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
