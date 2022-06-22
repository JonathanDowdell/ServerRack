//
//  ServerConfigListView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/1/22.
//

import SwiftUI

struct ServerConfigListView: View {
    
    @FetchRequest(
        entity: Server.entity(),
        sortDescriptors: [
        NSSortDescriptor(key: "order", ascending: true),
        NSSortDescriptor(key: "name", ascending: true),
        ]
    ) private var servers: FetchedResults<Server>
    
    @EnvironmentObject var sshManager: SSHManager
    
    @State private var presentServerConfigView = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    private func deleteServer(with indexSet: IndexSet) {
        for index in indexSet {
            let server = servers[index]
            sshManager.removeConnection(for: server)
        }
    }
    
    private func moveServer(offSet: IndexSet, destination: Int) {
        
    }
    
    private func onDrag() -> NSItemProvider {
        return NSItemProvider()
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Settings") {
                    ServerSettingView()
                }
                .foregroundColor(.accentColor)
                
                NavigationLink("Keychain") {
                    EmptyView()
                }
                .foregroundColor(.accentColor)

                
                Section("Servers") {
                    ForEach(sshManager.sshConnections, id: \.id) { wrapper in
                        NavigationLink {
                            ServerConfigView(server: wrapper.connection.server)
                        } label: {
                            ServerConfigItem(server: wrapper.connection.server)
                        }
                        .id("\(wrapper.connection.server.name)\(wrapper.connection.server.user)\(wrapper.connection.server.host)")
                    }
                    .onDelete(perform: deleteServer(with:))
                    .onMove(perform: moveServer(offSet:destination:))
                    .onDrag(onDrag)
                }
            }
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentServerConfigView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentServerConfigView) {
                NavigationView {
                    ServerConfigView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    presentServerConfigView = false
                                } label: {
                                    Text("Cancel")
                                }
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ServerConfigListView_Previews: PreviewProvider {
    static var previews: some View {
        ServerConfigListView()
    }
}
