//
//  ServerStatusDetailMetric.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/18/22.
//

import SwiftUI

struct ServerStatusDetailMetric: View {
    
    var color: Color? = nil
    
    var label: String
    
    var value: String
    
    var valueMetric: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center, spacing: 5) {
                if let color = color {
                    Rectangle()
                        .fill(color)
                        .frame(width: 5, height: 10, alignment: .center)
                        .cornerRadius(10)
                }
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .bottom, spacing: 3) {
                Text(value)
                    .font(.system(.caption, design: .rounded))
                    .bold()
                Text(valueMetric)
                    .font(.caption2)
            }
        }
    }
}
struct ServerStatusDetailMetric_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusDetailMetric(label: "123", value: "123", valueMetric: "D")
    }
}
