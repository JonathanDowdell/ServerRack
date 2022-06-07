//
//  ServerConfigView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/1/22.
//

import SwiftUI

struct ServerConfigView: View {
    
    @State private var name = ""
    @State private var host = ""
    @State private var port = "22"
    @State private var user = ""
    @State private var password = ""
    @State private var showStatus = true
    @FocusState private var focusedField: Field?
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Environment(\.managedObjectContext) private var moc
    
    var server: Server?
    
    var body: some View {
        Form {
            HStack {
                Text("Name")
                Spacer()
                TextField("Diplay Name", text: $name)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit(focusNextField)
            }
            
            HStack {
                Text("Host")
                Spacer()
                TextField("IP or Domain", text: $host)
                    .multilineTextAlignment(.trailing)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .host)
                    .submitLabel(.next)
                    .onSubmit(focusNextField)
            }
            
            HStack {
                Text("Port")
                Spacer()
                TextField("Port", text: $port)
                    .multilineTextAlignment(.trailing)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .port)
                    .submitLabel(.next)
                    .onSubmit(focusNextField)
            }
            
            Section("Authentication") {
                HStack {
                    Text("User")
                    Spacer()
                    TextField("Admin", text: $user)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .user)
                        .submitLabel(.next)
                        .onSubmit(focusNextField)
                }
                
                HStack {
                    Text("Password")
                    Spacer()
                    SecureField("Password", text: $password)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit(focusNextField)
                }
            }
            
            Toggle("Show in Status", isOn: $showStatus)
        }
        .navigationTitle("Add Server")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                    saveServer()
                } label: {
                    Text("Save")
                }
            }
        }
        .onAppear {
            if let server = server {
                self.name = server.name
                self.host = server.host
                self.port = String(server.port)
                self.user = server.user
                self.password = server.password
                self.showStatus = server.show
            }
        }
    }
    
}

extension ServerConfigView {
    private func saveServer() {
        if let server = server {
            server.name = self.name
            server.host = self.host
            server.port = Int32(self.port) ?? 22
            server.user = self.user
            server.password = self.password
            server.show = self.showStatus
        } else {
            let server = Server(context: moc)
            server.id = UUID()
            server.name = self.name
            server.host = self.host
            server.port = Int32(self.port) ?? 22
            server.user = self.user
            server.password = self.password
            server.show = self.showStatus
        }
        
        try? moc.save()
    }
}

extension ServerConfigView {
    private enum Field: Int, Hashable, CaseIterable {
    case name, host, port, user, password
    }
    
    private func focusNextField() {
        focusedField = focusedField.map {
            Field(rawValue: $0.rawValue + 1) ?? .name
        }
    }
}

struct ServerConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ServerConfigView()
    }
}
