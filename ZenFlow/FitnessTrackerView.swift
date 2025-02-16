import SwiftUI

struct FitnessTrackerView: View {
    @State private var showExerciseAnalyzer = false
    let yogaGoals: Set<String>
    let name: String
    let mentalHealthMeds: String
    let mentalDisorders: String
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("ZenFlow")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("4-Week Personalized Yoga Plan for \(name)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ForEach(1...4, id: \.self) { week in
                        WeeklyPlanView(week: week, workoutForDay: workoutForDay)
                    }
                    
                    Button(action: { showExerciseAnalyzer = true }) {
                        Text("Yoga Pose Analyzer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showExerciseAnalyzer) {
            ExerciseAnalyzerView()
        }
    }

    func workoutForDay(week: Int, day: String) -> String {
        switch week {
        case 1:
            return foundationalYoga(day: day)
        case 2:
            return strengthAndFlexibilityYoga(day: day)
        case 3:
            return mindBodyConnectionYoga(day: day)
        case 4:
            return advancedPracticeYoga(day: day)
        default:
            return "Rest Day"
        }
    }
    
    func foundationalYoga(day: String) -> String {
        switch day {
        case "Monday":
            return "Sun Salutations (15 minutes)"
        case "Tuesday":
            return "Standing Poses (20 minutes)"
        case "Wednesday":
            return "Seated Poses (15 minutes)"
        case "Thursday":
            return "Gentle Flow (20 minutes)"
        case "Friday":
            return "Core Focus (15 minutes)"
        case "Saturday":
            return "Balance Poses (20 minutes)"
        case "Sunday":
            return "Relaxation and Meditation (15 minutes)"
        default:
            return "Rest Day"
        }
    }
    
    func strengthAndFlexibilityYoga(day: String) -> String {
        switch day {
        case "Monday":
            return "Power Yoga (20 minutes)"
        case "Tuesday":
            return "Yin Yoga (25 minutes)"
        case "Wednesday":
            return "Vinyasa Flow (20 minutes)"
        case "Thursday":
            return "Hip Openers (15 minutes)"
        case "Friday":
            return "Arm Balances (20 minutes)"
        case "Saturday":
            return "Backbends (15 minutes)"
        case "Sunday":
            return "Restorative Yoga (25 minutes)"
        default:
            return "Rest Day"
        }
    }
    
    func mindBodyConnectionYoga(day: String) -> String {
        switch day {
        case "Monday":
            return "Breath-Focused Practice (20 minutes)"
        case "Tuesday":
            return "Mindful Movement (25 minutes)"
        case "Wednesday":
            return "Yoga Nidra (30 minutes)"
        case "Thursday":
            return "Chakra Balancing (20 minutes)"
        case "Friday":
            return "Kundalini Yoga (25 minutes)"
        case "Saturday":
            return "Walking Meditation (20 minutes)"
        case "Sunday":
            return "Gentle Stretching (15 minutes)"
        default:
            return "Rest Day"
        }
    }
    
    func advancedPracticeYoga(day: String) -> String {
        switch day {
        case "Monday":
            return "Ashtanga-Inspired Flow (30 minutes)"
        case "Tuesday":
            return "Inversions (20 minutes)"
        case "Wednesday":
            return "Advanced Sun Salutations (25 minutes)"
        case "Thursday":
            return "Arm Balance Workshop (20 minutes)"
        case "Friday":
            return "Power Vinyasa (30 minutes)"
        case "Saturday":
            return "Yoga for Flexibility (25 minutes)"
        case "Sunday":
            return "Restorative and Meditation (30 minutes)"
        default:
            return "Rest Day"
        }
    }
}

struct WeeklyPlanView: View {
    let week: Int
    let workoutForDay: (Int, String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Week \(week)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                HStack(alignment: .top) {
                    Text(day)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 100, alignment: .leading)
                    
                    Text(workoutForDay(week, day))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
