//
//  CPU.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

class CPU: ObservableObject {
    
    @Published var load: [CGFloat] = [0.001,0.001,0.001]
    @Published var idle: CGFloat = -1
    @Published var temperature: CGFloat = 0.0
    @Published var system: CGFloat = 0.0
    @Published var nice: CGFloat = 0.0
    @Published var iowait: CGFloat = 0.0
    @Published var steal: CGFloat = 0.0
    
    var celsius: Int {
        return Int((Double(temperature) ) * 0.001)
    }
    
    var fahrenheit: Int {
        let celsius = self.celsius
        if celsius == 0 {
            return 0
        } else {
            return celsius * 9 / 5 + 32
        }
    }
    
    var cpuPercentage: CGFloat {
        return idle == -1 ? 0.001 : 100.0 - idle
    }
    
    init() {}
    
    init(
        rawCPURow: String,
        rawTopRow: String,
        temperatureData: String
    ) {
        update(
            rawCPURow: rawCPURow,
            rawTopRow: rawTopRow,
            temperatureData: temperatureData
        )
    }
    
    func update(
        rawCPURow: String,
        rawTopRow: String,
        temperatureData: String
    ) {
        let cleanedCPUData = removeWhiteSpaceAndNewLines(rawCPURow)
        let cleanedRawTopRow = removeWhiteSpaceAndNewLines(rawTopRow)
        self.idle = parseIdleData(cleanedCPUData)
        self.load = parseLoadData(cleanedRawTopRow)
        self.temperature = parseTemperatureData(temperatureData)
        self.system = parseSystemData(cleanedCPUData)
        self.nice = parseNiceData(cleanedCPUData)
        self.iowait = parseIoWaitData(cleanedCPUData)
        self.steal = parseStealData(cleanedCPUData)
    }
    
    func cache(id: UUID) {
        if ServerCache.shared.cache[id.uuidString] == nil {
            ServerCache.shared.cache[id.uuidString] = .init()
        }
        
        ServerCache.shared.cache[id.uuidString]?["idle"] = self.idle
        ServerCache.shared.cache[id.uuidString]?["load"] = self.load
        ServerCache.shared.cache[id.uuidString]?["temperature"] = self.temperature
        ServerCache.shared.cache[id.uuidString]?["celsius"] = self.celsius
        ServerCache.shared.cache[id.uuidString]?["fahrenheit"] = self.fahrenheit
        ServerCache.shared.cache[id.uuidString]?["system"] = self.system
        ServerCache.shared.cache[id.uuidString]?["nice"] = self.nice
        ServerCache.shared.cache[id.uuidString]?["iowait"] = self.iowait
        ServerCache.shared.cache[id.uuidString]?["steal"] = self.steal
    }
    
    private func removeWhiteSpaceAndNewLines(_ data: String) -> String {
        return data
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
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
