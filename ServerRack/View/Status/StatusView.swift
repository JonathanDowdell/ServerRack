//
//  StatusView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/23/22.
//

import SwiftUI
import Citadel
import Combine
import CoreData

class StatusViewModel: ObservableObject {
    
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

struct StatusView: View {
    
    @StateObject var vm: StatusViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(vm.servers, id: \.self) { server in
//                        StatusItem(vm: .init(server: server))
//                        TempStatus(server: server)
                    }
                    .onDelete { indexSet in
                        vm.deleteServer(indexSet)
                    }
                    .onMove { indexSet, index in
                        vm.moveServer(indexSet, index)
                    }
                    .onDrag {
                        NSItemProvider()
                    }
                }
            }
            .navigationTitle("Status")
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(vm: .init())
    }
}


