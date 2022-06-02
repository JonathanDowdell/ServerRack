//
//  StatusItemModel.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

class StatusItemModel: SSHConnection, ObservableObject {
    
    @Published var temperature = ""
    
    @Published var cpuLoad: [CGFloat] = [0.01,0.01,0.01]
    
    @Published var cpuIdle: CGFloat = 99.9
    
    private var timer: Timer?
    
    private let userDefault = UserDefaults()
    
    init(server: Server) {
        super.init(server)
    }
    
    deinit {
        timer?.invalidate()
        
        print("Deinit - StatusItemModel")
    }
    
    fileprivate func fetchTemp() async throws {
        let tempType = TemperatureType(rawValue: userDefault.integer(forKey: "TemperatureType"))
        let data = (try await self.send(command: Commands.SysHwmonTemp.rawValue) ?? "").trimmingCharacters(in: .newlines)
        let celsius = Int((Double(data) ?? 0) * 0.001)
        switch tempType {
        case .fahrenheit:
            let fahrenheit = celsius * 9 / 5 + 32
            await MainActor.run {
                withAnimation {
                    self.temperature = String(fahrenheit)
                }
            }
        case .celsius:
            await MainActor.run {
                withAnimation {
                    self.temperature = String(celsius)
                }
            }
        }
    }
    
    fileprivate func fetchCpuLoad() async throws {
        let data = (try await self.send(command: Commands.TopTop.rawValue) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if let index = data.index(of: "load average: ") {
            let rawCpuLoad = data[index...]
                .replacingOccurrences(of: "load average: ", with: "")
                .replacingOccurrences(of: " ", with: "")
            let cpuLoad = rawCpuLoad.components(separatedBy: ",").compactMap { Double($0) }.map { max(0.001, CGFloat($0)) * 100 }
            await MainActor.run {
                print(cpuLoad)
                withAnimation(.spring()) {
                    self.cpuLoad = cpuLoad
                }
            }
        }
    }
    
    fileprivate func fetchCpuIdle() async throws {
        let data = (try await self.send(command: Commands.TopCPU.rawValue) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
        if let array = data.matchingStrings(regex: "(\\d+\\.\\d[id])").first, let rawIdle = array.first?.trimmingCharacters(in: .letters), let cpuIdle = Double(rawIdle) {
            await MainActor.run {
                withAnimation(.spring()) {
                    self.cpuIdle = cpuIdle
                }
            }
        }
    }
    
    fileprivate func fetchCpuUsage() async throws {
        let data = (try await self.send(command: Commands.TopTop.rawValue) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if let index = data.index(of: "load average: ") {
            let rawCpuLoad = data[index...]
                .replacingOccurrences(of: "load average: ", with: "")
                .replacingOccurrences(of: " ", with: "")
            let cpuLoad = rawCpuLoad.components(separatedBy: ",").compactMap { Double($0) }.map { max(0.001, CGFloat($0)) * 100 }
            await MainActor.run {
                print(cpuLoad)
                withAnimation(.spring()) {
                    self.cpuLoad = cpuLoad
                }
            }
        }
    }
    
    @objc func fetchData() {
        Task {
            try await fetchTemp()
            try await fetchCpuLoad()
            try await fetchCpuIdle()
        }
    }
    
    override func connect() async throws {
        if client == nil {
            try await super.connect()
            DispatchQueue.main.async {
                self.attachTimer()
            }
        }
    }
    
    override func disconnect() async throws {
        try await super.disconnect()
        DispatchQueue.main.async {
            self.dettachTimer()
        }
    }
    
    func attachTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(fetchData),
            userInfo: nil,
            repeats: true
        )
    }
    
    func dettachTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}



extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}
