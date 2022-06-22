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
    
    @EnvironmentObject var sshManager: SSHManager
    
    @State private var selectedConnection: SSHConnectionWrapper?
    
    @State private var shouldPresentServerDetailView = false
    
    @AppStorage("displaygrid") private var displayGridType: DisplayGridType = .stack
    
    private var columns: [GridItem] {
        switch displayGridType {
        case .stack:
            return stack
        case .grid:
            return grid
        }
    }
    
    private var stack:[GridItem] = [
        .init(.flexible())
    ]
    
    private var grid:[GridItem] = [
        .init(.adaptive(minimum: 120), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    NavigationLink("", isActive: $shouldPresentServerDetailView) {
                        if let selectedConnection = selectedConnection {
                            ServerStatusDetailView(sshConnectionWrapper: selectedConnection)
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 16) {
                        Section {
                            ForEach(sshManager.sshConnections, id: \.id) { connection in
                                Button {
                                    self.selectedConnection = connection
                                    self.shouldPresentServerDetailView = true
                                } label: {
                                    ServerStatusItem(connection: connection)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.default) {
                                        if displayGridType == .grid {
                                            displayGridType = .stack
                                        } else {
                                            displayGridType = .grid
                                        }
                                    }
                                } label: {
                                    switch displayGridType {
                                    case .stack:
                                        Image(systemName: "rectangle.grid.1x2.fill")
                                    case .grid:
                                        Image(systemName: "square.grid.3x2.fill")
                                    }
                                }
                            }
                            .padding(.trailing, 5)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Status")
            .toolbar {}
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("Disconnect")
            sshManager.disConnectAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("Connected")
            sshManager.connectAll()
        }
    }
}

struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusView()
    }
}
