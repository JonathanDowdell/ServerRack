//
//  StatusRing.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct StatusRing: View {
    
    var percent: CGFloat
    var startAngle: CGFloat
    var ringWidth: CGFloat
    var ringColor: Color
    var backgroundColor: Color
    var drawnClockwise: Bool
    
    var body: some View {
        ZStack {
            RingShape()
                .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .fill(backgroundColor)
            
            RingShape(percent: percent, startAngle: startAngle, drawnClockwise: drawnClockwise)
                .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .fill(ringColor)
        }
        .animation(.spring(), value: percent)
        .animation(.spring(), value: ringColor)
    }
}

struct CircleItem_Previews: PreviewProvider {
    static var previews: some View {
        StatusRing(
            percent: 50.0,
            startAngle: 90.0,
            ringWidth: 5,
            ringColor: .green,
            backgroundColor: Color(.systemGray6),
            drawnClockwise: true
        )
            .frame(width: 100, height: 100, alignment: .center)
    }
}
