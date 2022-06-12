//
//  Network.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/30/22.
//

import Foundation

struct Network {
    
    var devices: [NetworkDevice] = .init()
    
    /// Total Uploaded by Server - MB
    var up: Double {
        let value = devices.map { $0.up }.reduce(0, +)
        return Double(value) / 1048576
    }
    
    /// Total Downloaded by Server - MB
    var down: Double {
        let value = devices.map { $0.down }.reduce(0, +)
        return Double(value) / 1048576
    }
    
    private weak var sshConnection: SSHConnection?
    
    init(_ sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    init() {}
    
    mutating func update(rawNetworkData: String) {
        let resultsArray = rawNetworkData.components(separatedBy: "split")
        
        self.devices = resultsArray.compactMap { item in
            let item = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let rawDevice = item.matchingStrings(regex: ".*:").first?.first else { return nil }
            var networkDevice = NetworkDevice()
            let device = rawDevice.replacingOccurrences(of: ":", with: "")
            networkDevice.name = device
            if let rawDown = item.matchingStrings(regex: "\\d*.down").first?.first,
               let down = Int(rawDown.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .letters)) {
                networkDevice.down = down
            }
            
            if let rawUp = item.matchingStrings(regex: "\\d*.up").first?.first,
               let up = Int(rawUp.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .letters)) {
                networkDevice.up = up
            }
            return networkDevice
        }
    }
    
    @MainActor
    mutating func update() async {
        guard let sshConnection = sshConnection else { return }
        let rawNetworkData = (try? await sshConnection.send(command: Commands.ProcNetDev.rawValue.replacingOccurrences(of: "\\", with: "")) ?? "") ?? ""
        let id = sshConnection.server.id
        
        update(rawNetworkData: rawNetworkData)
        cache(id: id)
    }
    
    func cache(id: UUID) {
        if ServerCache.shared.cache[id.uuidString] == nil {
            ServerCache.shared.cache[id.uuidString] = .init()
        }
        
        ServerCache.shared.cache[id.uuidString]?["up"] = self.up
        ServerCache.shared.cache[id.uuidString]?["down"] = self.down
    }
}

/// Network Device for Server
struct NetworkDevice {
    /// Server Name
    var name: String = ""
    
    /// Uploaded by Server - Bytes
    var up: Int = 0
    
    /// Downloaded by Server - Bytes
    var down: Int = 0
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
