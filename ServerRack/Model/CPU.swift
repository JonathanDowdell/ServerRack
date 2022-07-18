//
//  CPU.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI
import Combine

class CPU: ObservableObject {
    
    // MARK: Temperature
    var temperature = CurrentValueSubject<CGFloat, Never>(0.0)
    
    // MARK: Celsius
    var celsius: Int {
        return Int((Double(temperature.value) ) * 0.001)
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
    
    // MARK: Total Idle Usage
    var totalIdleUsage: CGFloat {
        let cores = cores.value
        guard cores.count != 0 else { return -1 }
        return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
    }
    
    // MARK: Load
    var load = CurrentValueSubject<[CGFloat], Never>([0.001,0.001,0.001])
    
    // MARK: Cores
    var cores = CurrentValueSubject<[Core], Never>(.init())
    
    // MARK: Tasks
    var tasks = CurrentValueSubject<Tasks, Never>(.init())
    
    private weak var sshConnection: SSHConnection?
    
    private var serverCache: ServerCache {
        return ServerCache.shared
    }
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    func update(
        rawCpuCoreData: String,
        rawTopRow: String,
        rawTaskData: String,
        temperatureData: String
    ) {
        let cleanedCPUCoreData = removeWhiteSpaceAndNewLines(rawCpuCoreData)
        let cleanedRawTopRow = removeWhiteSpaceAndNewLines(rawTopRow)
        let cleanedRawTaskData = removeWhiteSpaceAndNewLines(rawTaskData)
        self.cores.send(parseCpuCoreData(cleanedCPUCoreData))
        self.load.send(parseLoadData(cleanedRawTopRow))
        self.tasks.send(parseTasksData(cleanedRawTaskData))
        self.temperature.send(parseTemperatureData(temperatureData))
    }
    
    @MainActor
    func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawCpuCoreData = (try? await sshConnection.send(command: Commands.TopCPUCore.rawValue) ?? "") ?? ""
        let rawTopRowData = (try? await sshConnection.send(command: Commands.TopTop.rawValue) ?? "") ?? ""
        let rawTaskData = (try? await sshConnection.send(command: Commands.TopTask.rawValue) ?? "") ?? ""
        let temperatureData = (try? await sshConnection.send(command: Commands.SysHwmonTemp.rawValue) ?? "") ?? ""
        update(
            rawCpuCoreData: rawCpuCoreData,
            rawTopRow: rawTopRowData,
            rawTaskData: rawTaskData,
            temperatureData: temperatureData
        )
    }
    
    func cache(id: UUID) {
//        var cacheDict: [String: Any] = .init()
//        cacheDict["load"] = self.load
//        cacheDict["temperature"] = self.temperature
//        cacheDict["celsius"] = self.celsius
//        cacheDict["fahrenheit"] = self.fahrenheit
//        cacheDict["cores"] = self.cores
//
//        serverCache.cache[id.uuidString] = cacheDict
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
    
    private func parseTasksData(_ data: String) -> Tasks  {
        var tasks = Tasks()
        if let rawTotal = data.matchingStrings(regex: "(\\d+total)").first?.first?.trimmingCharacters(in: .letters),
           let total = Int(rawTotal) {
            tasks.total = total
        }
        
        if let rawRunning = data.matchingStrings(regex: "(\\d+running)").first?.first?.trimmingCharacters(in: .letters),
           let running = Int(rawRunning) {
            tasks.running = running
        }
        
        if let rawSleeping = data.matchingStrings(regex: "(\\d+sleeping)").first?.first?.trimmingCharacters(in: .letters),
           let sleeping = Int(rawSleeping) {
            tasks.sleeping = sleeping
        }
        
        if let rawStopped = data.matchingStrings(regex: "(\\d+stopped)").first?.first?.trimmingCharacters(in: .letters),
           let stopped = Int(rawStopped) {
            tasks.stopped = stopped
        }
        
        if let rawZombie = data.matchingStrings(regex: "(\\d+zombie)").first?.first?.trimmingCharacters(in: .letters),
           let zombie = Int(rawZombie) {
            tasks.zombie = zombie
        }
        
        return tasks
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
