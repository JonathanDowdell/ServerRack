//
//  ServerStatusRingMetricItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusRingMetricItem: View {
    
    @AppStorage("temperature") fileprivate var temperatureType: TemperatureType = .fahrenheit
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GroupBox {
            switch displayGridType {
            case .stack: stackLayout
            case .grid: gridLayout
            }
        }
    }
}

extension ServerStatusRingMetricItem {
    var head: some View {
        HStack {
            Text(viewModel.name)
                .bold()
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                if viewModel.fahrenheit != 0 || viewModel.celsius != 0 {
                    switch temperatureType {
                    case .fahrenheit:
                        Text("\(viewModel.fahrenheit)°F")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    case .celsius:
                        Text("\(viewModel.celsius)°C")
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
                            percent: viewModel.load,
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
                        let cpuPercentage = viewModel.cpuPercentUsage
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
                            let memoryPercentageUsed = viewModel.memoryPercentageUsed
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
                            let swapPercentageUsed = viewModel.swapPercentageUsed
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
                        topValue: viewModel.up,
                        topString: "upload",
                        bottomValue: viewModel.down,
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
                        topValue: viewModel.reads,
                        topString: "Read",
                        bottomValue: viewModel.writes,
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
                Text(viewModel.name)
                    .bold()
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 15) {
                    if viewModel.fahrenheit != 0 || viewModel.celsius != 0 {
                        switch temperatureType {
                        case .fahrenheit:
                            Text("\(viewModel.fahrenheit)°F")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        case .celsius:
                            Text("\(viewModel.celsius)°C")
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
                        percent: viewModel.load,
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
                        let cpuPercentage = viewModel.cpuPercentUsage
                        StatusRing(
                            percent: cpuPercentage,
                            startAngle: -90,
                            ringWidth: 7,
                            ringColor: .green,
                            backgroundColor: Color(.systemGray4),
                            drawnClockwise: false
                        )
                        
                        Group {
                            if cpuPercentage == -1 {
                                Text("%")
                            } else {
                                Text("\(Int8(cpuPercentage))%")
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

extension ServerStatusRingMetricItem {
    class ViewModel: ObservableObject {
        
        var name: String = ""
        
        var temperature: CGFloat = 0
        
        var fahrenheit: Int {
            let celsius = self.celsius
            if celsius == 0 {
                return 0
            } else {
                return celsius * 9 / 5 + 32
            }
        }
        
        var celsius: Int {
            return Int((Double(temperature) ) * 0.001)
        }
        
        var cores: [Core] = .init()
        
        var totalIdleUsage: CGFloat {
            let cores = cores
            guard cores.count != 0 else { return -1 }
            return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
        }
        
        var load: [CGFloat] = [0.01,0.01,0.01]
        
        var totalMemory: CGFloat = 0.001
        
        var usedMemory: CGFloat = 0.001
        
        var cacheMemory: CGFloat = 0.001
        
        var memoryPercentageUsed: CGFloat {
            guard !(totalMemory == 0.001 && usedMemory == 0.001) else { return 0.001 }
            if totalMemory != 0 {
                return (usedMemory / totalMemory) * 1000
            } else {
                return 0.001
            }
        }
        
        var totalCache: CGFloat = 0.001
        
        var usedCache: CGFloat = 0.001
        
        var swapCache: CGFloat = 0.001
        
        var swapPercentageUsed: CGFloat {
            guard !(totalCache == 0.001 && usedCache == 0.001) else { return 0.001 }
            if totalCache != 0 {
                return (usedCache / totalCache) * 1000
            } else {
                return 0.001
            }
        }
        
        var networkDevices: [NetworkDevice] = .init()
        
        var up: Double {
            let value = networkDevices.map { $0.up }.reduce(0, +)
            return Double(value) / 1048576
        }
        
        var down: Double {
            let value = networkDevices.map { $0.down }.reduce(0, +)
            return Double(value) / 1048576
        }
        
        var deviceIOs: [IODevice] = .init()
        
        var reads: Double {
            let value = deviceIOs.map { $0.read }.reduce(0, +)
            return Double(value) / 2048.0
        }
        
        var writes: Double {
            let value = deviceIOs.map { $0.write }.reduce(0, +)
            return Double(value) / 2048.0
        }
        
        var cpuPercentUsage: CGFloat {
            return 100 - totalIdleUsage
        }
        
        init(
            name: String,
            temperature: CGFloat,
            load: [CGFloat],
            cores: [Core],
            totalMemory: CGFloat,
            usedMemory: CGFloat,
            totalCache: CGFloat,
            usedCache: CGFloat,
            networkDevices: [NetworkDevice],
            deviceIOs: [IODevice]
        ) {
            self.name = name
            self.temperature = temperature
            self.load = load
            self.cores = cores
            self.totalMemory = totalMemory
            self.usedMemory = usedMemory
            self.totalCache = totalCache
            self.usedCache = usedCache
            self.networkDevices = networkDevices
            self.deviceIOs = deviceIOs
        }
    }
}
