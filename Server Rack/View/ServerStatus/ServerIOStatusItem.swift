//
//  ServerIOStatusItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/1/22.
//

import SwiftUI

struct ServerIOStatusItem: View {
    
    let topValue: Double
    
    let topString: String
    
    let bottomValue: Double
    
    let bottomString: String
    
    private func valueConversion(_ value: Double) -> String {
        if value < 999 {
            return String(Int(value))
        } else {
            return "\(String(format: "%.1f", (value / 1024).rounded(toPlaces: 1)))"
        }
    }
    
    private func unitTypeConversion(_ value: Double) -> String {
        if value > 999 {
            return "G"
        } else {
            return "M"
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 3) {
                HStack(alignment: .bottom, spacing: 3) {
                    Text(valueConversion(topValue))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                        .bold()
                    
                    Text(unitTypeConversion(topValue))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text(topString)
                        .font(.system(.caption2, design: .monospaced))
                        .padding(.leading, 2)
                }
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 7.5)
            
            VStack(spacing: 3) {
                HStack(alignment: .bottom, spacing: 3) {
                    Text(valueConversion(bottomValue))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                        .bold()
                    
                    Text(unitTypeConversion(bottomValue))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text(bottomString)
                        .font(.system(.caption2, design: .monospaced))
                        .padding(.leading, 2)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ServerIOStatusItem_Previews: PreviewProvider {
    static var previews: some View {
        ServerIOStatusItem(topValue: 456, topString: "Read", bottomValue: 61, bottomString: "Write")
    }
}
