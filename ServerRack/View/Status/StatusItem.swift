//
//  StatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI



struct StatusItem: View {
    
    @StateObject var vm: ViewModel
    
    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack {
                    Text(vm.server.name)
                        .bold()
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Text("\(vm.temperature)°F")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            let userDefault = UserDefaults()
                            userDefault.set(Int.random(in: 0...1), forKey: "TemperatureType")
                        } label: {
                            Image(systemName: "drop")
                                .foregroundColor(.accentColor)
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "terminal")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                HStack {
                    FlipView {
                        VStack(spacing: 12) {
                            StatusMultiRing(
                                percent: vm.cpuLoad,
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
                                StatusRing(
                                    percent: 100.0 - vm.cpuIdle,
                                    startAngle: -90,
                                    ringWidth: 7,
                                    ringColor: .green,
                                    backgroundColor: Color(.systemGray4),
                                    drawnClockwise: false
                                )
                                
                                Text("\(Int8(100.0 - vm.cpuIdle))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 55, height: 55, alignment: .center)
                            
                            Text("CPU")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.leading, 2)

                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: 100.0 - vm.cpuIdle,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Text("\(Int8(100.0 - vm.cpuIdle))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("Mem")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 40)
                    
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("3")
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.subheadline)
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.subheadline)
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("3")
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.subheadline)
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.subheadline)
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(maxWidth: 15, alignment: .center)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("Disconnect")
            disconnect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("Connect")
            connect()
        }
        
    }
    
    func connect() {
        Task {
            try await vm.connect()
        }
    }
    
    func disconnect() {
        Task {
            try await vm.disconnect()
        }
    }
}

extension StatusItem {
    class ViewModel: SSHConnection, ObservableObject {
        
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
            
            print("Deinit - ViewModel")
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
}

//struct StatusViewItem_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusViewItem()
//    }
//}
