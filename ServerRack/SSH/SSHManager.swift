//
//  SSHManager.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/12/22.
//

import SwiftUI
import Combine

class SSHManager: ObservableObject {
    
    static let shared = SSHManager()
    
    private var cancellableSet = Set<AnyCancellable>()
    
    @Published var sshConnections = [SSHConnectionWrapper].init()
    
    init(
        serverPublisher: AnyPublisher<[Server], Never> = ServerStorage.shared.servers.eraseToAnyPublisher()
    ) {
        serverPublisher.sink { servers in
            self.sshConnections = servers.map { SSHConnectionWrapper(sshConnection: SSHConnection($0)) }
        }
        .store(in: &cancellableSet)
    }
    
    func connectAll() {
        for sshConnection in sshConnections {
            Task {
                try await sshConnection.connection.connect()
            }
        }
    }
    
    func disConnectAll() {
        for sshConnection in sshConnections {
            Task {
                try await sshConnection.connection.disconnect()
            }
        }
    }
    
    func removeConnection(for server: Server) {
        if let index = sshConnections.firstIndex(where: { server == $0.connection.server }) {
            Task {
                try await sshConnections[index].connection.disconnect()
                _ = await MainActor.run {
                    sshConnections.remove(at: index)
                }
            }
        }
    }
}

class SSHConnectionWrapper: ObservableObject {
    
    var id = UUID()
    
    var cpu: Cpu
    
    var memory: MEMORY
    
    var swap: SWAP
    
    var network: NETWORK
    
    var storage: STORAGE
    
    var connection: SSHConnection
    
    deinit {
        print("Deinit \(connection.server.name)")
    }
    
    init(sshConnection: SSHConnection) {
        self.connection = sshConnection
        self.cpu = Cpu(self.connection)
        self.memory = MEMORY(self.connection)
        self.swap = SWAP(self.connection)
        self.network = NETWORK(self.connection)
        self.storage = STORAGE(self.connection)
    }
    
    func update() {
        Task {
            await cpu.update()
            await memory.update()
            await network.update()
            await storage.update()
        }
    }
    
    func disconnect() {
        Task {
            try await connection.disconnect()
        }
    }
}


class Cpu: ObservableObject {
    
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
    
    var totalIdleUsage: CGFloat {
        let cores = cores.value
        guard cores.count != 0 else { return -1 }
        return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
    }
    
    // MARK: Load
    var load = CurrentValueSubject<[CGFloat], Never>([0.001,0.001,0.001])
    
    // MARK: Cores
    var cores = CurrentValueSubject<[Core], Never>(.init())
    
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
        temperatureData: String
    ) {
        let cleanedCPUCoreData = removeWhiteSpaceAndNewLines(rawCpuCoreData)
        let cleanedRawTopRow = removeWhiteSpaceAndNewLines(rawTopRow)
        
        self.cores.send(parseCpuCoreData(cleanedCPUCoreData))
        self.load.send(parseLoadData(cleanedRawTopRow))
        self.temperature.send(parseTemperatureData(temperatureData))
    }
    
    @MainActor
    func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawCpuCoreData = (try? await sshConnection.send(command: Commands.TopCPUCore.rawValue) ?? "") ?? ""
        let rawTopRowData = (try? await sshConnection.send(command: Commands.TopTop.rawValue) ?? "") ?? ""
        let temperatureData = (try? await sshConnection.send(command: Commands.SysHwmonTemp.rawValue) ?? "") ?? ""
        update(rawCpuCoreData: rawCpuCoreData, rawTopRow: rawTopRowData, temperatureData: temperatureData)
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
