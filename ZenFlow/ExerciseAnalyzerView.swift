import SwiftUI
import AVFoundation
import Vision

struct ExerciseAnalyzerView: View {
    @State private var isAnalyzing = false
    @State private var feedbackSummary: String = ""
    @State private var selectedPose = "Mountain Pose"
    @State private var showFeedback = false
    @Environment(\.presentationMode) var presentationMode

    let yogaPoses = [
        "Mountain Pose", "Tree Pose", "Warrior I", "Warrior II", "Downward-Facing Dog",
        "Child's Pose", "Cobra Pose", "Triangle Pose", "Plank Pose", "Bridge Pose"
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Yoga Pose Analyzer")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding()
                
                if !isAnalyzing && !showFeedback {
                    Picker("Select Yoga Pose", selection: $selectedPose) {
                        ForEach(yogaPoses, id: \.self) {
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
                    CameraView(feedbackSummary: $feedbackSummary, pose: selectedPose)
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
                        Text("Yoga Pose Feedback")
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
    var pose: String
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        cameraVC.pose = pose
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.pose = pose
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
    var pose: String = "Mountain Pose"
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var poseRequest = VNDetectHumanBodyPoseRequest()
    private var lastAnalysisTime = Date()
    private var analysisInterval: TimeInterval = 1.0
    
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
            guard let observations = poseRequest.results else { return }
            
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
        
        switch pose {
        case "Mountain Pose":
            feedback = analyzeMountainPose(observation: observation)
        case "Tree Pose":
            feedback = analyzeTreePose(observation: observation)
        case "Warrior I":
            feedback = analyzeWarriorI(observation: observation)
        case "Warrior II":
            feedback = analyzeWarriorII(observation: observation)
        case "Downward-Facing Dog":
            feedback = analyzeDownwardFacingDog(observation: observation)
        case "Child's Pose":
            feedback = analyzeChildsPose(observation: observation)
        case "Cobra Pose":
            feedback = analyzeCobraPose(observation: observation)
        case "Triangle Pose":
            feedback = analyzeTrianglePose(observation: observation)
        case "Plank Pose":
            feedback = analyzePlankPose(observation: observation)
        case "Bridge Pose":
            feedback = analyzeBridgePose(observation: observation)
        default:
            feedback = "Pose not recognized"
        }
        
        delegate?.cameraViewController(self, didUpdateFeedbackSummary: feedback)
    }
    
    private func analyzeMountainPose(observation: VNHumanBodyPoseObservation) -> String {
        guard let spineAngle = getAngle(observation: observation, joint1: .root, joint2: .neck, joint3: .rightShoulder) else {
            return "Cannot detect Mountain Pose"
        }
        
        if 170 < spineAngle && spineAngle < 190 {
            return "Good Mountain Pose: Spine is straight and aligned"
        } else if 160 < spineAngle && spineAngle <= 170 || 190 <= spineAngle && spineAngle < 200 {
            return "Improve Mountain Pose: Straighten your spine more"
        } else {
            return "Poor Mountain Pose: Focus on aligning your spine vertically"
        }
    }
    
    private func analyzeTreePose(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect Tree Pose"
        }
        
        if 80 < hipAngle && hipAngle < 100 {
            return "Good Tree Pose: Foot is well-placed on inner thigh"
        } else if 60 < hipAngle && hipAngle <= 80 || 100 <= hipAngle && hipAngle < 120 {
            return "Improve Tree Pose: Adjust your foot placement on your inner thigh"
        } else {
            return "Poor Tree Pose: Place your foot higher on your inner thigh"
        }
    }
    
    private func analyzeWarriorI(observation: VNHumanBodyPoseObservation) -> String {
        guard let frontKneeAngle = getAngle(observation: observation, joint1: .rightHip, joint2: .rightKnee, joint3: .rightAnkle) else {
            return "Cannot detect Warrior I Pose"
        }
        
        if 85 < frontKneeAngle && frontKneeAngle < 95 {
            return "Good Warrior I Pose: Front knee is at 90 degrees"
        } else if 75 < frontKneeAngle && frontKneeAngle <= 85 || 95 <= frontKneeAngle && frontKneeAngle < 105 {
            return "Improve Warrior I Pose: Adjust your front knee to 90 degrees"
        } else {
            return "Poor Warrior I Pose: Bend your front knee more to reach 90 degrees"
        }
    }
    
    private func analyzeWarriorII(observation: VNHumanBodyPoseObservation) -> String {
        guard let armAngle = getAngle(observation: observation, joint1: .leftWrist, joint2: .leftShoulder, joint3: .rightWrist) else {
            return "Cannot detect Warrior II Pose"
        }
        
        if 170 < armAngle && armAngle < 190 {
            return "Good Warrior II Pose: Arms are aligned and extended"
        } else if 160 < armAngle && armAngle <= 170 || 190 <= armAngle && armAngle < 200 {
            return "Improve Warrior II Pose: Extend your arms more"
        } else {
            return "Poor Warrior II Pose: Focus on aligning and extending your arms"
        }
    }
    
    private func analyzeDownwardFacingDog(observation: VNHumanBodyPoseObservation) -> String {
        guard let spineAngle = getAngle(observation: observation, joint1: .root, joint2: .neck, joint3: .rightAnkle) else {
            return "Cannot detect Downward-Facing Dog Pose"
        }
        
        if 30 < spineAngle && spineAngle < 50 {
            return "Good Downward-Facing Dog Pose: Spine and legs form an inverted V"
        } else if 20 < spineAngle && spineAngle <= 30 || 50 <= spineAngle && spineAngle < 60 {
            return "Improve Downward-Facing Dog Pose: Adjust your hips to form a better inverted V"
        } else {
            return "Poor Downward-Facing Dog Pose: Lift your hips higher to form an inverted V"
        }
    }
    
    private func analyzeChildsPose(observation: VNHumanBodyPoseObservation) -> String {
        guard let spineAngle = getAngle(observation: observation, joint1: .root, joint2: .neck, joint3: .rightShoulder) else {
            return "Cannot detect Child's Pose"
        }
        
        if 150 < spineAngle && spineAngle < 180 {
            return "Good Child's Pose: Body is well-folded and relaxed"
        } else if 130 < spineAngle && spineAngle <= 150 {
            return "Improve Child's Pose: Try to relax and fold your body more"
        } else {
            return "Poor Child's Pose: Focus on folding your body and relaxing into the pose"
        }
    }
    
    private func analyzeCobraPose(observation: VNHumanBodyPoseObservation) -> String {
        guard let spineAngle = getAngle(observation: observation, joint1: .root, joint2: .neck, joint3: .rightShoulder) else {
            return "Cannot detect Cobra Pose"
        }
        
        if 30 < spineAngle && spineAngle < 60 {
            return "Good Cobra Pose: Upper body is lifted with a good arch"
        } else if 15 < spineAngle && spineAngle <= 30 || 60 <= spineAngle && spineAngle < 75 {
            return "Improve Cobra Pose: Adjust your upper body lift"
        } else {
            return "Poor Cobra Pose: Focus on lifting your upper body while keeping your hips down"
        }
    }
    
    private func analyzeTrianglePose(observation: VNHumanBodyPoseObservation) -> String {
        guard let trunkAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .root, joint3: .rightAnkle) else {
            return "Cannot detect Triangle Pose"
        }
        
        if 30 < trunkAngle && trunkAngle < 60 {
            return "Good Triangle Pose: Trunk is well-extended to the side"
        } else if 15 < trunkAngle && trunkAngle <= 30 || 60 <= trunkAngle && trunkAngle < 75 {
            return "Improve Triangle Pose: Extend your trunk more to the side"
        } else {
            return "Poor Triangle Pose: Focus on extending your trunk to the side while keeping your legs straight"
        }
    }
    
    private func analyzePlankPose(observation: VNHumanBodyPoseObservation) -> String {
        guard let bodyAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .root, joint3: .rightAnkle) else {
            return "Cannot detect Plank Pose"
        }
        
        if 170 < bodyAngle && bodyAngle < 190 {
            return "Good Plank Pose: Body is well-aligned and straight"
        } else if 160 < bodyAngle && bodyAngle <= 170 || 190 <= bodyAngle && bodyAngle < 200 {
            return "Improve Plank Pose: Straighten your body more"
        } else {
            return "Poor Plank Pose: Focus on aligning your body from head to heels"
        }
    }
    
    private func analyzeBridgePose(observation: VNHumanBodyPoseObservation) -> String {
        guard let hipAngle = getAngle(observation: observation, joint1: .rightShoulder, joint2: .rightHip, joint3: .rightKnee) else {
            return "Cannot detect Bridge Pose"
        }
        
        if 170 < hipAngle && hipAngle < 190 {
            return "Good Bridge Pose: Hips are well-lifted and aligned"
        } else if 150 < hipAngle && hipAngle <= 170 {
            return "Improve Bridge Pose: Lift your hips higher"
        } else {
            return "Poor Bridge Pose: Focus on lifting your hips while keeping your shoulders on the ground"
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
