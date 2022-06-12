//
//  CacheWrapper.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/11/22.
//

import Foundation

class CacheWrapper<T>: NSObject {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}
