//
//  MainTabView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            StatusView(vm: .init())
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Status")
                }
            
            ServerView(vm: .init())
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
