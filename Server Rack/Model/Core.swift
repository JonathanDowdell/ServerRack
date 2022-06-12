//
//  Core.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/8/22.
//

import SwiftUI

struct Core {
    var coreNumber: Int
    var temperature: CGFloat = 0.0
    var user: CGFloat = 0.0
    var idle: CGFloat = -1
    var system: CGFloat = 0.0
    var nice: CGFloat = 0.0
    var iowait: CGFloat = 0.0
    var steal: CGFloat = 0.0
    
    init(_ coreNumber: Int) {
        self.coreNumber = coreNumber
    }
}
