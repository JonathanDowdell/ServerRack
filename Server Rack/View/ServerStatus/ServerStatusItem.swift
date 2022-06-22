//
//  ServerStatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusItem: View {
    
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @AppStorage("temperature") fileprivate var temperatureType: TemperatureType = .fahrenheit
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    @State private var load: [CGFloat] = [0.01,0.01,0.01]
    
    private var cpuPercentUsage: CGFloat {
        return 100 - connection.cpu.totalIdleUsage
    }
    
    @State private var totalMemory: CGFloat = 0.001
    
    @State private var usedMemory: CGFloat = 0.001
    
    @State private var cacheMemory: CGFloat = 0.001
    
    var memoryPercentageUsed: CGFloat {
        guard !(totalMemory == 0.001 && usedMemory == 0.001) else { return 0.001 }
        if totalMemory != 0 {
            return (usedMemory / totalMemory) * 1000
        } else {
            return 0.001
        }
    }
    
    @State private var totalCache: CGFloat = 0.001
    
    @State private var usedCache: CGFloat = 0.001
    
    @State private var cachedSwap: CGFloat = 0.001
    
    var swapPercentageUsed: CGFloat {
        guard !(totalCache == 0.001 && usedCache == 0.001) else { return 0.001 }
        if totalCache != 0 {
            return (usedCache / totalCache) * 1000
        } else {
            return 0.001
        }
    }
    
    @State private var networkDevices: [NetworkDevice] = .init()
    
    var up: Double {
        let value = networkDevices.map { $0.up }.reduce(0, +)
        return Double(value) / 1048576
    }
    
    var down: Double {
        let value = networkDevices.map { $0.down }.reduce(0, +)
        return Double(value) / 1048576
    }
    
    @State private var deviceIOs: [DeviceIO] = .init()
    
    var reads: Double {
        let value = deviceIOs.map { $0.read }.reduce(0, +)
        return Double(value) / 2048.0
    }
    
    var writes: Double {
        let value = deviceIOs.map { $0.write }.reduce(0, +)
        return Double(value) / 2048.0
    }
    
    private var server: Server {
        return connection.connection.server
    }
    
    private var connection: SSHConnectionWrapper

    init(connection: SSHConnectionWrapper) {
        self.connection = connection
    }
    
    var body: some View {
        GroupBox {
            switch displayGridType {
            case .stack: stackLayout
            case .grid: gridLayout
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            disconnect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            connect()
        }
        .onReceive(connection.cpu.load.eraseToAnyPublisher()) { newLoad in
            self.load = newLoad
        }
        .onReceive(connection.memory.total.eraseToAnyPublisher()) { newTotal in
            self.totalMemory = newTotal
        }
        .onReceive(connection.memory.used.eraseToAnyPublisher()) { newUsed in
            self.usedMemory = newUsed
        }
        .onReceive(connection.swap.total.eraseToAnyPublisher()) { newTotal in
            self.totalCache = newTotal
        }
        .onReceive(connection.swap.used.eraseToAnyPublisher()) { newUsed in
            self.usedCache = newUsed
        }
        .onReceive(connection.network.devices.eraseToAnyPublisher()) { newDevices in
            self.networkDevices = newDevices
        }
        .onReceive(connection.storage.deviceIOs.eraseToAnyPublisher()) { newDevices in
            self.deviceIOs = newDevices
        }
        .onReceive(timer) { _ in
            getServerData()
        }
    }
    
    func connect() {
        self.timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    }
    
    func disconnect() {
        self.timer.upstream.connect().cancel()
    }
    
    func getServerData() {
        connection.update()
    }
}

extension ServerStatusItem {
    var head: some View {
        HStack {
            Text(server.name)
                .bold()
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                if connection.cpu.fahrenheit != 0 || connection.cpu.celsius != 0 {
                    switch temperatureType {
                    case .fahrenheit:
                        Text("\(connection.cpu.fahrenheit)°F")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    case .celsius:
                        Text("\(connection.cpu.celsius)°C")
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
    }
    
    var stackLayout: some View {
        VStack {
            head
                .padding(.bottom, 8)
            
            HStack {
                FlipView {
                    VStack(spacing: 12) {
                        StatusMultiRing(
                            percent: load,
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
                        let cpuPercentage = cpuPercentUsage
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
                                Text("\(Int8(cpuPercentage))%")
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
                
                Spacer()
                
                FlipView {
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: memoryPercentageUsed,
                                startAngle: -90,
                                ringWidth: 7,
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
                                percent: swapPercentageUsed,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Group {
                                if swapPercentageUsed == 0.001 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(swapPercentageUsed))%")
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
                
                Spacer()
                
                FlipView {
                    ServerIOStatusItem(
                        topValue: up,
                        topString: "upload",
                        bottomValue: down,
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
                        topValue: reads,
                        topString: "Read",
                        bottomValue: writes,
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
            }
            .padding(.horizontal, 9)
        }
    }
    
    var gridLayout: some View {
        VStack(spacing: 12) {
            HStack {
                Text(server.name)
                    .bold()
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 15) {
                    if connection.cpu.fahrenheit != 0 || connection.cpu.celsius != 0 {
                        switch temperatureType {
                        case .fahrenheit:
                            Text("\(connection.cpu.fahrenheit)°F")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        case .celsius:
                            Text("\(connection.cpu.celsius)°C")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
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
                        percent: load,
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
                            percent: cpuPercentUsage,
                            startAngle: -90,
                            ringWidth: 7,
                            ringColor: .green,
                            backgroundColor: Color(.systemGray4),
                            drawnClockwise: false
                        )
                        
                        Group {
                            if cpuPercentUsage == -1 {
                                Text("%")
                            } else {
                                Text("\(Int8(cpuPercentUsage))%")
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
}

