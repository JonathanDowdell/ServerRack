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
                        EmptyView()
                    }
                    LazyVGrid(columns: columns, spacing: 16) {
                        Section {
                            ForEach(servers, id: \.self) { server in
                                Button {
                                    selectedServer = server
                                    shouldPresentServerDetailView = true
                                } label: {
                                    ServerStatusItem(server: server)
                                        .environmentObject(sshContoller)
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
            }
            .navigationTitle("Status")
            .toolbar {}
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
