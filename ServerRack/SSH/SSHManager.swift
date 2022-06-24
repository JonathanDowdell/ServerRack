//
//  SSHManager.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/12/22.
//

import SwiftUI
import Combine

class SSHManager: ObservableObject {
    
    static let shared = SSHManager()
    
    private var cancellableSet = Set<AnyCancellable>()
    
    @Published var sshConnections = [SSHConnectionWrapper].init()
    
    init(
        serverPublisher: AnyPublisher<[Server], Never> = ServerStorage.shared.servers.eraseToAnyPublisher()
    ) {
        serverPublisher.sink { servers in
            self.sshConnections = servers.map { SSHConnectionWrapper(sshConnection: SSHConnection($0)) }
        }
        .store(in: &cancellableSet)
    }
    
    func connectAll() {
        for sshConnection in sshConnections {
            Task {
                try await sshConnection.connection.connect()
            }
        }
    }
    
    func disConnectAll() {
        for sshConnection in sshConnections {
            Task {
                try await sshConnection.connection.disconnect()
            }
        }
    }
    
    func removeConnection(for server: Server) {
        if let index = sshConnections.firstIndex(where: { server == $0.connection.server }) {
            Task {
                try await sshConnections[index].connection.disconnect()
                _ = await MainActor.run {
                    sshConnections.remove(at: index)
                }
            }
        }
    }
}

class SSHConnectionWrapper: ObservableObject {
    
    var id = UUID()
    
    var cpu: CPU
    
    var memory: MEMORY
    
    var swap: SWAP
    
    var network: NETWORK
    
    var storage: STORAGE
    
    var connection: SSHConnection
    
    deinit {
        print("Deinit \(connection.server.name)")
    }
    
    init(sshConnection: SSHConnection) {
        self.connection = sshConnection
        self.cpu = CPU(self.connection)
        self.memory = MEMORY(self.connection)
        self.swap = SWAP(self.connection)
        self.network = NETWORK(self.connection)
        self.storage = STORAGE(self.connection)
    }
    
    func update() {
        Task {
            await cpu.update()
            await memory.update()
            await network.update()
            await storage.update()
        }
    }
    
    func disconnect() {
        Task {
            try await connection.disconnect()
        }
    }
}


