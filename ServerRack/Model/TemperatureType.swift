//
//  TemperatureType.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import Foundation

enum TemperatureType: Int, CaseIterable {
    case fahrenheit = 0
    case celsius = 1
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .fahrenheit
        case 1: self = .celsius
        default: self = .fahrenheit
        }
    }
    
    var text: String {
        switch self {
        case .fahrenheit:
            return "Fahrenheit"
        case .celsius:
            return "Celsius"
        }
    }
}
