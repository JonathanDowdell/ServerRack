//
//  ServerStats.swift
//  ServerRack
//
//  Created by Mettaworldj on 7/5/22.
//

import SwiftUI

class ServerStats {
    var name: String = ""
    
    var temperature: CGFloat = 0
    
    var celsius: Int {
        return Int((Double(temperature) ) * 0.001)
    }
    
    var fahrenheit: Int {
        let celsius = self.celsius
        if celsius == 0 {
            return 0
        } else {
            return celsius * 9 / 5 + 32
        }
    }
    
    var cores: [Core] = .init()
    
    var tasks: Tasks = .init()
    
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
}
