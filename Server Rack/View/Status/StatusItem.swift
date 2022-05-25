//
//  StatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI



struct StatusItem: View {
    
    @StateObject var vm: StatusItemModel
    
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

//struct StatusViewItem_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusViewItem()
//    }
//}
