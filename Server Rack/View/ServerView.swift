//
//  ServerView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

class ServerViewModel: ObservableObject {
    @Published var presentCreateServerView = false
}

struct ServerView: View {
    
    @StateObject var vm: ServerViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Text("Settings")
                            .foregroundColor(.accentColor)
                    }
                }
                
                Section("Servers") {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Beta")
                                .foregroundColor(.primary)
                                .bold()
                            
                            Text("192.168.1.36")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "terminal")
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.presentCreateServerView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $vm.presentCreateServerView) {
                ServerCreateView()
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView(vm: .init())
    }
}

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
        .padding(.vertical, 2)
    }
}
