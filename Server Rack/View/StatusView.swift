//
//  StatusView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/23/22.
//

import SwiftUI
import Citadel

class StatusViewModel: ObservableObject {
    
    var sshConnection: SSHConnection?
    
    @Published var string = ""
    
    init() {
        let server = Server(context: PersistenceController.shared.container.viewContext)
        server.name = "Beta"
        server.host = "192.168.1.36"
        server.port = 22
        server.user = "dietpi"
        server.show = true
        
        Task {
            self.sshConnection = try await SSHConnection(server)
        }
    }
    
    func send() {
        Task {
            if let response = try await sshConnection?.send() {
                await MainActor.run {
                    self.string = response
                }
            }
        }
    }
    
    func connect() {
        Task {
            try await sshConnection?.connect()
        }
    }
    
    func disconnect() {
        Task {
            try await sshConnection?.disconnect()
        }
    }
}

struct StatusView: View {
    
    @StateObject var vm: StatusViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                vm.send()
            } label: {
                Text("Send Data")
            }
            
            Button {
                vm.connect()
            } label: {
                Text("Connect SSH")
            }
            
            Button {
                vm.disconnect()
            } label: {
                Text("Disconnect SSH")
            }
            
            Text(vm.string)
        }
        .onDisappear {
            print("Gone")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { output in
            vm.disconnect()
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(vm: .init())
    }
}
