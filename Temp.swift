//
//  Temp.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct Temp: View {
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 3) {
                Text("3")
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                Text("K")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                Text("/")
                Text("s")
                    .padding(.leading, 2)
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 10)
            
            HStack(alignment: .bottom, spacing: 3) {
                Text("1")
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                Text("K")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "arrow.down")
                    .font(.subheadline)
                Text("/")
                Text("s")
                    .padding(.leading, 2)
            }
            .foregroundColor(.secondary)
        }
    }
}

struct Temp_Previews: PreviewProvider {
    static var previews: some View {
        Temp()
            .preferredColorScheme(.dark)
    }
}
