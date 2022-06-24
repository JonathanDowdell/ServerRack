//
//  ServerStatusLineRingItem.swift
//  ServerRack
//
//  Created by Mettaworldj on 6/23/22.
//

import SwiftUI

struct ServerStatusLineRingItem: View {
    
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var head: some View {
        HStack {
            Text("Alpha")
                .bold()
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                Text("\(104)°F")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Button {
                    
                } label: {
                    Image(systemName: "square.3.stack.3d")
                        .foregroundColor(.accentColor)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "terminal")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                head
                
                HStack(alignment: .top, spacing: 25) {
                    VStack {
                        cpu
                        
                        load
                    }
                    
                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: 40,
                                startAngle: -90,
                                ringWidth: 5,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            
                            Group {
                                Text("\(Int8(40))%")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("Memory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 12) {
                        ZStack {
                            StatusRing(
                                percent: 4,
                                startAngle: -90,
                                ringWidth: 5,
                                ringColor: .green,
                                backgroundColor: Color(.systemGray4),
                                drawnClockwise: false
                            )
                            
                            
                            Group {
                                Text("4%")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .frame(width: 55, height: 55, alignment: .center)
                        
                        Text("Task")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                
            }
        }
    }
    
    var cpu: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * 0.5, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            HStack {
                Text("CPU")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
    
    var load: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * 0.9, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * 0.7, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * 0.5, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            HStack {
                Text("Load")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
    
    var memory: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(.systemGray4), lineWidth: 3)
                    .frame(height: 3, alignment: .center)
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * 0.3, height: 3, alignment: .center)
                }
                .frame(height: 3, alignment: .center)
            }
            
            HStack {
                Text("Memory")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
}

struct ServerStatusLineRingItem_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusLineRingItem(viewModel: .init())
    }
}

extension ServerStatusLineRingItem {
    class ViewModel: ObservableObject {
        
    }
}
