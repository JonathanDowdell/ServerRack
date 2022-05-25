//
//  Server+CoreDataProperties.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//
//

import Foundation
import KeychainAccess
import CoreData


extension Server {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Server> {
        return NSFetchRequest<Server>(entityName: "Server")
    }

    @NSManaged public var name: String
    @NSManaged public var host: String
    @NSManaged public var port: Int32
    @NSManaged public var order: Int16
    @NSManaged public var user: String
    @NSManaged public var encrypted_password: Data?
    @NSManaged public var show: Bool

    var password: String {
        get {
            guard
                let data = encrypted_password,
                let decryptedData = SecurityManager.shared.decrypt(data, using: SecurityKey.Password.rawValue),
                let password = String(data: decryptedData, encoding: .utf8)
            else { return "" }
            
            return password
        }
        set {
            guard
                let data = newValue.data(using: .utf8),
                let encryptedData = SecurityManager.shared.encrypt(data, using: SecurityKey.Password.rawValue)
            else { return }
            self.encrypted_password = encryptedData
        }
    }
}

extension Server : Identifiable {

}
