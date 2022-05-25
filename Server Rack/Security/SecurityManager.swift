//
//  SecurityManager.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import RNCryptor
import Foundation
import KeychainAccess

enum SecurityKey: String {
case Password = "pwd-key"
}

class SecurityManager {
    
    static let shared = SecurityManager(keychain: .init())
    
    private let keychain: Keychain
    
    init(keychain: Keychain) {
        self.keychain = keychain
        let key = SecurityKey.Password.rawValue
        if (try? self.keychain.get(key)) == nil {
            let newPassword = UUID().uuidString
            try? self.keychain.set(newPassword, key: key)
        }
    }
    
    func encrypt(_ data: Data, using key: String) -> Data? {
        guard
            let password = try? self.keychain.get(key)
        else { return nil }
        
        return RNCryptor.encrypt(data: data, withPassword: password)
    }
    
    func decrypt(_ data: Data, using key: String) -> Data? {
        guard
            let password = try? self.keychain.get(key)
        else { return nil }
        
        return try? RNCryptor.decrypt(data: data, withPassword: password)
    }
}
