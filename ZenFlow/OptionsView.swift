//
//  OptionsView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

func getRandomAffirmation() -> String {
    let affirmations = [
        "You are capable of amazing things!",
        "Every day is a new opportunity.",
        "You have the power to create change.",
        "You are strong and resilient.",
        "Your potential is limitless."
    ]
    return affirmations.randomElement() ?? affirmations[0]
}

struct OptionsView: View {
    let name: String
    let currentWeight: String
    let goalWeight: String
    let height: String
    let age: String
    let gender: Int
    let activityLevel: Double
    let dailyWaterIntake: Double
    let exerciseHours: Double
    let sleepHours: Double
    let stressLevel: Int
    let energyLevel: Int
    let moodRating: Int
    let sittingHours: Double
    let motivationLevel: Int
    let fitnessGoals: Set<String>
    let exercisePreferences: Set<String>
    let supplements: Set<String>
    let medicalConditions: Set<String>
    let isVegan: Bool
    let isVegetarian: Bool
    let isLactoseIntolerant: Bool
    let wantsClearSkin: Bool
    let participatesInSports: Bool
    let hasRegularMealSchedule: Bool
    let studiesLate: Bool
    let usesScreenBeforeBed: Bool
    let hasExtracurricularActivities: Bool
    let experiencesTestAnxiety: Bool
    let hasDifficultiesConcentrating: Bool
    let onNutritionAnalyzer: () -> Void
    let onDietWaterPlan: () -> Void
    @State private var showFitnessTracker = false
    @State private var showMealScan = false
    @State private var showNutritionAnalyzer = false
    @State private var showExerciseAnalyzer = false
    @State private var dailyAffirmation = "You are capable of amazing things!"

    init(name: String, currentWeight: String, goalWeight: String, height: String, age: String, gender: Int, activityLevel: Double, dailyWaterIntake: Double, exerciseHours: Double, sleepHours: Double, stressLevel: Int, energyLevel: Int, moodRating: Int, sittingHours: Double, motivationLevel: Int, fitnessGoals: Set<String>, exercisePreferences: Set<String>, supplements: Set<String>, medicalConditions: Set<String>, isVegan: Bool, isVegetarian: Bool, isLactoseIntolerant: Bool, wantsClearSkin: Bool, participatesInSports: Bool, hasRegularMealSchedule: Bool, studiesLate: Bool, usesScreenBeforeBed: Bool, hasExtracurricularActivities: Bool, experiencesTestAnxiety: Bool, hasDifficultiesConcentrating: Bool, onNutritionAnalyzer: @escaping () -> Void, onDietWaterPlan: @escaping () -> Void) {
        self.name = name
        self.currentWeight = currentWeight
        self.goalWeight = goalWeight
        self.height = height
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
        self.dailyWaterIntake = dailyWaterIntake
        self.exerciseHours = exerciseHours
        self.sleepHours = sleepHours
        self.stressLevel = stressLevel
        self.energyLevel = energyLevel
        self.moodRating = moodRating
        self.sittingHours = sittingHours
        self.motivationLevel = motivationLevel
        self.fitnessGoals = fitnessGoals
        self.exercisePreferences = exercisePreferences
        self.supplements = supplements
        self.medicalConditions = medicalConditions
        self.isVegan = isVegan
        self.isVegetarian = isVegetarian
        self.isLactoseIntolerant = isLactoseIntolerant
        self.wantsClearSkin = wantsClearSkin
        self.participatesInSports = participatesInSports
        self.hasRegularMealSchedule = hasRegularMealSchedule
        self.studiesLate = studiesLate
        self.usesScreenBeforeBed = usesScreenBeforeBed
        self.hasExtracurricularActivities = hasExtracurricularActivities
        self.experiencesTestAnxiety = experiencesTestAnxiety
        self.hasDifficultiesConcentrating = hasDifficultiesConcentrating
        self.onNutritionAnalyzer = onNutritionAnalyzer
        self.onDietWaterPlan = onDietWaterPlan
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome \(name)!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .padding(.top, 40)

                        AffirmationView(affirmation: $dailyAffirmation)

                        ResourceSection(title: "Mental Health Resources", items: mentalHealthResources)
                        ResourceSection(title: "Emergency Contacts", items: emergencyWebsites)
                        ResourceSection(title: "Wellness Articles", items: articles)
                    }
                    .padding()
                }

                Spacer()

                HStack {
                   
                    TabButton(title: "Exercise", imageName: "figure.walk", action: {
                        showFitnessTracker = true  // Change this line
                    })
                  
                }
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.9))}
        }
        .edgesIgnoringSafeArea(.bottom)

        .sheet(isPresented: $showExerciseAnalyzer) {
            ExerciseAnalyzerView()
        }
        .sheet(isPresented: $showFitnessTracker) {
            FitnessTrackerView(
                fitnessGoals: fitnessGoals,
                name: name,
                currentWeight: currentWeight,
                goalWeight: goalWeight,
                activityLevel: activityLevel
            )
        }
    }
}

struct AffirmationView: View {
    @Binding var affirmation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Affirmation")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text(affirmation)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring()) {
                affirmation = getRandomAffirmation()
            }
        }
    }
}

struct ResourceSection: View {
    let title: String
    let items: [ResourceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(items) { item in
                Link(destination: URL(string: item.url)!) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(10)
                        
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResourceItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let imageName: String
    let description: String
}

let mentalHealthResources = [
    ResourceItem(title: "National Alliance on Mental Illness",
                 url: "https://www.nami.org",
                 imageName: "nami",
                 description: "NAMI provides advocacy, education, support and public awareness so that all individuals and families affected by mental illness can build better lives."),
    ResourceItem(title: "Mental Health America",
                 url: "https://www.mhanational.org",
                 imageName: "mha",
                 description: "MHA's work is driven by its commitment to promote mental health as a critical part of overall wellness."),
    ResourceItem(title: "Anxiety and Depression Association of America",
                 url: "https://adaa.org",
                 imageName: "adaa",
                 description: "ADAA is an international nonprofit organization dedicated to the prevention, treatment, and cure of anxiety, depression, OCD, PTSD, and co-occurring disorders.")
]

let emergencyWebsites = [
    ResourceItem(title: "National Suicide Prevention Lifeline",
                 url: "https://suicidepreventionlifeline.org",
                 imageName: "suicide_prevention",
                 description: "The Lifeline provides 24/7, free and confidential support for people in distress, prevention and crisis resources for you or your loved ones."),
    ResourceItem(title: "Crisis Text Line",
                 url: "https://www.crisistextline.org",
                 imageName: "crisis_text",
                 description: "Crisis Text Line serves anyone, in any type of crisis, providing access to free, 24/7 support via text message."),
    ResourceItem(title: "Emergency Services",
                 url: "tel:911",
                 imageName: "emergency_services",
                 description: "For immediate emergency assistance, always call your local emergency number.")
]

let articles = [
    ResourceItem(title: "10 Tips for Better Mental Health",
                 url: "https://www.easterseals.com",
                 imageName: "mental_health_tips",
                 description: "Discover practical strategies to improve your mental well-being and lead a happier life."),
    ResourceItem(title: "Understanding Stress and How to Manage It",
                 url: "https://odphp.health.gov/myhealthfinder/health-conditions/heart-health/manage-stress",
                 imageName: "stress_management",
                 description: "Learn about the effects of stress on your body and mind, and explore effective techniques to manage it."),
    ResourceItem(title: "The Importance of Self-Care",
                 url: "https://www.snhu.edu/about-us/newsroom/health/what-is-self-care",
                 imageName: "self_care",
                 description: "Understand why self-care is crucial for your overall well-being and how to incorporate it into your daily routine.")
]
