//
//  ServerStatusDetailView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/8/22.
//

import SwiftUI

struct ServerStatusDetailView: View {
    
    @StateObject private var viewModel: ViewModel
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let server: Server
    
    var cached: Bool {
        return !viewModel.loaded
    }
    
    init(server: Server) {
        self.server = server
        self._viewModel = StateObject(wrappedValue: ViewModel(server: server))
    }
    
    var cpuSection: some View {
        GroupBox {
            VStack(spacing: 15) {
                HStack {
                    HStack(alignment: .bottom, spacing: 3) {
                        let totalIdleUsage = viewModel.cpu.totalIdleUsage(cached: cached)
                        let totalUsage = totalIdleUsage == -1 ? 0.001 : 100.0 - totalIdleUsage
                        Text("\(Int(totalUsage))")
                            .font(.system(.largeTitle, design: .rounded))
                        Text("%")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                    }
                    
                    Spacer()
                    
                    let systemUsage = viewModel.cpu.totalSystemUsage(cached: cached)
                    ServerStatusDetailMetric(
                        color: .red,
                        label: "SYS",
                        value: "\(Int(systemUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    let userUsage = viewModel.cpu.totalUserUsage(cached: cached)
                    ServerStatusDetailMetric(
                        color: .green,
                        label: "USER",
                        value: "\(Int(userUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    let iowaitUsage = viewModel.cpu.totalIOWaitUsage(cached: cached)
                    ServerStatusDetailMetric(
                        color: .purple,
                        label: "IOWAIT",
                        value: "\(Int(iowaitUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    let stealUsage = viewModel.cpu.totalStealUsage(cached: cached)
                    ServerStatusDetailMetric(
                        color: .yellow,
                        label: "STEAL",
                        value: "\(Int(stealUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(viewModel.coreProcess, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.self) { bullet in
                                Rectangle()
                                    .fill(bullet.color)
                                    .frame(width: 5, height: 10, alignment: .center)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                HStack {
                    
                    ServerStatusDetailMetric(label: "CORES", value: "\(viewModel.cpu.cores(cached: cached).count)", valueMetric: "")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: "IDLE", value: "\(Int(viewModel.cpu.totalIdleUsage(cached: cached)))", valueMetric: "%")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: "UPTIME", value: "6", valueMetric: "D")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: " LOAD", value: "", valueMetric: "1, 5, 15M")
                    
                    Spacer()
                    
                    StatusMultiRing(
                        percent: viewModel.cpu.load(cached: cached),
                        startAngle: -90,
                        ringWidth: 4,
                        ringSpaceOffSet: 10,
                        ringColor: .green
                    )
                    .frame(width: 35, height: 35, alignment: .center)
                }
            }
        }
    }
    
    
    var memorySection: some View {
        GroupBox {
            HStack {
                let freeMemory = viewModel.memory.free(cached: cached)
                ServerStatusDetailMetric(
                    label: "FREE",
                    value: freeMemory.humanizeMiBMemory(),
                    valueMetric: freeMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                let usedMemory = viewModel.memory.used(cached: cached)
                ServerStatusDetailMetric(
                    color: .green, label: "USED",
                    value: usedMemory.humanizeMiBMemory(),
                    valueMetric: usedMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                let cachedMemory = viewModel.memory.cache(cached: cached)
                ServerStatusDetailMetric(
                    color: .gray,
                    label: "CACHE",
                    value: cachedMemory.humanizeMiBMemory(),
                    valueMetric: cachedMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                ZStack {
                    let memoryPercentageUsed = viewModel.memory.memoryPercentageUsed(cached: cached)
                    StatusRing(
                        percent: memoryPercentageUsed,
                        startAngle: -90,
                        ringWidth: 4,
                        ringColor: .green,
                        backgroundColor: Color(.systemGray4),
                        drawnClockwise: false
                    )
                    
                    Group {
                        if memoryPercentageUsed == 0.001 {
                            Text("%")
                        } else {
                            Text("\(Int(memoryPercentageUsed))%")
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                }
                .frame(width: 35, height: 35, alignment: .center)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            cpuSection
                .padding(.horizontal)
            
            memorySection
                .padding(.horizontal)
        }
        .navigationTitle(server.name)
        .onAppear {
            connect()
        }
        .onDisappear {
            disconnect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("Disconnect")
            disconnect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("Connected")
            connect()
        }
        .onReceive(timer) { _ in
            getServerData()
        }
    }
    
    func connect() {
        self.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        self.viewModel.connect()
    }
    
    func disconnect() {
        self.timer.upstream.connect().cancel()
        self.viewModel.disconnect()
    }
    
    func getServerData() {
        viewModel.getServerData()
    }
}

extension ServerStatusDetailView {
    class ViewModel: ServerProtocol {
        
        @Published var cpu: CPU
        
        @Published var memory: Memory
        
        @Published var swap: Swap
        
        @Published var network: Network
        
        @Published var storage: Storage
        
        @Published var loaded = false
        
        
        var cpuCores: [Core] {
            if loaded {
                return cpu.cores
            } else {
                let id = server.id.uuidString
                let cores = (serverCache.cache[id]?["cores"] as? [Core] ?? .init())
                return cores
            }
        }
        
        var coreProcess: [[BulletProcess]] {
            return cpuCores.compactMap { core in
                let maxCount = Double(Int(UIScreen.screenWidth * 0.094))
                let sysItemCount = Int((core.system / 100) * maxCount)
                let systemBullets = Array.init(repeating: BulletProcess(priority: 1, color: .red), count: sysItemCount)
                
                let userItemCount = Int((core.user / 100) * maxCount)
                let userBullets = Array.init(repeating: BulletProcess(priority: 2, color: .green), count: userItemCount)
                
                let iowaitItemCount = Int((core.iowait / 100) * maxCount)
                let iowaitBullets = Array.init(repeating: BulletProcess(priority: 3, color: .purple), count: iowaitItemCount)
                
                let stealItemCount = Int((core.steal / 100) * maxCount)
                let stealBullets = Array.init(repeating: BulletProcess(priority: 4, color: .yellow), count: stealItemCount)
                
                let grayBulletStartInt = (sysItemCount + userItemCount + iowaitItemCount + stealItemCount)
                
                let processes = systemBullets + userBullets + iowaitBullets + stealBullets + (grayBulletStartInt ..< Int(maxCount)).map { BulletProcess(priority: $0, color: .gray) }
                
                return processes
            }
        }

//        var cpuPercentage: CGFloat {
//            let idle = cpuIdle
//            return idle == -1 ? 0.001 : 100.0 - idle
//        }
//
//        var memoryFree: CGFloat {
//            if loaded {
//                return memory.free
//            } else {
//                // Get Cached
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["memoryFree"] as? CGFloat) ?? 0.001
//                return value
//            }
//        }
//
//        var memoryUsed: CGFloat {
//            if loaded {
//                return memory.used
//            } else {
//                // Get Cached
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["memoryUsed"] as? CGFloat) ?? 0.001
//                return value
//            }
//        }
//
//        var cacheUsed: CGFloat {
//            if loaded {
//                return memory.cache
//            } else {
//                // Get Cached
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["memoryCacheUsed"] as? CGFloat) ?? 0.001
//                return value
//            }
//        }
//
//        var swapPercentageUsed: CGFloat {
//            if loaded {
//                return swap.swapPercentageUsed
//            } else {
//                // Get Cached
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["swapPercentageUsed"] as? CGFloat) ?? 0.001
//                return value
//            }
//        }
//
//        var networkUp: CGFloat {
//            if loaded {
//                return network.up
//            } else {
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["up"] as? Double) ?? 0
//                return value
//            }
//        }
//
//        var networkDown: CGFloat {
//            if loaded {
//                return network.down
//            } else {
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["down"] as? Double) ?? 0
//                return value
//            }
//        }
//
//        var totalReads: CGFloat {
//            if loaded {
//                return storage.totalReads
//            } else {
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["reads"] as? Double) ?? 0
//                return value
//            }
//        }
//
//        var totalWrites: CGFloat {
//            if loaded {
//                return storage.totalWrites
//            } else {
//                let id = server.id.uuidString
//                let value = (serverCache.cache[id]?["writes"] as? Double) ?? 0
//                return value
//            }
//        }
        
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
            print("ServerStatusDetailView - \(server.name) - Initialized")
        }
        
        deinit {
            print("ServerStatusDetailView - \(server.name) - Dinitialized")
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
                print("Ran From ServerStatusDetailView")
                await MainActor.run {
                    loaded = true
                }
            }
        }
    }
}

//struct ServerDetailStatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ServerStatusDetailView(server: <#Server#>)
//        }
//    }
//}

struct ServerStatusDetailMetric: View {
    
    var color: Color? = nil
    
    var label: String
    
    var value: String
    
    var valueMetric: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center, spacing: 5) {
                if let color = color {
                    Rectangle()
                        .fill(color)
                        .frame(width: 5, height: 10, alignment: .center)
                        .cornerRadius(10)
                }
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .bottom, spacing: 3) {
                Text(value)
                    .font(.system(.caption, design: .rounded))
                    .bold()
                Text(valueMetric)
                    .font(.caption2)
            }
        }
    }
}

struct BulletProcess: Hashable {
    var priority: Int = 5
    var color: Color = .gray
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
