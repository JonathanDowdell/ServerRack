//
//  ServerStatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusItem: View {
    
    @State private var sshConnection: SSHConnection
    
    @StateObject private var cpu = CPU()
    
    @StateObject private var memory = Memory()
    
    @StateObject private var swap = Swap()
    
    @StateObject private var network = Network()
    
    @StateObject private var storage = Storage()
    
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @AppStorage("temperature") private var temperatureType: TemperatureType = .fahrenheit
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    @EnvironmentObject var serverCache: ServerCache
    
    @State private var loaded = false
    
    private var server: Server

    init(server: Server) {
        self.server = server
        self.sshConnection = SSHConnection(server)
    }
    
    var body: some View {
        GroupBox {
            switch displayGridType {
            case .stack: normal
            case .grid: twoByTwo
            }
        }
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
        Task {
            try await self.sshConnection.connect()
        }
    }
    
    func disconnect() {
        self.timer.upstream.connect().cancel()
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
                self.loaded = true
                withAnimation(.spring()) {
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

extension ServerStatusItem {
    var twoByTwo: some View {
        VStack(spacing: 12) {
            HStack {
                Text(server.name)
                    .bold()
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 15) {
                    if loaded || hasLoaded {
                        Group {
                            switch temperatureType {
                            case .fahrenheit:
                                Text("\(fahrenheit)°F")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            case .celsius:
                                Text("\(celsius)°C")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        PulsatingView()
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
            
            FlipView {
                VStack(spacing: 12) {
                    StatusMultiRing(
                        percent: cpuLoad,
                        startAngle: -90,
                        ringWidth: 5,
                        ringSpaceOffSet: 12,
                        ringColor: .green
                    )
                    .frame(width: 55, height: 55, alignment: .center)
                    Text("Load")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } backView: {
                VStack(spacing: 12) {
                    ZStack {
                        StatusRing(
                            percent: cpuPercentage,
                            startAngle: -90,
                            ringWidth: 7,
                            ringColor: .green,
                            backgroundColor: Color(.systemGray4),
                            drawnClockwise: false
                        )
                        
                        let idle = cpuIdle
                        Group {
                            if idle == -1 {
                                Text("%")
                            } else {
                                Text("\(Int8(100.0 - idle))%")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .frame(width: 55, height: 55, alignment: .center)
                    
                    Text("CPU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var normal: some View {
        VStack(spacing: 12) {
            HStack {
                Text(server.name)
                    .bold()
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 15) {
                    if loaded || hasLoaded {
                        switch temperatureType {
                        case .fahrenheit:
                            Text("\(fahrenheit)°F")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        case .celsius:
                            Text("\(celsius)°C")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        PulsatingView()
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    
                    Button {
                        temperatureType = .fahrenheit
                    } label: {
                        Image(systemName: "square.3.stack.3d")
                            .foregroundColor(.accentColor)
                    }
                    
                    Button {
                        temperatureType = .celsius
                    } label: {
                        Image(systemName: "terminal")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            HStack {
                FlipView {
                    VStack(spacing: 12) {
                        StatusMultiRing(
                            percent: cpuLoad,
                            startAngle: -90,
                            ringWidth: 5,
                            ringSpaceOffSet: 12,
                            ringColor: .green
                        )
                        .frame(width: 55, height: 55, alignment: .center)
                        Text("Load")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } backView: {
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: cpuPercentage,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            
                            Group {
                                if cpuIdle == -1 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(100.0 - cpuIdle))%")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("CPU")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 2)

                FlipView {
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: memoryUsed,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Group {
                                if memoryUsed == 0.001 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(memoryUsed))%")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("Mem")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } backView: {
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: swapUsed,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Group {
                                if swapUsed == 0.001 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(swapUsed))%")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("Swap")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 38)
                
                Spacer()
                
                FlipView {
                    ServerIOStatusItem(
                        topValue: networkUp,
                        topString: "upload",
                        bottomValue: networkDown,
                        bottomString: "download"
                    )
                } backView: {
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("30")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }

                
                Spacer()
                
                FlipView {
                    ServerIOStatusItem(
                        topValue: totalReads,
                        topString: "Read",
                        bottomValue: totalWrites,
                        bottomString: "Write"
                    )
                } backView: {
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("30")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                    .frame(maxWidth: 15, alignment: .center)
            }
        }
    }
    
    
    var hasLoaded: Bool {
        let id = server.id.uuidString
        return serverCache.cache[id] != nil
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
}

//struct ServerStatusItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerStatusItem()
//    }
//}

extension ServerStatusItem  {
}


