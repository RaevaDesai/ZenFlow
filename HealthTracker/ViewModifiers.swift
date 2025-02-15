//
//  ViewModifiers.swift
//  HealthTracker
//
//  Created by Swarasai Mulagari on 1/05/25.
//

import SwiftUI

struct OrangeYellowGradient: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]),
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .cornerRadius(10)
    }
}

extension View {
    func orangeYellowGradient() -> some View {
        self.modifier(OrangeYellowGradient())
    }
}
