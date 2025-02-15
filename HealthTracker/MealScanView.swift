//
//  MealScanView.swift
//  HealthTracker
//
//  Created by Swarasai Mulagari on 1/05/25.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct MealScanView: View {
    @State private var image: UIImage?
    @State private var resultText: String = ""
    @State private var isImageCaptured: Bool = false
    @State private var isLoading: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showResults: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Meal Scan")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("Capture a meal image to get started")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Button(action: {
                    self.showImagePicker = true
                }) {
                    Text("Capture Meal Image")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Analyzing...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .camera, selectedImage: $image) { capturedImage in
                if let capturedImage = capturedImage {
                    analyzeImage(capturedImage)
                }
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            if let image = image {
                ResultView(resultText: resultText, capturedImage: image) {
                    showResults = false
                    self.image = nil
                    resultText = ""
                }
            }
        }
    }
    
    private func analyzeImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            showResult(resultText: "Failed to process image.")
            return
        }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config = MLModelConfiguration()
                let model = try VNCoreMLModel(for: mealscan(configuration: config).model)
                
                let request = VNCoreMLRequest(model: model) { request, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.showResult(resultText: "Error analyzing image: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    guard let results = request.results as? [VNClassificationObservation] else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.showResult(resultText: "Unexpected result type from VNCoreMLRequest")
                        }
                        return
                    }
                    
                    if let topResult = results.first {
                        let foodItem = topResult.identifier
                        let confidence = topResult.confidence
                        print("Detected food: \(foodItem) with confidence: \(confidence)")
                        let message = self.getMessage(for: foodItem)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.showResult(resultText: "Detected: \(foodItem)\n\n\(message)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.showResult(resultText: "Unable to classify the image.")
                        }
                    }
                }
                
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
                try handler.perform([request])
            } catch {
                print("Error setting up Vision with CoreML: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showResult(resultText: "Error setting up image analysis.")
                }
            }
        }
    }
    
    private func showResult(resultText: String) {
        self.resultText = resultText
        self.showResults = true
    }
    
    private func getMessage(for condition: String) -> String {
        switch condition {
        case "Bread":
            return "Bread detected. While it provides carbohydrates for energy (about 15g per slice), opt for whole grain varieties for more fiber (3-4g per slice) and nutrients like B vitamins and iron. A slice typically contains 70-80 calories. Moderation is key for weight management, aim for 1-2 slices per meal."
            
        case "Dairy product":
            return "Dairy product found. Excellent source of calcium (300mg per cup of milk) and protein (8g per cup). If you're looking to reduce fat intake, consider low-fat options which have 0-2% fat content. Dairy can support bone health and muscle recovery with its combination of protein and nutrients like vitamin D. Aim for 2-3 servings per day."
            
        case "Dessert":
            return "Dessert identified. While enjoyable, desserts are often high in sugar (20-30g per serving) and calories (200-400 per serving). They typically offer little nutritional value. Consume in moderation, limiting to 1-2 small servings per week if you're focusing on weight loss or maintaining a balanced diet. Consider fruit-based desserts for a healthier option."
            
        case "Egg":
            return "Eggs detected! Excellent source of high-quality protein (6g per egg) and various nutrients including vitamin D, B12, and choline. One large egg contains about 70 calories. They can support muscle building and provide satiety, aiding in weight management. Aim for 1-2 eggs per day as part of a balanced diet."
            
        case "Fried food":
            return "Fried food spotted. While tasty, fried foods are typically high in calories (300-500 per serving) and unhealthy trans fats. They can add 100-200 extra calories compared to non-fried versions. Limit consumption to once a week or less for better heart health and to support weight loss goals. Consider air-frying or baking as healthier alternatives."
            
        case "Meat":
            return "Meat identified. Excellent source of protein (20-25g per 3oz serving) and iron (2-3mg per serving). Lean meats like chicken or turkey breast have fewer calories (about 120 per 3oz) compared to fattier cuts. They can support muscle growth and repair. Aim for 3-4oz portions, and choose lean cuts or plant-based alternatives for overall health."
            
        case "Noodles-Pasta":
            return "Noodles or pasta detected. Provides carbohydrates for energy (about 40g per cup cooked). Choose whole grain options for more fiber (6g vs 2g per cup) and nutrients like B vitamins. A typical serving is 1/2 to 1 cup cooked (200-220 calories). Be mindful of portion sizes and added sauces if managing weight."
            
        case "Rice":
            return "Rice found on your plate. A staple carbohydrate source providing about 45g of carbs per cup cooked. Brown rice offers more fiber (3.5g vs 0.6g per cup) and nutrients like magnesium compared to white rice. A typical serving is 1/2 to 1 cup cooked (100-200 calories). Portion control is important for weight management."
            
        case "Seafood":
            return "Seafood detected. Excellent source of lean protein (20-25g per 3oz serving) and omega-3 fatty acids (particularly in fatty fish like salmon, providing 1.5-2g per 3oz). Supports heart health and can aid in maintaining a healthy weight. Aim for 2-3 servings per week. Great choice for most fitness goals due to its high protein and healthy fat content."
            
        case "Soup":
            return "Soup identified. Can be a nutritious, low-calorie option (50-100 calories per cup for broth-based soups) depending on ingredients. Broth-based soups can help with hydration and feeling full, supporting weight management. Vegetable-rich soups provide fiber and nutrients. Be cautious of cream-based soups which can be high in calories and fat."
            
        case "Vegetable-Fruit":
            return "Vegetables or fruits detected. Excellent choice! Rich in vitamins, minerals, and fiber (3-8g per serving). Low in calories (usually 30-50 per serving for non-starchy vegetables, 60-90 for fruits) and high in nutrients, they support overall health and can aid in weight management. Aim for 5-9 servings per day, filling half your plate with fruits and vegetables."
            
        default:
            return "This food item may not directly align with common fitness goals. Remember, a balanced diet with a variety of nutrients is key to supporting your overall health and fitness. Aim for a mix of carbohydrates, proteins, and healthy fats, and include plenty of fruits, vegetables, and whole grains in your diet."
        }
    }
}
