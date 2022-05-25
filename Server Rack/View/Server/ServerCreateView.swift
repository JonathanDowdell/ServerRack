//
//  ServerCreateView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI
import Combine
import CoreData

class ServerCreateViewModel: ObservableObject {
    
    @Published var name = ""
    
    @Published var host = ""
    
    @Published var port = "22"
    
    @Published var user = ""
    
    @Published var password = ""
    
    @Published var showStatus = true
    
    @Published var servers = [Server]()
    
    private let context: NSManagedObjectContext
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init(
        server: Server? = nil,
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
        
        if let server = server {
            self.name = server.name
            self.host = server.host
            self.port = String(server.port)
            self.user = server.user
            self.password = server.password
            self.showStatus = server.show
        }
    }
    
    func saveServer() {
        let server = Server(context: context)
        server.name = name
        server.host = host
        server.port = Int32(port) ?? 22
        server.user = user
        server.show = showStatus
        server.password = password
        
        try? context.save()
    }
    
}

struct ServerCreateView: View {
    
    @StateObject var vm: ServerCreateViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Diplay Name", text: $vm.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Host")
                    Spacer()
                    TextField("IP or Domain", text: $vm.host)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("Port", text: $vm.port)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                
                Section("Authentication") {
                    HStack {
                        Text("User")
                        Spacer()
                        TextField("Admin", text: $vm.user)
                            .multilineTextAlignment(.trailing)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    
                    HStack {
                        Text("Password")
                        Spacer()
                        SecureField("Password", text: $vm.password)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Toggle("Show in Status", isOn: $vm.showStatus)
            }
            .navigationTitle("Add Server")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.saveServer()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct ServerCreateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerCreateView(vm: .init())
        }
    }
}
