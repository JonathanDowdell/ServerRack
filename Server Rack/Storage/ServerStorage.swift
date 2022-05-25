//
//  ServerStorage.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import Foundation
import CoreData
import Combine

class ServerStorage: NSObject {
    
    static let shared = ServerStorage()
    
    var servers = CurrentValueSubject<[Server], Never>([])
    
    private let serverFetchController: NSFetchedResultsController<Server>
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        
        let fetchRequest = Server.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "order", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
        ]
        
        serverFetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        serverFetchController.delegate = self
        
        do {
            try serverFetchController.performFetch()
            servers.value = serverFetchController.fetchedObjects ?? []
        } catch {
            print(error)
        }
    }
    
}

extension ServerStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let servers = controller.fetchedObjects as? [Server] else { return }
        self.servers.value = servers
    }
}
