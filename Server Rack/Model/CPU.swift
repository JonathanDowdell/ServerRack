//
//  CPU.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct CPU {
    
    // MARK: Temperature
    var temperature: CGFloat = 0.0
    
    func temperature(cached: Bool) -> CGFloat {
        if !cached {
            return self.temperature
        } else {
            // Get Cached
            guard
                let id = sshConnection?.server.id.uuidString,
                let temperature = serverCache.cache[id]?["temperature"] as? CGFloat
            else { return 0 }
            return temperature
        }
    }
    
    // MARK: Load
    var load: [CGFloat] = [0.001,0.001,0.001]
    
    func load(cached: Bool) -> [CGFloat] {
        if !cached {
            return self.load
        } else {
            // Get Cached
            guard
                let id = sshConnection?.server.id.uuidString,
                let load = serverCache.cache[id]?["load"] as? [CGFloat]
            else { return [0.007,0.007,0.007] }
            return load
        }
    }
    
    // MARK: Celsius
    var celsius: Int {
        return Int((Double(temperature) ) * 0.001)
    }
    
    func celsius(cached: Bool) -> Int {
        if !cached {
            return self.fahrenheit
        } else {
            // Get Cached
            guard
                let id = sshConnection?.server.id.uuidString,
                let celsius = serverCache.cache[id]?["celsius"] as? Int
            else { return 0 }
            return celsius
        }
    }
    
    // MARK: Fahrenheit
    var fahrenheit: Int {
        let celsius = self.celsius
        if celsius == 0 {
            return 0
        } else {
            return celsius * 9 / 5 + 32
        }
    }
    
    func fahrenheit(cached: Bool) -> Int {
        if !cached {
            return fahrenheit
        } else {
            // Get Cached
            guard
                let id = sshConnection?.server.id.uuidString,
                let fahrenheit = serverCache.cache[id]?["fahrenheit"] as? Int
            else { return 0 }
            return fahrenheit
        }
    }
    
    // MARK: Cores
    var cores: [Core] = .init()
    
    func cores(cached: Bool) -> [Core] {
        if !cached {
            return self.cores
        } else {
            // Get Cached
            guard
                let id = sshConnection?.server.id.uuidString,
                let cores = serverCache.cache[id]?["cores"] as? [Core]
            else { return .init() }
            return cores
        }
    }
    
    func totalSystemUsage(cached: Bool) -> CGFloat {
        let cores = cores(cached: cached)
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.system }.reduce(0, +) / Double(cores.count)
    }
    
    func totalUserUsage(cached: Bool) -> CGFloat {
        let cores = cores(cached: cached)
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.user }.reduce(0, +) / Double(cores.count)
    }
    
    func totalIOWaitUsage(cached: Bool) -> CGFloat {
        let cores = cores(cached: cached)
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.iowait }.reduce(0, +) / Double(cores.count)
    }
    
    func totalStealUsage(cached: Bool) -> CGFloat {
        let cores = cores(cached: cached)
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.steal }.reduce(0, +) / Double(cores.count)
    }
    
    func totalIdleUsage(cached: Bool) -> CGFloat {
        let cores = cores(cached: cached)
        guard cores.count != 0 else { return -1 }
        return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
    }
    
    private weak var sshConnection: SSHConnection?
    
    private var serverCache: ServerCache {
        return ServerCache.shared
    }
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    
    
    mutating func update(
        rawCpuCoreData: String,
        rawTopRow: String,
        temperatureData: String
    ) {
        let cleanedCPUCoreData = removeWhiteSpaceAndNewLines(rawCpuCoreData)
        let cleanedRawTopRow = removeWhiteSpaceAndNewLines(rawTopRow)
        
        self.cores = parseCpuCoreData(cleanedCPUCoreData)
        self.load = parseLoadData(cleanedRawTopRow)
        self.temperature = parseTemperatureData(temperatureData)
    }
    
    @MainActor
    mutating func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawCpuCoreData = (try? await sshConnection.send(command: Commands.TopCPUCore.rawValue) ?? "") ?? ""
        let rawTopRowData = (try? await sshConnection.send(command: Commands.TopTop.rawValue) ?? "") ?? ""
        let temperatureData = (try? await sshConnection.send(command: Commands.SysHwmonTemp.rawValue) ?? "") ?? ""
        let id = sshConnection.server.id
        update(rawCpuCoreData: rawCpuCoreData, rawTopRow: rawTopRowData, temperatureData: temperatureData)
        cache(id: id)
    }
    
    func cache(id: UUID) {
        var cacheDict: [String: Any] = .init()
        cacheDict["load"] = self.load
        cacheDict["temperature"] = self.temperature
        cacheDict["celsius"] = self.celsius
        cacheDict["fahrenheit"] = self.fahrenheit
        cacheDict["cores"] = self.cores
        
        serverCache.cache[id.uuidString] = cacheDict
    }
    
    private func removeWhiteSpaceAndNewLines(_ data: String) -> String {
        return data
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func parseCpuCoreData(_ data: String) -> [Core] {
        let data = data.components(separatedBy: "%").filter { !$0.isEmpty }
        return data.compactMap {
            guard
                let rawCoreData = $0.matchingStrings(regex: "^cpu\\d").first?.first,
                let coreNumber = Int(rawCoreData.trimmingCharacters(in: .letters))
            else { return nil }
            var core = Core(coreNumber)
            if let rawUser = $0.matchingStrings(regex: "(\\d+\\.\\dus)").first?.first?.trimmingCharacters(in: .letters),
               let user = Double(rawUser) {
                core.user = user
            }
            
            if let rawSystem = $0.matchingStrings(regex: "(\\d+\\.\\dsy)").first?.first?.trimmingCharacters(in: .letters),
               let system = Double(rawSystem) {
                core.system = system
            }
            
            if let rawNice = $0.matchingStrings(regex: "(\\d+\\.\\dni)").first?.first?.trimmingCharacters(in: .letters),
               let nice = Double(rawNice) {
                core.nice = nice
            }
            
            if let rawIdle = $0.matchingStrings(regex: "(\\d+\\.\\did)").first?.first?.trimmingCharacters(in: .letters),
               let idle = Double(rawIdle) {
                core.idle = idle
            }
            
            if let rawIowait = $0.matchingStrings(regex: "(\\d+\\.\\dwa)").first?.first?.trimmingCharacters(in: .letters),
               let iowait = Double(rawIowait) {
                core.iowait = iowait
            }
            
            if let rawSteal = $0.matchingStrings(regex: "(\\d+\\.\\dst)").first?.first?.trimmingCharacters(in: .letters),
               let steal = Double(rawSteal){
                core.steal = steal
            }
            
            return core
        }
    }
    
    private func parseTemperatureData(_ data: String) -> CGFloat {
        return CGFloat(Double(data.trimmingCharacters(in: .newlines)) ?? 0)
    }
    
    private func parseIdleData(_ data: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: "(\\d+\\.\\d[id])").first,
            let rawIdle = array.first?.trimmingCharacters(in: .letters),
            let idle = Double(rawIdle)
        else { return -1.0 }
        return idle
    }
    
    private func parseLoadData(_ data: String) -> [CGFloat] {
        guard
            let array = data.matchingStrings(regex: "loadaverage:\\d*\\.\\d*,\\d*\\.\\d*,\\d*\\.\\d*").first,
            let raw = array.first?.trimmingCharacters(in: .letters)
                .replacingOccurrences(of: ":", with: "")
        else { return [0.01,0.01,0.01] }
        
        return raw.components(separatedBy: ",").map { CGFloat(Double($0) ?? 0.01) }.map { max(0.001, CGFloat($0)) * 100 }
    }
    
    private func parseSystemData(_ data: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: "\\d*.\\d*sy").first,
            let raw = array.first?.trimmingCharacters(in: .letters),
            let system = Double(raw)
        else { return 0.0 }
        
        return system
    }
    
    private func parseNiceData(_ data: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: "\\d*.\\d*ni").first,
            let raw = array.first?.trimmingCharacters(in: .letters),
            let nice = Double(raw)
        else { return 0.0 }
        return nice
    }
    
    private func parseIoWaitData(_ data: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: "\\d*.\\d*wa").first,
            let raw = array.first?.trimmingCharacters(in: .letters),
            let iowait = Double(raw)
        else { return 0.0 }
        return iowait
    }
    
    private func parseStealData(_ data: String) -> CGFloat {
        guard
            let array = data.matchingStrings(regex: "\\d*.\\d*st").first,
            let raw = array.first?.trimmingCharacters(in: .letters),
            let steal = Double(raw)
        else { return 0.0 }
        return steal
    }
}
