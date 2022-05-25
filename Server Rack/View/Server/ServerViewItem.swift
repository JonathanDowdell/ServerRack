//
//  ServerViewItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct ServerViewItem: View {
    
    var server: Server
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(server.name)
                    .foregroundColor(.primary)
                    .bold()
                
                Text("\(server.user)@\(server.host)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "terminal")
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 5)
    }
}

//struct ServerViewItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerViewItem(server: <#Server#>)
//    }
//}
