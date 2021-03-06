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
    
    @AppStorage("coloringscheme") private var coloringScheme: ColoringScheme = .auto
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ServerCache.shared)
                .environmentObject(SSHManager.shared)
                .preferredColorScheme(coloringScheme.scheme)
        }
    }
}
