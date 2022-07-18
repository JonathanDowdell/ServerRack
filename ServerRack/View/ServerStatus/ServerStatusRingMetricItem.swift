//
//  ServerStatusRingMetricItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusRingMetricItem: View {
    
    @AppStorage("temperature") private var temperatureType: TemperatureType = .fahrenheit
    
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
                .foregroundColor(.primary)
            
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
                .frame(height: 100)
                
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
                .frame(height: 100)
                
                Spacer()
                
                ServerIOStatusItem(
                    topValue: viewModel.up,
                    topString: "upload",
                    bottomValue: viewModel.down,
                    bottomString: "download"
                )
                .frame(height: 100)
                
                Spacer()
                
                ServerIOStatusItem(
                    topValue: viewModel.reads,
                    topString: "Read",
                    bottomValue: viewModel.writes,
                    bottomString: "Write"
                )
                .frame(height: 100)
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

struct ServerStatusRingMetricItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LazyVStack {
                ServerStatusRingMetricItem(viewModel: .init())
                    .preferredColorScheme(.light)
                    .padding()
            }
            
            LazyVStack {
                ServerStatusRingMetricItem(viewModel: .init())
                    .preferredColorScheme(.dark)
                    .padding()
            }
        }
    }
}

extension ServerStatusRingMetricItem {
    class ViewModel: ServerStats, ObservableObject {
        
        override init() {
            super.init()
            self.name = "Server"
        }
        
        convenience init(name: String) {
            self.init()
            self.name = name
        }
        
        convenience init(name: String, temperature: CGFloat) {
            self.init()
            self.name = name
            self.temperature = temperature
        }
        
        convenience init(
            name: String,
            temperature: CGFloat,
            load: [CGFloat],
            cores: [Core],
            tasks: Tasks,
            totalMemory: CGFloat,
            usedMemory: CGFloat,
            totalCache: CGFloat,
            usedCache: CGFloat,
            networkDevices: [NetworkDevice],
            deviceIOs: [IODevice]
        ) {
            self.init()
            self.name = name
            self.temperature = temperature
            self.load = load
            self.cores = cores
            self.tasks = tasks
            self.totalMemory = totalMemory
            self.usedMemory = usedMemory
            self.totalCache = totalCache
            self.usedCache = usedCache
            self.networkDevices = networkDevices
            self.deviceIOs = deviceIOs
        }
    }
}
