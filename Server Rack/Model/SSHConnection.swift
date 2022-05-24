//
//  SSHConnection.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import Foundation
import Citadel

class SSHConnection {
    var client: SSHClient?
    
    private let server: Server
    
    init(_ server: Server) async throws {
        self.server = server
        try await connect()
    }
    
    func send() async throws -> String? {
        if let client = client {
            let blob = try await client.executeCommand("echo \(UUID().uuidString)")
            return blob.getString(at: 0, length: blob.readableBytes)
        } else {
            print("Please Connect to Server")
            return nil
        }
    }
    
    func connect() async throws {
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
    }
    
    func disconnect() async throws {
        try await client?.close()
        client = nil
        print("Disconnected from Server")
    }
}
