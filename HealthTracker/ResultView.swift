//
//  ResultView.swift
//  HealthTracker
//
//  Created by Swarasai Mulagari on 1/05/25.
//

import SwiftUI

struct ResultView: View {
    var resultText: String
    var capturedImage: UIImage
    var onBack: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Meal Analysis")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding()
                    
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    
                    Text(formatResultText(resultText))
                        .font(.system(size: 16, design: .rounded))
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onBack) {
                        Text("Back to Scan")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
    
    private func formatResultText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let keyTerms = ["Bread", "Dairy product", "Dessert", "Egg", "Fried food", "Meat", "Noodles-Pasta", "Rice", "Seafood", "Soup", "Vegetable-Fruit", "Detected"]
        
        for term in keyTerms {
            if let range = attributedString.range(of: term) {
                attributedString[range].foregroundColor = .blue
                attributedString[range].font = .system(size: 18, weight: .bold, design: .rounded)
            }
        }
        
        return attributedString
    }
}
