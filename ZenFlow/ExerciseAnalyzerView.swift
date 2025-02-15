//
//  ExerciseAnalyzerView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI
import AVFoundation
import Vision

struct ExerciseAnalyzerView: View {
    @State private var isAnalyzing = false
    @State private var feedbackSummary: String = ""
    @State private var selectedExercise = "Squat"
    @State private var showFeedback = false
    @Environment(\.presentationMode) var presentationMode

    let exercises = [
        "Squat", "Push-up", "Lunge", "Plank", "Glute Bridge", "Calf Raise",
        "Wall Sit", "Shoulder Press", "Tricep Dip", "Bicycle Crunch",
        "Superman", "Mountain Climber", "Jumping Jack", "Burpee",
        "High Knees", "Box Jump", "Kettlebell Swing", "Russian Twist", "Step-up"
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Exercise Analyzer")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding()
                
                if !isAnalyzing && !showFeedback {
                    Picker("Select Exercise", selection: $selectedExercise) {
                        ForEach(exercises, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(15)
                    
                    Button(action: {
                        isAnalyzing = true
                        feedbackSummary = ""
                    }) {
                        Text("Start Analysis")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                } else if isAnalyzing {
                    CameraView(feedbackSummary: $feedbackSummary, exercise: selectedExercise)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .padding()
                    
                    Button(action: {
                        isAnalyzing = false
                        showFeedback = true
                    }) {
                        Text("Stop Analysis")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                } else if showFeedback {
                    VStack(spacing: 20) {
                        Text("Exercise Feedback")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(feedbackSummary)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(15)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showFeedback = false
                        }) {
                            Text("Back")
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
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var feedbackSummary: String
    var exercise: String
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        cameraVC.exercise = exercise
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.exercise = exercise
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func cameraViewController(_ viewController: CameraViewController, didUpdateFeedbackSummary summary: String) {
            parent.feedbackSummary = summary
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewController(_ viewController: CameraViewController, didUpdateFeedbackSummary summary: String)
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraViewControllerDelegate?
    var exercise: String = "Squat"
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var poseRequest = VNDetectHumanBodyPoseRequest()
    private var lastAnalysisTime = Date()
    private var analysisInterval: TimeInterval = 1.0
    private var goodCount = 0
    private var improveCount = 0
    private var poorCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession?.addInput(input)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession?.addOutput(videoOutput)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.frame = view.bounds
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastAnalysisTime) >= analysisInterval else { return }
        lastAnalysisTime = currentTime
        
        let handler = VNImageRequestHandler(ciImage: CIImage(cvPixelBuffer: pixelBuffer), orientation: .up, options: [:])
        do {
            try handler.perform([poseRequest])
            guard let observations = poseRequest.results as? [VNHumanBodyPoseObservation] else { return }
            
            DispatchQueue.main.async {
                self.analyzePose(observations: observations)
            }
        } catch {
            print("Failed to perform pose detection: \(error)")
        }
    }
    
    private func analyzePose(observations: [VNHumanBodyPoseObservation]) {
        guard let observation = observations.first else {
            return
        }
        
        let feedback: String
        
        switch exercise {
        case "Squat":
            feedback = analyzeSquat(observation: observation)
        case "Push-up":
            feedback = analyzePushUp(observation: observation)
        case "Lunge":
            feedback = analyzeLunge(observation: observation)
        case "Plank":
            feedback = analyzePlank(observation: observation)
        case "Glute Bridge":
            feedback = analyzeGluteBridge(observation: observation)
        case "Calf Raise":
            feedback = analyzeCalfRaise(observation: observation)
        case "Wall Sit":
            feedback = analyzeWallSit(observation: observation)
        case "Shoulder Press":
            feedback = analyzeShoulderPress(observation: observation)
        case "Tricep Dip":
            feedback = analyzeTricepDip(observation: observation)
        case "Bicycle Crunch":
            feedback = analyzeBicycleCrunch(observation: observation)
        case "Superman":
            feedback = analyzeSuperman(observation: observation)
        case "Mountain Climber":
            feedback = analyzeMountainClimber(observation: observation)
        case "Jumping Jack":
            feedback = analyzeJumpingJack(observation: observation)
        case "Burpee":
            feedback = analyzeBurpee(observation: observation)
        case "High Knees":
            feedback = analyzeHighKnees(observation: observation)
        case "Box Jump":
            feedback = analyzeBoxJump(observation: observation)
        case "Kettlebell Swing":
            feedback = analyzeKettlebellSwing(observation: observation)
        case "Russian Twist":
            feedback = analyzeRussianTwist(observation: observation)
        case "Step-up":
            feedback = analyzeStepUp(observation: observation)
        default:
            feedback = "Exercise not recognized"
        }
        
        updateFeedbackCounts(feedback: feedback)
        generateFeedbackSummary()
    }
    
    private func updateFeedbackCounts(feedback: String) {
        if feedback.contains("Good") {
            goodCount += 1
        } else if feedback.contains("Improve") {
            improveCount += 1
        } else if feedback.contains("Poor") {
            poorCount += 1
        }
    }
    
    private func generateFeedbackSummary() {
        let total = Double(goodCount + improveCount + poorCount)
        let goodPercentage = Double(goodCount) / total
        let improvePercentage = Double(improveCount) / total
        let poorPercentage = Double(poorCount) / total
        
        var summary = ""
        
        if goodPercentage > 0.7 {
            summary = "Overall, your form is very good. "
        } else if goodPercentage > 0.5 {
            summary = "Your form is generally good, but there's room for improvement. "
        } else if improvePercentage > 0.5 {
            summary = "Your form needs some work. "
        } else {
            summary = "Your form needs significant improvement. "
        }
        
        if improvePercentage > 0.2 {
            summary += getImprovementSuggestion()
        }
        
        if poorPercentage > 0.2 {
            summary += "Focus on maintaining proper form throughout the exercise."
        }
        
        delegate?.cameraViewController(self, didUpdateFeedbackSummary: summary)
    }
    
    private func getImprovementSuggestion() -> String {
        switch exercise {
        case "Squat":
            return "Work on lowering your hips more and keeping your back straight. "
        case "Push-up":
            return "Try to lower your chest closer to the ground and keep your body straight. "
        case "Lunge":
            return "Focus on keeping your front knee at a 90-degree angle and your back straight. "
        case "Plank":
            return "Keep your body in a straight line from head to heels. "
        case "Glute Bridge":
            return "Lift your hips higher and squeeze your glutes at the top. "
        case "Calf Raise":
            return "Rise up onto your toes as high as possible. "
        case "Wall Sit":
            return "Keep your thighs parallel to the ground and back against the wall. "
        case "Shoulder Press":
            return "Fully extend your arms overhead and keep your core engaged. "
        case "Tricep Dip":
            return "Lower your body until your upper arms are parallel to the ground. "
        case "Bicycle Crunch":
            return "Rotate your torso more and bring your elbow closer to the opposite knee. "
        case "Superman":
            return "Lift your arms and legs higher off the ground. "
        case "Mountain Climber":
            return "Bring your knees closer to your chest and increase your speed. "
        case "Jumping Jack":
            return "Fully extend your arms and legs with each jump. "
        case "Burpee":
            return "Lower your chest to the ground in the push-up and jump higher at the end. "
        case "High Knees":
            return "Lift your knees higher and increase your pace. "
        case "Box Jump":
            return "Land softly on the box with your knees slightly bent. "
        case "Kettlebell Swing":
            return "Drive the movement from your hips and keep your arms straight. "
        case "Russian Twist":
            return "Rotate your torso further and lift your feet off the ground if possible. "
        case "Step-up":
            return "Step fully onto the platform and straighten your leg at the top. "
        default:
            return "Pay attention to the proper form for this exercise. "
        }
    }
    
    private func analyzeSquat(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect squat pose"
        }
        
        if hipAngle < 90 {
            return "Good squat form: Knees bent sufficiently"
        } else if hipAngle < 120 {
            return "Improve squat form: Lower your hips more"
        } else {
            return "Poor squat form: Bend your knees more"
        }
    }
    
    private func analyzePushUp(observation: VNHumanBodyPoseObservation) -> String {
        guard let elbowAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightElbow, joint3: .rightWrist) else {
            return "Cannot detect push-up pose"
        }
        
        if elbowAngle < 90 {
            return "Good push-up form: Arms bent sufficiently"
        } else if elbowAngle < 120 {
            return "Improve push-up form: Lower your chest more"
        } else {
            return "Poor push-up form: Bend your elbows more"
        }
    }
    
    private func analyzeLunge(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect lunge pose"
        }
        
        if 80 < kneeAngle && kneeAngle < 100 {
            return "Good lunge form: Front knee bent properly"
        } else if 100 <= kneeAngle && kneeAngle < 120 {
            return "Improve lunge form: Bend your front knee more"
        } else {
            return "Poor lunge form: Adjust your stance and knee bend"
        }
    }
    
    private func analyzePlank(observation: VNHumanBodyPoseObservation) -> String {
        guard let bodyAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightAnkle) else {
            return "Cannot detect plank pose"
        }
        
        if 160 < bodyAngle && bodyAngle < 180 {
            return "Good plank form: Body well-aligned"
        } else if 150 < bodyAngle && bodyAngle <= 160 {
            return "Improve plank form: Straighten your body more"
        } else {
            return "Poor plank form: Align your body, keep it straight"
        }
    }
    
    private func analyzeGluteBridge(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightKnee) else {
            return "Cannot detect glute bridge pose"
        }
        
        if hipAngle > 160 {
            return "Good glute bridge form: Hips raised high"
        } else if hipAngle > 140 {
            return "Improve glute bridge form: Raise your hips higher"
        } else {
            return "Poor glute bridge form: Lift your hips much higher"
        }
    }
    
    private func analyzeCalfRaise(observation: VNHumanBodyPoseObservation) -> String {
        guard let anklePoint = try? observation.recognizedPoint(.rightAnkle),
              let kneePoint = try? observation.recognizedPoint(.rightKnee),
              anklePoint.confidence > 0.1 && kneePoint.confidence > 0.1 else {
            return "Cannot detect calf raise pose"
        }
        
        let verticalDistance = kneePoint.location.y - anklePoint.location.y
        let normalizedDistance = verticalDistance / (kneePoint.location.y - 0.5)
        
        if normalizedDistance < 0.1 {
            return "Good calf raise form: Heels raised high"
        } else if normalizedDistance < 0.15 {
            return "Improve calf raise form: Raise your heels higher"
        } else {
            return "Poor calf raise form: Lift your heels much higher"
        }
    }
    
    private func analyzeWallSit(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect wall sit pose"
        }
        
        if 85 < kneeAngle && kneeAngle < 95 {
            return "Good wall sit form: Knees at 90 degrees"
        } else if 80 < kneeAngle && kneeAngle <= 85 || 95 <= kneeAngle && kneeAngle < 100 {
            return "Improve wall sit form: Adjust to 90 degree knee bend"
        } else {
            return "Poor wall sit form: Significantly off from 90 degree knee bend"
        }
    }
    
    private func analyzeShoulderPress(observation: VNHumanBodyPoseObservation) -> String {
        guard let shoulderAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightElbow, joint3: .rightWrist) else {
            return "Cannot detect shoulder press pose"
        }
        
        if shoulderAngle > 160 {
            return "Good shoulder press form: Arms extended"
        } else if shoulderAngle > 140 {
            return "Improve shoulder press form: Extend arms more"
        } else {
            return "Poor shoulder press form: Push the weights higher"
        }
    }
    
    private func analyzeTricepDip(observation: VNHumanBodyPoseObservation) -> String {
        guard let elbowAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightElbow, joint3: .rightWrist) else {
            return "Cannot detect tricep dip pose"
        }
        
        if elbowAngle < 90 {
            return "Good tricep dip form: Arms bent sufficiently"
        } else if elbowAngle < 120 {
            return "Improve tricep dip form: Lower your body more"
        } else {
            return "Poor tricep dip form: Bend your elbows more"
        }
    }
    
    private func analyzeBicycleCrunch(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle),
              let elbowAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightElbow, joint3: .rightWrist) else {
            return "Cannot detect bicycle crunch pose"
        }
        
        if kneeAngle < 45 && elbowAngle < 90 {
            return "Good bicycle crunch form: Knee close to chest and elbow twisted"
        } else if kneeAngle < 60 && elbowAngle < 110 {
            return "Improve bicycle crunch form: Bring knee closer to chest and twist more"
        } else {
            return "Poor bicycle crunch form: Bring your knee much closer and twist further"
        }
    }
    
    private func analyzeSuperman(observation: VNHumanBodyPoseObservation) -> String {
        guard let bodyAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightAnkle) else {
            return "Cannot detect superman pose"
        }
        
        if bodyAngle > 160 {
            return "Good superman form: Body well-extended"
        } else if bodyAngle > 140 {
            return "Improve superman form: Lift limbs higher"
        } else {
            return "Poor superman form: Lift your arms and legs much higher"
        }
    }
    
    private func analyzeMountainClimber(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect mountain climber pose"
        }
        
        if kneeAngle < 90 {
            return "Good mountain climber form: Knee close to chest"
        } else if kneeAngle < 120 {
            return "Improve mountain climber form: Bring knee closer to chest"
        } else {
            return "Poor mountain climber form: Bring your knee much closer to your chest"
        }
    }
    
    private func analyzeJumpingJack(observation: VNHumanBodyPoseObservation) -> String {
        guard let armAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightElbow, joint3: .rightWrist),
              let legAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect jumping jack pose"
        }
        
        if armAngle > 150 && legAngle > 30 {
            return "Good jumping jack form: Arms and legs extended"
        } else if armAngle > 120 && legAngle > 20 {
            return "Improve jumping jack form: Extend arms and legs more"
        } else {
            return "Poor jumping jack form: Jump higher and extend arms fully"
        }
    }
    
    private func analyzeBurpee(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightKnee) else {
            return "Cannot detect burpee pose"
        }
        
        if hipAngle < 60 {
            return "Good burpee form: Low squat position"
        } else if hipAngle < 90 {
            return "Improve burpee form: Lower your squat"
        } else {
            return "Poor burpee form: Squat lower and jump higher"
        }
    }
    
    private func analyzeHighKnees(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect high knees pose"
        }
        
        if kneeAngle < 90 {
            return "Good high knees form: Knee raised high"
        } else if kneeAngle < 120 {
            return "Improve high knees form: Raise your knee higher"
        } else {
            return "Poor high knees form: Lift your knee much higher"
        }
    }
    
    private func analyzeBoxJump(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect box jump pose"
        }
        
        if kneeAngle < 90 {
            return "Good box jump form: Deep squat before jump"
        } else if kneeAngle < 120 {
            return "Improve box jump form: Lower your squat before jumping"
        } else {
            return "Poor box jump form: Squat lower for more explosive jump"
        }
    }
    
    private func analyzeKettlebellSwing(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightKnee) else {
            return "Cannot detect kettlebell swing pose"
        }
        
        if 160 < hipAngle && hipAngle < 180 {
            return "Good kettlebell swing form: Hips fully extended at the top"
        } else if 140 < hipAngle && hipAngle <= 160 {
            return "Improve kettlebell swing form: Extend your hips more at the top"
        } else {
            return "Poor kettlebell swing form: Focus on hip hinge and full extension"
        }
    }
    
    private func analyzeRussianTwist(observation: VNHumanBodyPoseObservation) -> String {
        guard let spineAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .root, joint3: .rightHip) else {
            return "Cannot detect Russian twist pose"
        }
        
        if spineAngle < 60 {
            return "Good Russian twist form: Torso rotated sufficiently"
        } else if spineAngle < 90 {
            return "Improve Russian twist form: Rotate your torso more"
        } else {
            return "Poor Russian twist form: Increase your range of motion"
        }
    }
    
    private func analyzeStepUp(observation: VNHumanBodyPoseObservation) -> String {
        guard let kneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect step-up pose"
        }
        
        if kneeAngle < 90 {
            return "Good step-up form: Leg lifted high enough"
        } else if kneeAngle < 120 {
            return "Improve step-up form: Lift your leg higher"
        } else {
            return "Poor step-up form: Step onto a higher platform or lift your leg higher"
        }
    }
    
    private func getAngle(observation: VNHumanBodyPoseObservation, joint1: VNHumanBodyPoseObservation.JointName, joint2: VNHumanBodyPoseObservation.JointName, joint3: VNHumanBodyPoseObservation.JointName) -> CGFloat? {
        guard let joint1Point = try? observation.recognizedPoint(joint1),
              let joint2Point = try? observation.recognizedPoint(joint2),
              let joint3Point = try? observation.recognizedPoint(joint3),
              joint1Point.confidence > 0.1 && joint2Point.confidence > 0.1 && joint3Point.confidence > 0.1 else {
            return nil
        }
        
        let vector1 = CGPoint(x: joint1Point.location.x - joint2Point.location.x,
                              y: joint1Point.location.y - joint2Point.location.y)
        let vector2 = CGPoint(x: joint3Point.location.x - joint2Point.location.x,
                              y: joint3Point.location.y - joint2Point.location.y)
        
        let angle = atan2(vector2.y, vector2.x) - atan2(vector1.y, vector1.x)
        return abs(angle * 180 / .pi)
    }
}

struct ExerciseAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseAnalyzerView()
    }
}
