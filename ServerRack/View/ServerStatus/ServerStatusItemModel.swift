//
//  ServerStatusItemModel.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/8/22.
//

import SwiftUI

protocol ServerProtocol: ObservableObject {
    var cpu: CPU { get set }
    var memory: Memory { get set }
    var swap: Swap { get set }
    var network: Network { get set }
    var storage: Storage { get set }
    var loaded: Bool { get set }
}

extension ServerStatusItem {
    class ViewModel: ServerProtocol {
        
        @Published var cpu: CPU
        
        @Published var memory: Memory
        
        @Published var swap: Swap
        
        @Published var network: Network
        
        @Published var storage: Storage
        
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
            guard cpu.cores.count != 0 else { return -1 }
            if loaded {
                return (cpu.cores.map { $0.idle }.reduce(0, +)) / Double(cpu.cores.count)
            } else {
                // Get Cached
                let id = server.id.uuidString
                let cores = (serverCache.cache[id]?["cores"] as? [Core] ?? .init())
                return (cores.map { $0.idle }.reduce(0, +)) / Double(cpu.cores.count)
            }
        }

        var cpuPercentage: CGFloat {
            let idle = cpuIdle
            return idle == -1 ? 0.001 : 100.0 - idle
        }
        
        var memoryUsed: CGFloat {
            if loaded {
                return memory.used
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["memoryUsed"] as? CGFloat) ?? 0.001
                return value
            }
        }

        var swapPercentageUsed: CGFloat {
            if loaded {
                return swap.swapPercentageUsed
            } else {
                // Get Cached
                let id = server.id.uuidString
                let value = (serverCache.cache[id]?["swapPercentageUsed"] as? CGFloat) ?? 0.001
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
            self.cpu = CPU(self.sshConnection)
            self.memory = Memory(self.sshConnection)
            self.swap = Swap(self.sshConnection)
            self.network = Network(self.sshConnection)
            self.storage = Storage(self.sshConnection)
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
                await cpu.update()
                await memory.update()
                await swap.update()
                await network.update()
                await storage.update()
                
                
                await MainActor.run {
                    loaded = true
                }
            }
        }
        
    }
}
