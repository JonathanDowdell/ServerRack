//
//  TempStatus.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct TempStatus: View {
    
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var server: Server
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onReceive(timer) { input in
                print(input)
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
            .onAppear {
                timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            }
    }
}

//struct TempStatus_Previews: PreviewProvider {
//    static var previews: some View {
//        TempStatus()
//    }
//}
