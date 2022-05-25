//
//  FlipView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import SwiftUI

struct FlipView<FrontView: View, BackView: View>: View {
    
    @State private var flipped = false
    
    private let impact = UIImpactFeedbackGenerator(style: .soft)
    
    private let frontView: FrontView
    
    private let backView: BackView
    
    init(
        @ViewBuilder frontView: () -> FrontView,
        @ViewBuilder backView: () -> BackView
    ) {
        self.frontView = frontView()
        self.backView = backView()
    }
    
    var body: some View {
        
        let flipDegrees = flipped ? 180.0 : 0
        
        return VStack {
            
            Spacer()
            
            ZStack() {
                frontView
                .flipRotate(flipDegrees)
                .opacity(flipped ? 0.0 : 1.0)
                
                backView
                .flipRotate(-180 + flipDegrees)
                .opacity(flipped ? 1.0 : 0.0)
            }
            .onTapGesture {
                impact.impactOccurred()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.flipped.toggle()
                }
            }
            
            Spacer()
            
        }
    }
}

extension View {
    
    func flipRotate(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    func placedOnCard(_ color: Color) -> some View {
        return padding(5).frame(width: 250, height: 150, alignment: .center).background(color)
    }
}

