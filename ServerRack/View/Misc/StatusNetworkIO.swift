//
//  StatusNetworkIO.swift
//  ServerRack
//
//  Created by Mettaworldj on 7/7/22.
//

import SwiftUI

struct StatusNetworkIO: View {
    var body: some View {
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

struct StatusNetworkIO_Previews: PreviewProvider {
    static var previews: some View {
        StatusNetworkIO()
    }
}
