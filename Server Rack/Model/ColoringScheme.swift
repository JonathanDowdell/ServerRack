//
//  ColoringScheme.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/9/22.
//

import SwiftUI

enum ColoringScheme: Int, CaseIterable {
    case auto, light, dark
    
    init(rawValue: Int) {
        switch rawValue {
        case 1: self = .light
        case 2: self = .dark
        default:
            self = .auto
        }
    }
    
    var text: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .auto:
            return "Auto"
        }
    }
    
    var scheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return nil
        }
    }
}
