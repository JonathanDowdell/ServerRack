//
//  ServerView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import Combine
import SwiftUI
import CoreData

class ServerViewModel: ObservableObject {
    
    @Published var presentCreateServerView = false
    
    @Published var servers = [Server]()
    
    private let context: NSManagedObjectContext
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init(
        serverPublisher: AnyPublisher<[Server], Never> = ServerStorage.shared.servers.eraseToAnyPublisher(),
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.context = context
        
        serverPublisher.sink { [weak self] servers in
            guard let self = self else { return }
            withAnimation {
                self.servers = servers
            }
        }
        .store(in: &cancellableSet)
    }
    
    func deleteServer(_ offSet: IndexSet) {
        for index in offSet {
            let server = servers[index]
            servers.remove(at: index)
            context.delete(server)
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func moveServer(_ offSet: IndexSet, _ destination: Int) {
        var revisedServers = servers.map { $0 }
        revisedServers.move(fromOffsets: offSet, toOffset: destination)
        
        for revisedIndex in stride(from: revisedServers.count - 1, through: 0, by: -1) {
            revisedServers[revisedIndex].order = Int16(revisedIndex)
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
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
                    ForEach(vm.servers, id: \.self) { server in
                        ServerViewItem(server: server)
                    }
                    .onDelete { indexSet in
                        vm.deleteServer(indexSet)
                    }
                    .onMove { offSet, destination in
                        vm.moveServer(offSet, destination)
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
                        vm.presentCreateServerView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $vm.presentCreateServerView) {
                ServerCreateView(vm: .init())
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView(vm: .init())
    }
}


