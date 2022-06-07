//
//  ServerCache.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/4/22.
//

import Foundation

class ServerCache: ObservableObject {
    
    static let shared = ServerCache()
    
    @Published var cache: [String: [String: Any]] = .init()
    
}
