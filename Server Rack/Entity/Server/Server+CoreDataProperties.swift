//
//  Server+CoreDataProperties.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//
//

import Foundation
import CoreData


extension Server {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Server> {
        return NSFetchRequest<Server>(entityName: "Server")
    }

    @NSManaged public var name: String
    @NSManaged public var host: String
    @NSManaged public var port: Int32
    @NSManaged public var user: String
    @NSManaged public var encrypted_password: Data?
    @NSManaged public var show: Bool

    var password: String {
        get {
            return "Pro2711,."
        }
    }
}

extension Server : Identifiable {

}
