//
//  ServerSettingView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 6/9/22.
//

import SwiftUI

enum ThemeColor: Int, CaseIterable {
    
    case blue, red, green
    
    init(rawValue: Int) {
        switch rawValue {
        case 1: self = .blue
        case 2: self = .red
        case 3: self = .green
        default:
            self = .blue
        }
    }
    
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .red:
            return .red
        case .green:
            return .green
        }
    }
    
    var text: String {
        switch self {
        case .blue:
            return "Blue"
        case .red:
            return "Red"
        case .green:
            return "Green"
        }
    }
    
}

struct ServerSettingView: View {
    
    @AppStorage("coloringscheme") private var coloringScheme: ColoringScheme = .auto
    
    @AppStorage("temperature") private var temperatureType: TemperatureType = .fahrenheit
    
    var body: some View {
        List {
            Section("GENERAL") {
                Picker(selection: $coloringScheme) {
                    ForEach(ColoringScheme.allCases, id: \.self) { scheme in
                        Text(scheme.text)
                    }
                } label: {
                    Text("Appearance")
                }

                Picker(selection: $temperatureType) {
                    ForEach(TemperatureType.allCases, id: \.self) { temperature in
                        Text(temperature.text)
                    }
                } label: {
                    Text("Temperature")
                }
                
//                Picker(selection: $themeColor) {
//                    ForEach(ThemeColor.allCases, id: \.self) { themeColor in
//                        Text(themeColor.text)
//                    }
//                } label: {
//                    Text("Tint")
//                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct ServerSettingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ServerSettingView()
        }
    }
}


