//
//  Swap.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI
import Combine

struct Swap {
    var total: CGFloat = 0.0
    var free: CGFloat = 0.0
    var used: CGFloat = 0.0
    var cache: CGFloat = 0.0
    
    var swapPercentageUsed: CGFloat {
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    private weak var sshConnection: SSHConnection?
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    mutating func update(rawSwapRow: String) {
        let cleanedSwapRow = removeWhiteSpaceAndNewLines(rawSwapRow)
        
        self.total = parseData(cleanedSwapRow, regex: "\\d*.\\d*total")
        self.free = parseData(cleanedSwapRow, regex: "\\d*.\\d*free")
        self.used = parseData(cleanedSwapRow, regex: "\\d*.\\d*used")
        self.cache = parseData(cleanedSwapRow, regex: "\\d*.\\d*avail")
    }
    
    @MainActor
    mutating func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawSwapRowData = (try? await sshConnection.send(command: Commands.TopSwap.rawValue) ?? "") ?? ""
        let id = sshConnection.server.id
        
        update(rawSwapRow: rawSwapRowData)
        cache(id: id)
    }
    
    func cache(id: UUID) {
        if ServerCache.shared.cache[id.uuidString] == nil {
            ServerCache.shared.cache[id.uuidString] = .init()
        }
        
        ServerCache.shared.cache[id.uuidString]?["total"] = self.total
        ServerCache.shared.cache[id.uuidString]?["free"] = self.free
        ServerCache.shared.cache[id.uuidString]?["used"] = self.used
        ServerCache.shared.cache[id.uuidString]?["cache"] = self.cache
        ServerCache.shared.cache[id.uuidString]?["swapPercentageUsed"] = self.swapPercentageUsed
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

class SWAP {
    var total = CurrentValueSubject<CGFloat, Never>(0.0)
    var free = CurrentValueSubject<CGFloat, Never>(0.0)
    var used = CurrentValueSubject<CGFloat, Never>(0.0)
    var cache = CurrentValueSubject<CGFloat, Never>(0.0)
    
    var swapPercentageUsed: CGFloat {
        if total.value != 0 {
            return (used.value / total.value) * 1000
        } else {
            return 0.001
        }
    }
    
    private weak var sshConnection: SSHConnection?
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    func update(rawSwapRow: String) {
        let cleanedSwapRow = removeWhiteSpaceAndNewLines(rawSwapRow)
        
        self.total.send(parseData(cleanedSwapRow, regex: "\\d*.\\d*total"))
        self.free.send(parseData(cleanedSwapRow, regex: "\\d*.\\d*free"))
        self.used.send(parseData(cleanedSwapRow, regex: "\\d*.\\d*used"))
        self.cache.send(parseData(cleanedSwapRow, regex: "\\d*.\\d*avail"))
    }
    
    @MainActor
    func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawSwapRowData = (try? await sshConnection.send(command: Commands.TopSwap.rawValue) ?? "") ?? ""
        update(rawSwapRow: rawSwapRowData)
    }
    
    func cache(id: UUID) {
//        if ServerCache.shared.cache[id.uuidString] == nil {
//            ServerCache.shared.cache[id.uuidString] = .init()
//        }
//
//        ServerCache.shared.cache[id.uuidString]?["total"] = self.total
//        ServerCache.shared.cache[id.uuidString]?["free"] = self.free
//        ServerCache.shared.cache[id.uuidString]?["used"] = self.used
//        ServerCache.shared.cache[id.uuidString]?["cache"] = self.cache
//        ServerCache.shared.cache[id.uuidString]?["swapPercentageUsed"] = self.swapPercentageUsed
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
