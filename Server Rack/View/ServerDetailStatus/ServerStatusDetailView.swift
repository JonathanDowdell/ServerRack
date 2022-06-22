//
//  ServerStatusDetailView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/13/22.
//

import SwiftUI

class ServerStatusDetailViewModel: ObservableObject {
    
    @Published var sshConnectionWrapper: SSHConnectionWrapper
    
    let server: Server
    
    @Published var load: [CGFloat] = [0.01,0.01,0.01]
    
    @Published var cores: [Core] = .init()
    
    var totalSystemUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.system }.reduce(0, +) / Double(cores.count)
    }
    
    var totalUserUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.user }.reduce(0, +) / Double(cores.count)
    }
    
    var totalIOWaitUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.iowait }.reduce(0, +) / Double(cores.count)
    }
    
    var totalStealUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.steal }.reduce(0, +) / Double(cores.count)
    }
    
    var totalIdleUsage: CGFloat {
        guard cores.count != 0 else { return -1 }
        return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
    }
    
    var stringValueLoad: String {
        
        return "\(load.reversed().map { String(Int($0)) }.joined(separator: ", ") + "M")"
    }
    
    var coreProcess: [[BulletProcess]] {
        return cores.compactMap { core in
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
    
    @Published var freeMemory: CGFloat = 0
    
    @Published var usedMemory: CGFloat = 0
    
    @Published var cachedMemory: CGFloat = 0
    
    @Published var totalMemory: CGFloat = 0
    
    var memoryPercentageUsed: CGFloat {
        let used = usedMemory
        let total = totalMemory
        guard !(total == 0.001 && used == 0.001) else { return 0.001 }
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    init(sshConnectionWrapper: SSHConnectionWrapper) {
        print("Inited - ViewModel")
        self.sshConnectionWrapper = sshConnectionWrapper
        self.server = sshConnectionWrapper.connection.server
    }
    
}

struct ServerStatusDetailView: View {
    
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
//    @ObservedObject private var viewModel: ServerStatusDetailViewModel
    
    @StateObject var sshConnectionWrapper: SSHConnectionWrapper
    
    let server: Server
    
    @State var load: [CGFloat] = [0.01,0.01,0.01]
    
    @State var cores: [Core] = .init()
    
    var totalSystemUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.system }.reduce(0, +) / Double(cores.count)
    }
    
    var totalUserUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.user }.reduce(0, +) / Double(cores.count)
    }
    
    var totalIOWaitUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.iowait }.reduce(0, +) / Double(cores.count)
    }
    
    var totalStealUsage: CGFloat {
        guard cores.count != 0 else { return 0 }
        return cores.map { $0.steal }.reduce(0, +) / Double(cores.count)
    }
    
    var totalIdleUsage: CGFloat {
        guard cores.count != 0 else { return -1 }
        return cores.map { $0.idle }.reduce(0, +) / Double(cores.count)
    }
    
    var stringValueLoad: String {
        
        return "\(load.reversed().map { String(Int($0)) }.joined(separator: ", ") + "M")"
    }
    
    var coreProcess: [[BulletProcess]] {
        return cores.compactMap { core in
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
    
    @State var freeMemory: CGFloat = 0
    
    @State var usedMemory: CGFloat = 0
    
    @State var cachedMemory: CGFloat = 0
    
    @State var totalMemory: CGFloat = 0
    
    var memoryPercentageUsed: CGFloat {
        let used = usedMemory
        let total = totalMemory
        guard !(total == 0.001 && used == 0.001) else { return 0.001 }
        if total != 0 {
            return (used / total) * 1000
        } else {
            return 0.001
        }
    }
    
    init(sshConnectionWrapper: SSHConnectionWrapper) {
//        self._viewModel = ObservedObject(wrappedValue: .init(sshConnectionWrapper: sshConnectionWrapper))
        self._sshConnectionWrapper = StateObject(wrappedValue: .init(sshConnection: sshConnectionWrapper.connection))
        self.server = sshConnectionWrapper.connection.server
    }
    
    var cpuSection: some View {
        GroupBox {
            VStack(spacing: 15) {
                HStack {
                    HStack(alignment: .bottom, spacing: 3) {
                        Text("\(Int(100 - totalIdleUsage))")
                            .font(.system(.largeTitle, design: .rounded))
                        Text("%")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                    }
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(
                        color: .red,
                        label: "SYS",
                        value: "\(Int(totalSystemUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(
                        color: .green,
                        label: "USER",
                        value: "\(Int(totalUserUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(
                        color: .purple,
                        label: "IOWAIT",
                        value: "\(Int(totalIOWaitUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(
                        color: .yellow,
                        label: "STEAL",
                        value: "\(Int(totalStealUsage))",
                        valueMetric: "%"
                    )
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(coreProcess, id: \.self) { row in
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
                    
                    ServerStatusDetailMetric(label: "CORES", value: "\(cores.count)", valueMetric: "")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: "IDLE", value: "\(Int(totalIdleUsage))", valueMetric: "%")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: "UPTIME", value: "6", valueMetric: "D")
                    
                    Spacer()
                    
                    ServerStatusDetailMetric(label: " LOAD", value: "", valueMetric: stringValueLoad)
                    
                    Spacer()
                    
                    StatusMultiRing(
                        percent: load,
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
                ServerStatusDetailMetric(
                    label: "FREE",
                    value: freeMemory.humanizeMiBMemory(),
                    valueMetric: freeMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                ServerStatusDetailMetric(
                    color: .green, label: "USED",
                    value: usedMemory.humanizeMiBMemory(),
                    valueMetric: usedMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                ServerStatusDetailMetric(
                    color: .gray,
                    label: "CACHE",
                    value: cachedMemory.humanizeMiBMemory(),
                    valueMetric: cachedMemory.humanizeMiBMemoryMetric()
                )
                
                Spacer()
                
                ZStack {
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
        .onReceive(sshConnectionWrapper.cpu.load.eraseToAnyPublisher()) { newLoad in
            self.load = newLoad
        }
        .onReceive(sshConnectionWrapper.cpu.cores.eraseToAnyPublisher()) { newCores in
            self.cores = newCores
        }
        .onReceive(sshConnectionWrapper.memory.free.eraseToAnyPublisher()) { newFree in
            self.freeMemory = newFree
        }
        .onReceive(sshConnectionWrapper.memory.used.eraseToAnyPublisher()) { newUsed in
            self.usedMemory = newUsed
        }
        .onReceive(sshConnectionWrapper.memory.total.eraseToAnyPublisher()) { newTotal in
            self.totalMemory = newTotal
        }
        .onReceive(sshConnectionWrapper.memory.cache.eraseToAnyPublisher()) { newCached in
            self.cachedMemory = newCached
        }
        .onReceive(timer) { _ in
            getServerData()
        }
    }
    
    func connect() {
        self.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    }
    
    func disconnect() {
        self.timer.upstream.connect().cancel()
        
    }
    
    func getServerData() {
        
    }
}

//struct ServerStatusDetailViewV2_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerStatusDetailView()
//    }
//}



struct BulletProcess: Hashable {
    var priority: Int = 5
    var color: Color = .gray
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
