//
//  ServerCreateView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct ServerCreateView: View {
    
    @State var name = ""
    
    @State var host = ""
    
    @State var port = "22"
    
    @State var user = ""
    
    @State var password = ""
    
    @State var showStatus = true
    
    @Environment(\.managedObjectContext) var moc
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Diplay Name", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Host")
                    Spacer()
                    TextField("IP or Domain", text: $host)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                }
                
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("Port", text: $port)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                }
                
                Section("Authentication") {
                    HStack {
                        Text("User")
                        Spacer()
                        TextField("admin", text: $user)
                            .multilineTextAlignment(.trailing)
                            .disableAutocorrection(true)
                    }
                    
                    HStack {
                        Text("Password")
                        Spacer()
                        SecureField("Password", text: $password)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Toggle("Show in Status", isOn: $showStatus)
            }
            .navigationTitle("Add Server")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let server = Server(context: moc)
                        server.name = name
                        server.host = host
                        server.port = Int32(port) ?? 22
                        server.user = user
                        server.show = showStatus
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }

                }
            }
        }
    }
}

struct ServerCreateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerCreateView()
        }
    }
}
