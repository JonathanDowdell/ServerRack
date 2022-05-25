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
    
}

struct StatusView: View {
    
    @StateObject var vm: StatusViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(vm.servers, id: \.self) { server in
                        StatusItem(vm: .init(server: server))
                    }
                    .onDelete { indexSet in
                        print(indexSet)
                    }
                    .onMove { indexSet, index in
                        print(indexSet)
                        print(index)
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


