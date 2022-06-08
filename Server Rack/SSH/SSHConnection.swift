//
//  SSHConnection.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import Foundation
import Citadel

protocol SSHConnectionProtocol {
    func send(command: String) async throws -> String?
    func connect() async throws
    func disconnect() async throws
}

class SSHConnection: SSHConnectionProtocol {
    var client: SSHClient?
    
    let server: Server
    
    init(_ server: Server) {
        self.server = server
        print("SSHConnection - Initialized")
    }
    
    deinit {
        print("SSHConnection - Dinitialized")
    }
    
    func send(command: String) async throws -> String? {
        if let client = client {
            let blob = try await client.executeCommand(command)
            return blob.getString(at: 0, length: blob.readableBytes)
        } else {
            print("Please Connect to Server")
            return nil
        }
    }
    
    func connect() async throws {
        if client == nil {
            let host = server.host
            let port = server.port
            let user = server.user
            let password = server.password
            self.client = try await SSHClient.connect(
                host: host, port: Int(port),
                authenticationMethod: .passwordBased(username: user, password: password),
                hostKeyValidator: .acceptAnything(),
                reconnect: .never
            )
            print("Connected to Server")
        } else {
            print("Already Connected to Server")
        }
    }
    
    func disconnect() async throws {
        try await client?.close()
        client = nil
        print("Disconnected from Server")
    }
}
