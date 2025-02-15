//
//  FitnessTrackerView.swift
//  HealthTracker
//
//  Created by Swarasai Mulagari on 1/05/25.
//

import SwiftUI

struct FitnessTrackerView: View {
    @State private var showExerciseAnalyzer = false
    let fitnessGoals: Set<String>
    let name: String
    let currentWeight: String
    let goalWeight: String
    let activityLevel: Double
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Fitness Tracker")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("4-Week Personalized Workout Plan for \(name)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ForEach(1...4, id: \.self) { week in
                        WeeklyPlanView(week: week, workoutForDay: workoutForDay)
                    }
                    
                    Button(action: { showExerciseAnalyzer = true }) {
                        Text("Exercise Analyzer")
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
        let loseWeight = fitnessGoals.contains("Weight Loss")
        let gainMuscle = fitnessGoals.contains("Muscle Gain")
        let improveEndurance = fitnessGoals.contains("Improve Endurance")
        let increaseFlexibility = fitnessGoals.contains("Increase Flexibility")
        let maintainFitness = fitnessGoals.contains("Maintain Current Fitness")
        
        switch (loseWeight, gainMuscle, improveEndurance, increaseFlexibility, maintainFitness) {
        case (true, _, _, _, _):
            return weightLossWorkout(week: week, day: day)
        case (_, true, _, _, _):
            return muscleGainWorkout(week: week, day: day)
        case (_, _, true, _, _):
            return enduranceWorkout(week: week, day: day)
        case (_, _, _, true, _):
            return flexibilityWorkout(week: week, day: day)
        case (_, _, _, _, true):
            return maintenanceWorkout(week: week, day: day)
        default:
            return combinedWorkout(week: week, day: day)
        }
    }
    
    func weightLossWorkout(week: Int, day: String) -> String {
        let intensity = getIntensity(week: week)
        switch (week, day) {
        case (_, "Monday"):
            return "HIIT Cardio (\(intensity) min): Alternate 30 sec high-intensity with 30 sec rest"
        case (_, "Tuesday"):
            return "Full Body Strength: Squats, Push-ups, Rows, Lunges (\(3 + week) sets each)"
        case (_, "Wednesday"):
            return "Low-Intensity Cardio: \(intensity) min brisk walking or cycling"
        case (_, "Thursday"):
            return "Core and Upper Body: Planks, Dips, Shoulder Press, Russian Twists (\(3 + week) sets each)"
        case (_, "Friday"):
            return "Lower Body Focus: Deadlifts, Glute Bridges, Calf Raises (\(3 + week) sets each)"
        case (_, "Saturday"):
            return "Cardio of Choice: \(intensity + 5) min running, swimming, or cycling"
        case (_, "Sunday"):
            return "Active Recovery: 20 min light yoga or stretching"
        default:
            return "Rest Day"
        }
    }
    
    func muscleGainWorkout(week: Int, day: String) -> String {
        let sets = 3 + (week / 2)
        switch (week, day) {
        case (_, "Monday"):
            return "Chest and Triceps: Bench Press, Incline Dumbbell Press, Dips (\(sets) sets each)"
        case (_, "Tuesday"):
            return "Back and Biceps: Deadlifts, Pull-ups, Barbell Rows, Curls (\(sets) sets each)"
        case (_, "Wednesday"):
            return "Active Recovery: 20 min light cardio and stretching"
        case (_, "Thursday"):
            return "Legs and Shoulders: Squats, Leg Press, Shoulder Press (\(sets) sets each)"
        case (_, "Friday"):
            return "Arms and Core: Tricep Extensions, Hammer Curls, Planks (\(sets) sets each)"
        case (_, "Saturday"):
            return "Full Body: Compound exercises like Clean and Press (\(sets) sets)"
        case (_, "Sunday"):
            return "Rest Day"
        default:
            return "Rest Day"
        }
    }
    
    func enduranceWorkout(week: Int, day: String) -> String {
        let duration = 30 + (week * 5)
        switch (week, day) {
        case (_, "Monday"):
            return "Long Distance Run: \(duration) min at steady pace"
        case (_, "Tuesday"):
            return "Swimming: \(duration - 10) min continuous laps"
        case (_, "Wednesday"):
            return "Cycling: \(duration + 10) min ride"
        case (_, "Thursday"):
            return "Interval Training: \(duration - 5) min alternating 1 min high intensity, 1 min low"
        case (_, "Friday"):
            return "Rowing or Elliptical: \(duration) min"
        case (_, "Saturday"):
            return "Trail Run or Hike: \(duration + 15) min"
        case (_, "Sunday"):
            return "Active Recovery: 20 min light cardio and stretching"
        default:
            return "Rest Day"
        }
    }
    
    func flexibilityWorkout(week: Int, day: String) -> String {
        let duration = 30 + (week * 5)
        switch (week, day) {
        case (_, "Monday"):
            return "Yoga Flow: \(duration) min focusing on full body flexibility"
        case (_, "Tuesday"):
            return "Dynamic Stretching: \(duration - 10) min, include leg swings, arm circles"
        case (_, "Wednesday"):
            return "Pilates: \(duration) min mat workout"
        case (_, "Thursday"):
            return "Foam Rolling: \(duration - 15) min, focus on tight areas"
        case (_, "Friday"):
            return "Static Stretching: \(duration) min, hold each stretch for 30 seconds"
        case (_, "Saturday"):
            return "Mobility Workout: \(duration) min, include hip openers, shoulder mobility"
        case (_, "Sunday"):
            return "Gentle Yoga: \(duration - 5) min, focus on relaxation and stretching"
        default:
            return "Rest Day"
        }
    }
    
    func maintenanceWorkout(week: Int, day: String) -> String {
        switch (week, day) {
        case (_, "Monday"):
            return "Cardio: 30 min run or cycling"
        case (_, "Tuesday"):
            return "Strength Training: Full body workout, 3 sets of 10 reps each exercise"
        case (_, "Wednesday"):
            return "Flexibility: 30 min yoga or stretching"
        case (_, "Thursday"):
            return "High-Intensity Interval Training: 20 min"
        case (_, "Friday"):
            return "Strength Training: Focus on weaker areas, 3 sets of 12 reps each"
        case (_, "Saturday"):
            return "Recreational Activity: 45 min of sport or outdoor activity"
        case (_, "Sunday"):
            return "Active Recovery: 20 min light cardio and stretching"
        default:
            return "Rest Day"
        }
    }
    
    func combinedWorkout(week: Int, day: String) -> String {
        let intensity = getIntensity(week: week)
        switch (week, day) {
        case (_, "Monday"):
            return "Cardio and Strength: \(intensity) min HIIT followed by full body strength (\(3 + week) sets)"
        case (_, "Tuesday"):
            return "Endurance and Flexibility: \(intensity + 10) min run followed by 20 min yoga"
        case (_, "Wednesday"):
            return "Active Recovery: 30 min light cardio and foam rolling"
        case (_, "Thursday"):
            return "Strength and Core: Upper body and core exercises (\(3 + week) sets each)"
        case (_, "Friday"):
            return "Lower Body and Cardio: Leg workout (\(3 + week) sets) followed by 20 min cycling"
        case (_, "Saturday"):
            return "Outdoor Activity: \(intensity + 20) min hiking, swimming, or sport of choice"
        case (_, "Sunday"):
            return "Flexibility and Mobility: 40 min yoga or stretching routine"
        default:
            return "Rest Day"
        }
    }
    
    func getIntensity(week: Int) -> Int {
        let baseIntensity = activityLevel < 3 ? 20 : 30
        return baseIntensity + (week * 5)
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
