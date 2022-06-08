//
//  ServerStatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusItem: View {
    
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @AppStorage("temperature") private var temperatureType: TemperatureType = .fahrenheit
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    @StateObject private var viewModel: ViewModel
    
    private var server: Server

    init(server: Server) {
        self.server = server
        self._viewModel = StateObject(wrappedValue: ViewModel(server: server))
    }
    
    var body: some View {
        GroupBox {
            switch displayGridType {
            case .stack: stackLayout
            case .grid: gridLayout
            }
        }
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
        .onReceive(timer) { _ in
            getServerData()
        }
    }
    
    func connect() {
        self.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        self.viewModel.connect()
    }
    
    func disconnect() {
        self.timer.upstream.connect().cancel()
        self.viewModel.disconnect()
    }
    
    func getServerData() {
        viewModel.getServerData()
    }
}

extension ServerStatusItem {
    var gridLayout: some View {
        VStack(spacing: 12) {
            HStack {
                Text(server.name)
                    .bold()
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 15) {
                    if viewModel.loaded || !viewModel.cacheEmpty {
                        Group {
                            switch temperatureType {
                            case .fahrenheit:
                                Text("\(viewModel.cpu.fahrenheit)°F")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            case .celsius:
                                Text("\(viewModel.cpu.celsius)°C")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        PulsatingView()
                            .frame(width: 20, height: 20, alignment: .center)
                            .onAppear {
                                print(viewModel.cacheEmpty)
                            }
                    }
                }
            }
            
            FlipView {
                VStack(spacing: 12) {
                    StatusMultiRing(
                        percent: viewModel.cpuLoad,
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
                            percent: viewModel.cpuPercentage,
                            startAngle: -90,
                            ringWidth: 7,
                            ringColor: .green,
                            backgroundColor: Color(.systemGray4),
                            drawnClockwise: false
                        )
                        
                        Group {
                            if viewModel.cpuIdle == -1 {
                                Text("%")
                            } else {
                                Text("\(Int8(100.0 - viewModel.cpuIdle))%")
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
    
    var stackLayout: some View {
        VStack {
            head
                .padding(.bottom, 8)
            
            HStack {
                FlipView {
                    VStack(spacing: 12) {
                        StatusMultiRing(
                            percent: viewModel.cpuLoad,
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
                                percent: viewModel.cpuPercentage,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            
                            Group {
                                if viewModel.cpuIdle == -1 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(100.0 - viewModel.cpuIdle))%")
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
                
                Spacer()
                
                FlipView {
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: viewModel.memoryUsed,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Group {
                                if viewModel.memoryUsed == 0.001 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(viewModel.memoryUsed))%")
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
                            StatusRing(
                                percent: viewModel.swapUsed,
                                startAngle: -90,
                                ringWidth: 7,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            Group {
                                if viewModel.swapUsed == 0.001 {
                                    Text("%")
                                } else {
                                    Text("\(Int8(viewModel.swapUsed))%")
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
                
                Spacer()
                
                FlipView {
                    ServerIOStatusItem(
                        topValue: viewModel.networkUp,
                        topString: "upload",
                        bottomValue: viewModel.networkDown,
                        bottomString: "download"
                    )
                } backView: {
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("30")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                FlipView {
                    ServerIOStatusItem(
                        topValue: viewModel.totalReads,
                        topString: "Read",
                        bottomValue: viewModel.totalWrites,
                        bottomString: "Write"
                    )
                } backView: {
                    VStack {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("30")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 0.5)
                        
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("1")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                                .bold()
                            Text("K")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("/")
                                .font(.subheadline)
                            Text("s")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.leading, 2)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 9)
        }
    }
    
    var head: some View {
        HStack {
            Text(server.name)
                .bold()
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                if viewModel.loaded || !viewModel.cacheEmpty {
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
}

