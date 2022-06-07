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
    
    @EnvironmentObject var serverCache: ServerCache
    
    @State private var loaded = false
    
    private var server: Server

    init(server: Server) {
        self.server = server
        self.sshConnection = SSHConnection(server)
    }
    
    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack {
                    Text(server.name)
                        .bold()
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        if loaded {
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
                    memory.update(rawMemRow: rawMemRowData)
                    swap.update(rawSwapRow: rawSwapRowData)
                    network.update(rawNetworkData: rawNetworkData)
                    storage.update(rawDiskFreeData: rawDiskFreeData, rawProcDiskStatsData: rawProcDiskStatsData)
                    print(serverCache.cache["alpha"]?["up"] ?? "Nil")
                }
            }
        }
    }
}

extension ServerStatusItem {
    var fahrenheit: Int {
        if loaded {
            return cpu.fahrenheit
        } else {
            // Get Cached
            let id = server.id.debugDescription
            let value = (serverCache.cache[id]?["fahrenheit"] as? Int) ?? 0
            return value
        }
    }
    
    var celsius: Int {
        if loaded {
            return cpu.celsius
        } else {
            // Get Cached
            return cpu.celsius
        }
    }
    
    var cpuLoad: [CGFloat] {
        if loaded {
            return cpu.load
        } else {
            // Get Cached
            return cpu.load
        }
    }
    
    var cpuIdle: CGFloat {
        if loaded {
            return cpu.idle
        } else {
            return cpu.idle
        }
    }
    
    var cpuPercentage: CGFloat {
        if loaded {
            return cpu.idle == -1 ? 0.001 : 100.0 - cpu.idle
        } else {
            // Get Cached
            return cpu.idle == -1 ? 0.001 : 100.0 - cpu.idle
        }
    }
    
    var memoryUsed: CGFloat {
        if loaded {
            return memory.memoryUsed
        } else {
            return memory.memoryUsed
        }
    }
    
    var swapUsed: CGFloat {
        if loaded {
            return swap.swapUsed
        } else {
            return swap.swapUsed
        }
    }
    
    var networkUp: CGFloat {
        if loaded {
            return network.up
        } else {
            return network.up
        }
    }
    
    var networkDown: CGFloat {
        if loaded {
            return network.down
        } else {
            return network.down
        }
    }
    
    var totalReads: CGFloat {
        if loaded {
            return storage.totalReads
        } else {
            return storage.totalReads
        }
    }
    
    var totalWrites: CGFloat {
        if loaded {
            return storage.totalWrites
        } else {
            return storage.totalWrites
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


