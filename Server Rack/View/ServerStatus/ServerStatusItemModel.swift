//
//  ServerStatusItemModel.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/8/22.
//

import SwiftUI

extension ServerStatusItem {
    class ViewModel: ObservableObject {
        
        @Published var cpu = CPU()
        
        @Published var memory = Memory()
        
        @Published var swap = Swap()
        
        @Published var network = Network()
        
        @Published var storage = Storage()
        
        @Published var loaded = false
        
        var cacheEmpty: Bool {
            let id = server.id.uuidString
            return serverCache.cache[id] == nil
        }

        var fahrenheit: Int {
            if loaded {
                return cpu.fahrenheit
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["fahrenheit"] as? Int) ?? 0
                return value
            }
        }

        var celsius: Int {
            if loaded {
                return cpu.celsius
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["celsius"] as? Int) ?? 0
                return value
            }
        }

        var cpuLoad: [CGFloat] {
            if loaded {
                return cpu.load
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["load"] as? [CGFloat]) ?? [0.001,0.001,0.001]
                return value
            }
        }

        var cpuIdle: CGFloat {
            if loaded {
                return cpu.idle
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["idle"] as? CGFloat) ?? -1
                return value
            }
        }

        var cpuPercentage: CGFloat {
            let idle = cpuIdle
            return idle == -1 ? 0.001 : 100.0 - idle
        }

        var memoryUsed: CGFloat {
            if loaded {
                return memory.memoryUsed
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["memoryUsed"] as? CGFloat) ?? 0.001
                return value
            }
        }

        var swapUsed: CGFloat {
            if loaded {
                return swap.swapUsed
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["swapUsed"] as? CGFloat) ?? 0.001
                return value
            }
        }

        var networkUp: CGFloat {
            if loaded {
                return network.up
            } else {
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["up"] as? Double) ?? 0
                return value
            }
        }

        var networkDown: CGFloat {
            if loaded {
                return network.down
            } else {
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["down"] as? Double) ?? 0
                return value
            }
        }

        var totalReads: CGFloat {
            if loaded {
                return storage.totalReads
            } else {
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["reads"] as? Double) ?? 0
                return value
            }
        }

        var totalWrites: CGFloat {
            if loaded {
                return storage.totalWrites
            } else {
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["writes"] as? Double) ?? 0
                return value
            }
        }
        
        private var sshConnection: SSHConnection
        
        private let server: Server
        
        private let serverCache: ServerCache
        
        init(server: Server) {
            self.server = server
            self.sshConnection = SSHConnection(server)
            self.serverCache = ServerCache.shared
            print("ServerStatusItem - \(server.name) - Initialized")
        }
        
        deinit {
            print("ServerStatusItem - \(server.name) - Dinitialized")
        }
        
        func connect() {
            Task {
                try await self.sshConnection.connect()
            }
        }
        
        func disconnect() {
            Task {
                try await self.sshConnection.disconnect()
            }
        }
        
        func getServerData() {
            Task {
                let rawCpuRowData = (try? await self.sshConnection.send(command: Commands.TopCPU.rawValue) ?? "") ?? ""
                let rawTopRowData = (try? await self.sshConnection.send(command: Commands.TopTop.rawValue) ?? "") ?? ""
                let temperatureData = (try? await self.sshConnection.send(command: Commands.SysHwmonTemp.rawValue) ?? "") ?? ""
                let rawMemRowData = (try? await self.sshConnection.send(command: Commands.TopMem.rawValue) ?? "") ?? ""
                let rawSwapRowData = (try? await self.sshConnection.send(command: Commands.TopSwap.rawValue) ?? "") ?? ""

                let rawNetworkData = (try? await self.sshConnection.send(command: Commands.ProcNetDev.rawValue.replacingOccurrences(of: "\\", with: "")) ?? "") ?? ""

                let rawProcDiskStatsData = ((try? await self.sshConnection.send(command: Commands.ProcDiskStats.rawValue) ?? "")) ?? ""

                let rawDiskFreeData = ((try? await self.sshConnection.send(command: Commands.DiskFree.rawValue.replacingOccurrences(of: "\\", with: "")) ?? "")) ?? ""
                
                
                await MainActor.run {
                    loaded = true
                    cpu.update(rawCPURow: rawCpuRowData, rawTopRow: rawTopRowData, temperatureData: temperatureData)
                    cpu.cache(id: server.id)
                    
                    memory.update(rawMemRow: rawMemRowData)
                    memory.cache(id: server.id)
                    
                    swap.update(rawSwapRow: rawSwapRowData)
                    swap.cache(id: server.id)
                    
                    network.update(rawNetworkData: rawNetworkData)
                    network.cache(id: server.id)
                    
                    storage.update(rawDiskFreeData: rawDiskFreeData, rawProcDiskStatsData: rawProcDiskStatsData)
                    storage.cache(id: server.id)
                }
            }
        }
    }
}
