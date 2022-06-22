//
//  StatusRingItem.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct StatusItemRing: View {
    
    @State private var progressValues = [0.0, 0.0, 0.0, 0.0]
    
    var body: some View {
        StatusMultiRing(
            percent: [100, 40, 20],
            startAngle: -90,
            ringWidth: 10,
            ringSpaceOffSet: 23,
            ringColor: .green
        )
        .frame(width: 100, height: 100, alignment: .center)
    }
}

struct StatusRing_Previews: PreviewProvider {
    static var previews: some View {
        StatusItemRing()
    }
}


