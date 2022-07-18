//
//  ServerConfigThemeView.swift
//  ServerRack
//
//  Created by Mettaworldj on 7/7/22.
//

import SwiftUI

struct ServerConfigThemeView: View {
    
    @State var selected: Int? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Section {
                    Button {
                        selected = 2
                    } label: {
                        ZStack {
                            if selected == 2 {
                                Color.accentColor
                                    .opacity(0.8)
                            }
                            
                            ServerStatusRingMetricItem(viewModel: .init(name: "Server", temperature: 1000))
                                .padding(2)
                        }
                    }
                    .cornerRadius(10)
                    
                    Button {
                        selected = 1
                    } label: {
                        ZStack {
                            if selected == 1 {
                                Color.accentColor
                                    .opacity(0.8)
                            }
                            
                            ServerStatusLineRingItem(viewModel: .init(name: "Server", temperature: 1000))
                                .padding(2)
                        }
                    }
                    .cornerRadius(10)
                } header: {
                    HStack {
                        Text("")
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Server Theme")
    }
}

struct ServerConfigThemeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerConfigThemeView()
        }
    }
}
