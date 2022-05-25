//
//  StatusMultiRing.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/24/22.
//

import SwiftUI

struct StatusMultiRing: View {
    var percent: [CGFloat]
    var startAngle: CGFloat
    var ringWidth: CGFloat
    var ringSpaceOffSet: CGFloat
    var ringColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                StatusRing(
                    percent: Optional(percent[0]) ?? 0.001,
                    startAngle: -90,
                    ringWidth: ringWidth,
                    ringColor: ringColor,
                    backgroundColor: Color(.systemGray4),
                    drawnClockwise: false
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                StatusRing(
                    percent: Optional(percent[1]) ?? 0.001,
                    startAngle: -90,
                    ringWidth: ringWidth,
                    ringColor: ringColor,
                    backgroundColor: Color(.systemGray4),
                    drawnClockwise: false
                )
                .frame(width: geometry.size.width - ringSpaceOffSet, height: geometry.size.height - ringSpaceOffSet)
                
                StatusRing(
                    percent: Optional(percent[2]) ?? 0.001,
                    startAngle: -90,
                    ringWidth: ringWidth,
                    ringColor: ringColor,
                    backgroundColor: Color(.systemGray4),
                    drawnClockwise: false
                )
                .frame(width: geometry.size.width - ringSpaceOffSet - ringSpaceOffSet, height: geometry.size.height - ringSpaceOffSet - ringSpaceOffSet)
            }
        }
    }
}

struct StatusMultiRing_Previews: PreviewProvider {
    static var previews: some View {
        StatusMultiRing(
            percent: [100, 50, 20],
            startAngle: -90.0,
            ringWidth: 5,
            ringSpaceOffSet: 14,
            ringColor: .green
        )
            .frame(width: 50, height: 50, alignment: .center)
    }
}
