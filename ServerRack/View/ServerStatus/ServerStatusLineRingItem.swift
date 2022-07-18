//
//  ServerStatusLineRingItem.swift
//  ServerRack
//
//  Created by Mettaworldj on 6/23/22.
//

import SwiftUI

struct ServerStatusLineRingItem: View {
    
    @AppStorage("temperature") private var temperatureType: TemperatureType = .fahrenheit
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
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
    
    var cpu: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    let cpuPercentage = viewModel.cpuPercentUsage > 100 ? 0 : viewModel.cpuPercentUsage / 100
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * cpuPercentage, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            HStack {
                Text("CPU")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .animation(.default, value: viewModel.cpuPercentUsage)
    }
    
    var load: some View {
        VStack {
            
            ForEach(0..<viewModel.load.count, id: \.self) { index in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(.systemGray4), lineWidth: 3)
                        .frame(height: 3, alignment: .center)
                    
                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.green)
                            .frame(width: proxy.size.width * (viewModel.load[index] / 100), height: 3, alignment: .center)
                    }
                    .frame(height: 3, alignment: .center)
                }
                .animation(.default, value: viewModel.load[index])
            }
            
            HStack {
                Text("Load")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
    
    var memory: some View {
        VStack(spacing: 12) {
            ZStack {
                StatusRing(
                    percent: viewModel.memoryPercentageUsed,
                    startAngle: -90,
                    ringWidth: 5,
                    ringColor: .green,
                    backgroundColor: Color(.systemGray4),
                    drawnClockwise: false
                )
                
                
                Group {
                    Text("\(Int8(viewModel.memoryPercentageUsed))%")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(width: 55, height: 55, alignment: .center)
            
            Text("Memory")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var tasks: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                Image(systemName: "bolt.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Text("\(viewModel.tasks.running.suffixNumber())")
                    .font(.system(.subheadline, design: .monospaced))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .frame(width: 30)
            }
            .foregroundColor(.secondary)
            
            HStack(alignment: .center) {
                Image(systemName: "bolt.slash.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Text("\(viewModel.tasks.stopped.suffixNumber())")
                    .font(.system(.subheadline, design: .monospaced))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .frame(width: 30)
            }
            .foregroundColor(.secondary)
            
            HStack(alignment: .center) {
                Image(systemName: "moon.stars.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("\(viewModel.tasks.sleeping.suffixNumber())")
                    .font(.system(.subheadline, design: .monospaced))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .frame(width: 30)
            }
            .foregroundColor(.secondary)
        }
    }
    
    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                head
                
                HStack(alignment: .top, spacing: 25) {
                    
                    VStack {
                        cpu
                        
                        load
                    }
                    
                    memory
                    
                    tasks
                    
                }
                
            }
            .padding(.bottom, 2)
        }
    }

}

struct ServerStatusLineRingItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServerStatusLineRingItem(viewModel: .init())
                .preferredColorScheme(.light)
                .padding()
            
            ServerStatusLineRingItem(viewModel: .init())
                .preferredColorScheme(.dark)
                .padding()
        }
    }
}

extension ServerStatusLineRingItem {
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
