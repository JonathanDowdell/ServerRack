//
//  Storage.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/30/22.
//

import Foundation

class Storage: ObservableObject {
    
    @Published var devices: [StorageDevice] = .init()
    
    @Published var deviceIOs: [DeviceIO] = .init()
    
    /// Total Reads - MB
    var totalReads: Double {
        let value = deviceIOs.map { $0.read }.reduce(0, +)
        return Double(value) / 2048.0
    }
    
    /// Total Write - MB
    var totalWrites: Double {
        let value = deviceIOs.map { $0.write }.reduce(0, +)
        return Double(value) / 2048.0
    }
    
    init() {}
    
    func update(rawDiskFreeData: String, rawProcDiskStatsData: String) {
        // Clean Data
        let diskFreeDataArray = cleanRawDiskFreeData(rawDiskFreeData)
        let procDiskStatsArray = cleanRawProcDiskStatsData(rawProcDiskStatsData)
        self.devices = parseDiskFreeDataArray(diskFreeDataArray)
        self.deviceIOs = parseProcDiskStatsArray(procDiskStatsArray)
    }
    
    func cleanRawDiskFreeData(_ rawDiskFreeData: String) -> [String] {
        return rawDiskFreeData.components(separatedBy: "split")
    }
    
    func parseDiskFreeDataArray(_ diskFreeData: [String]) -> [StorageDevice] {
        return diskFreeData.compactMap { item in
            let diskItemArray = item.components(separatedBy: "|")
            if diskItemArray.count > 0 && diskItemArray.count > 1 {
                var storageDevice = StorageDevice()
                if let fileSystemString = Optional(diskItemArray[0])?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    storageDevice.fileSystem = fileSystemString
                }
                
                if let sizeString = Optional(diskItemArray[1])?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .letters),
                   let sizeMB = Int(sizeString) {
                    storageDevice.size = sizeMB
                }
                
                if let usedString = Optional(diskItemArray[2])?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .letters),
                   let usedMB = Int(usedString) {
                    storageDevice.used = usedMB
                }
                
                if let availableString = Optional(diskItemArray[3])?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .letters),
                   let availableMB = Int(availableString) {
                    storageDevice.available = availableMB
                }
                
                if let percentageUsedString = Optional(diskItemArray[4])?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "%", with: ""),
                   let percentage = Int(percentageUsedString) {
                    storageDevice.percentageUsed = percentage
                }
                
                if let mountedOnString = Optional(diskItemArray[5])?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    storageDevice.mountedOn = mountedOnString
                }
                
                return storageDevice
            } else {
                return nil
            }
        }
    }
    
    func cleanRawProcDiskStatsData(_ rawProcDiskStatsData: String) -> [String] {
        return rawProcDiskStatsData.components(separatedBy: "split")
    }
    
    func parseProcDiskStatsArray(_ procDiskStatsArray: [String]) -> [DeviceIO] {
        return procDiskStatsArray.compactMap { item in
            var deviceIO = DeviceIO()
            let items = item.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            guard items.count == 3 else { return nil }
            
            if let name = Optional(items[0]) {
                deviceIO.name = name
            }
            
            if let readString = Optional(items[1]),
               let readBytes = Int(readString) {
                deviceIO.read = readBytes
            }
            
            if let writeString = Optional(items[2]),
               let writeBytes = Int(writeString) {
                deviceIO.write = writeBytes
            }
            
            return deviceIO
        }
    }
}

struct StorageDevice {
    var fileSystem: String = ""
    var size: Int = 0
    var used: Int = 0
    var available: Int = 0
    var percentageUsed: Int = 0
    var mountedOn: String = ""
}

struct DeviceIO {
    var name: String = ""
    var read: Int = 0
    var write: Int = 0
}
