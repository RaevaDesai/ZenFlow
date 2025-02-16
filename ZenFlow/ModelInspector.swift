import Foundation
import CoreML

func inspectModel() {
    guard let modelURL = Bundle.main.url(forResource: "PositiveAffirmationML", withExtension: "mlmodelc") else {
        print("Model file not found")
        return
    }
    
    do {
        let mlmodel = try MLModel(contentsOf: modelURL)
        let spec = mlmodel.modelDescription
        
        print("\nModel Outputs:")
        for output in spec.outputDescriptionsByName {
            print("- \(output.key): \(output.value.type)")
        }
    } catch {
        print("Error loading model: \(error)")
    }
}
