//
//  Memory.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

/// Memory Data from Server
struct Memory {
    /// Total installed memory - MiB
    var total: CGFloat = 0.0
    
    func total(cached: Bool) -> CGFloat {
        if !cached {
            return self.total
        } else {
            guard
                let id = sshConnection?.server.id.uuidString,
                let memoryTotal = ServerCache.shared.cache[id]?["memoryTotal"] as? CGFloat
            else { return 0.001 }
            return memoryTotal
        }
    }
    
    /// Unused memory - MiB
    var free: CGFloat = 0.0
    
    func free(cached: Bool) -> CGFloat {
        if !cached {
            return self.free
        } else {
            guard
                let id = sshConnection?.server.id.uuidString,
                let memoryFree = ServerCache.shared.cache[id]?["memoryFree"] as? CGFloat
            else { return 0.001 }
            return memoryFree
        }
    }
    
    /// Used memory - MiB
    var used: CGFloat = 0.0
    
    func used(cached: Bool) -> CGFloat {
        if !cached {
            return self.used
        } else {
            guard
                let id = sshConnection?.server.id.uuidString,
                let memoryUsed = ServerCache.shared.cache[id]?["memoryUsed"] as? CGFloat
            else { return 0.001 }
            return memoryUsed
        }
    }
    
    /// Memory used by the page cache and slabs - MiB
    var cache: CGFloat = 0.0
    
    func cache(cached: Bool) -> CGFloat {
        if !cached {
            return self.cache
        } else {
            guard
                let id = sshConnection?.server.id.uuidString,
                let memoryCacheUsed = ServerCache.shared.cache[id]?["memoryCacheUsed"] as? CGFloat
            else { return 0.001 }
            return memoryCacheUsed
        }
    }
    
    func memoryPercentageUsed(cached: Bool) -> CGFloat {
        let used = used(cached: cached)
        let total = total(cached: cached)
        guard !(total == 0.001 && used == 0.001) else { return 0.001 }
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    private weak var sshConnection: SSHConnection?
    
    private var cacheManager: NSCache<NSString, NSObject> {
        return ServerCache.shared.nsCache
    }
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    init(rawMemRow: String) {
        update(rawMemRow: rawMemRow)
    }
    
    mutating func update(rawMemRow: String) {
        let cleanedMemData = removeWhiteSpaceAndNewLines(rawMemRow)
        self.total = parseData(cleanedMemData, regex: "\\d*.\\d*total")
        self.free = parseData(cleanedMemData, regex: "\\d*.\\d*free")
        self.used = parseData(cleanedMemData, regex: "\\d*.\\d*used")
        self.cache = parseData(cleanedMemData, regex: "\\d*.\\d*buff")
    }
    
    @MainActor
    mutating func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawMemRowData = (try? await sshConnection.send(command: Commands.TopMem.rawValue) ?? "") ?? ""
        let id = sshConnection.server.id
        
        update(rawMemRow: rawMemRowData)
        cache(id: id)
    }
    
    func cache(id: UUID) {
        if ServerCache.shared.cache[id.uuidString] == nil {
            ServerCache.shared.cache[id.uuidString] = .init()
        }
        ServerCache.shared.cache[id.uuidString]?["memoryTotal"] = self.total
        ServerCache.shared.cache[id.uuidString]?["memoryFree"] = self.free
        ServerCache.shared.cache[id.uuidString]?["memoryUsed"] = self.used
        ServerCache.shared.cache[id.uuidString]?["memoryCacheUsed"] = self.cache
        ServerCache.shared.cache[id.uuidString]?["memoryPercentageUsed"] = self.memoryPercentageUsed
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
