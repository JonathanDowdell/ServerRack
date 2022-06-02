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
    
    @State private var presentServerConfigView = false
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Settings") {
                    EmptyView()
                }
                .foregroundColor(.accentColor)
                
                NavigationLink("Keychain") {
                    EmptyView()
                }
                .foregroundColor(.accentColor)

                
                Section("Servers") {
                    ForEach(servers, id: \.self) { server in
                        NavigationLink {
                            ServerConfigView(server: server)
                        } label: {
                            ServerViewItem(server: server)
                        }
                    }
                    .onDelete { indexSet in
                        
                    }
                    .onMove { offSet, destination in
                        
                    }
                    .onDrag {
                        NSItemProvider()
                    }
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
