//
//  Server_RackApp.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/23/22.
//

import SwiftUI

@main
struct Server_RackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ServerCache.shared)
        }
    }
}
