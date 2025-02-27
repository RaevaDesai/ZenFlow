//
//  LoginView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.784, green: 0.894, blue: 0.937)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("HealthTracker")
                    .font(.custom("Avenir Next Bold", size: 60))
                    .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5))
                    .padding(.bottom, 20)
                
                Button(action: onLogin) {
                    Text("Take a Photo")
                        .font(.custom("Avenir Next Bold", size: 20))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
