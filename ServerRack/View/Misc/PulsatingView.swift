//
//  PulsatingView.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/27/22.
//

import SwiftUI

struct PulsatingView: View {
    
    @State private var animate = false
    
    private var state = 1
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ZStack {
                    Circle().fill(Color.accentColor.opacity(0.25))
                        .frame(width: max(0.01, proxy.size.width), height: max(0.01, proxy.size.height))
                        .scaleEffect(self.animate ? 1 : 0.01)
                    Circle().fill(Color.accentColor.opacity(0.35))
                        .frame(width: max(0.01, proxy.size.width - 10), height: max(0.01, proxy.size.height - 10))
                        .scaleEffect(self.animate ? 1 : 0.01)
                    Circle().fill(Color.accentColor.opacity(0.45))
                        .frame(width: max(0.01, proxy.size.width - 10 - 15), height: max(0.01, proxy.size.height - 10 - 15))
                        .scaleEffect(self.animate ? 1 : 0.01)
                    Circle().fill(Color.accentColor)
                        .frame(width: max(0.01, proxy.size.width - 10 - 15 - 8.75), height: max(0.01, proxy.size.height - 10 - 15 - 8.75))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        self.animate.toggle()
                    }
                }
            }
        }
    }
}

struct PulsatingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingView()
    }
}
