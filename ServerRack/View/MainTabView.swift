//
//  MainTabView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct MainTabView: View {
    
    @AppStorage("themecolor") private var themeColor: ThemeColor = .blue
    
    @EnvironmentObject var sshManager: SSHManager
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    fileprivate func deleteObjectsForDeletion() {
        let servers = ServerStorage.shared.servers.value
        let activeServers = sshManager.sshConnections.map { $0.connection.server }
        let differences = activeServers.differences(of: Array(servers))
        for difference in differences {
            managedObjectContext.delete(difference)
        }
        try? managedObjectContext.save()
    }
    
    var body: some View {
        TabView {
            ServerStatusView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Status")
                }
            
            ServerConfigListView()
                .tabItem {
                    Image(systemName: "server.rack")
                    Text("Servers")
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
            deleteObjectsForDeletion()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}


extension Array where Element: Hashable {
    func differences(of other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
