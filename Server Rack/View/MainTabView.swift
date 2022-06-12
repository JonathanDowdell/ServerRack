//
//  MainTabView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct MainTabView: View {
    
    @AppStorage("themecolor") private var themeColor: ThemeColor = .blue
    
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
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
