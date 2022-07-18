//
//  ServerStatusItem.swift
//  ServerRack
//
//  Created by Mettaworldj on 6/23/22.
//

import SwiftUI

struct ServerStatusItem: View {
    
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @State private var temperature: CGFloat = 0
    
    @State private var load: [CGFloat] = [0.01,0.01,0.01]
    
    @State private var cores: [Core] = .init()
    
    @State private var tasks: Tasks = .init()
    
    @State private var totalMemory: CGFloat = 0.001
    
    @State private var usedMemory: CGFloat = 0.001
    
    @State private var cacheMemory: CGFloat = 0.001
    
    @State private var totalCache: CGFloat = 0.001
    
    @State private var usedCache: CGFloat = 0.001
    
    @State private var cachedSwap: CGFloat = 0.001
    
    @State private var networkDevices: [NetworkDevice] = .init()
    
    @State private var ioDevices: [IODevice] = .init()
    
    private var server: Server {
        return connection.connection.server
    }
    
    private var connection: SSHConnectionWrapper

    init(connection: SSHConnectionWrapper) {
        self.connection = connection
        
    }
    
    var body: some View {
        Group {
            ServerStatusRingMetricItem(
                viewModel: .init(
                    name: server.name,
                    temperature: temperature,
                    load: load,
                    cores: cores,
                    tasks: tasks,
                    totalMemory: totalMemory,
                    usedMemory: usedMemory,
                    totalCache: totalCache,
                    usedCache: usedCache,
                    networkDevices: networkDevices,
                    deviceIOs: ioDevices
                )
            )
            
            
//            ServerStatusLineRingItem(
//                viewModel: .init(
//                    name: server.name,
//                    temperature: temperature,
//                    load: load,
//                    cores: cores,
//                    tasks: tasks,
//                    totalMemory: totalMemory,
//                    usedMemory: usedMemory,
//                    totalCache: totalCache,
//                    usedCache: usedCache,
//                    networkDevices: networkDevices,
//                    deviceIOs: ioDevices
//                )
//            )
            
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            connect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            disconnect()
        }
        .onReceive(connection.cpu.temperature) { newTemperature in
            self.temperature = newTemperature
        }
        .onReceive(connection.cpu.load.eraseToAnyPublisher()) { newLoad in
            self.load = newLoad
        }
        .onReceive(connection.cpu.cores.eraseToAnyPublisher()) { newCores in
            self.cores = newCores
        }
        .onReceive(connection.cpu.tasks.eraseToAnyPublisher()) { newTasks in
            self.tasks = newTasks
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
            self.ioDevices = newDevices
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

//struct ServerStatusItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerStatusItem()
//    }
//}
