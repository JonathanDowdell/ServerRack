//
//  ServerStatusView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct ServerStatusView: View {
    
    @FetchRequest(
        entity: Server.entity(),
        sortDescriptors: [
        NSSortDescriptor(key: "order", ascending: true),
        NSSortDescriptor(key: "name", ascending: true),
        ],
        predicate: NSPredicate(format: "show == %@", NSNumber(booleanLiteral: true))
    ) private var servers: FetchedResults<Server>
    
    @State private var selectedServer: Server?
    
    @State private var shouldPresentServerDetailView = false
    
    @StateObject private var sshContoller: SSHController = .init()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    NavigationLink("", isActive: $shouldPresentServerDetailView) {
                        EmptyView()
                    }
                    VStack {
                        ForEach(servers, id: \.self) { server in
                            Button {
                                selectedServer = server
                                shouldPresentServerDetailView = true
                            } label: {
                                ServerStatusItem(server: server)
                                    .environmentObject(sshContoller)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                        }
                    }
                }
            }
            .navigationTitle("Status")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusView()
    }
}

extension ServerStatusView {
    
}

class SSHController: ObservableObject {
    var connections: [ObjectIdentifier:SSHConnection] = .init()
}
