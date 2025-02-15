import SwiftUI

struct OptionsView: View {
    let name: String
    let age: String
    let gradeLevel: String
    let sleepHours: Double
    let stressLevel: Int
    let anxietyLevel: Int
    let moodRating: Int
    let studyHours: Double
    let screenTime: Double
    let exerciseHours: Double
    let yogaExperience: String
    let meditationFrequency: Double
    let concentrationLevel: Int
    let energyLevel: Int
    let socialConnectionRating: Int
    let academicPerformance: Int
    let extracurricularHours: Double
    let hasRegularRoutine: Bool
    let experiencesTestAnxiety: Bool
    let hasDifficultiesConcentrating: Bool
    let feelsOverwhelmed: Bool
    let practicesMindfullness: Bool
    let hasHealthyDiet: Bool
    let participatesInSports: Bool
    let enjoysSchool: Bool
    let hasSupportSystem: Bool
    let usesRelaxationTechniques: Bool
    let interestedInYoga: Bool
    let academicGoals: Set<String>
    let mentalHealthGoals: Set<String>
    let yogaInterests: Set<String>
    let studyHabits: Set<String>
    let onWellnessAnalyzer: () -> Void
    let onYogaPlan: () -> Void
    @State private var showFitnessTracker = false
    @State private var showMealScan = false
    @State private var showNutritionAnalyzer = false
    @State private var showExerciseAnalyzer = false
    @State private var showReminderView = false
    @State private var showMoodTracker = false
    @State private var dailyAffirmation = "You are capable of amazing things!"

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
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
                    TabButton(title: "Yoga", imageName: "figure.yoga", action: {
                        print("Yoga button tapped")
                        showFitnessTracker = true
                    })
                    
                    TabButton(title: "Mood", imageName: "face.smiling", action: {
                        print("Mood button tapped")
                        showMoodTracker = true
                    })

                    TabButton(title: "Reminder", imageName: "brain.head.profile", action: {
                        print("Reminder button tapped")
                        showReminderView = true
                    })
                }
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.9))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showFitnessTracker) {
            FitnessTrackerView(
                yogaGoals: yogaInterests,
                name: name,
                mentalHealthMeds: "",
                mentalDisorders: ""
            )
        }
        .sheet(isPresented: $showReminderView) {
            ReminderView(name: name)
        }
        .sheet(isPresented: $showMoodTracker) {
            MoodTrackerView()
        }
    }
}

struct AffirmationView: View {
    @Binding var affirmation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Affirmation")
                .font(.headline)
                .foregroundColor(.purple)
            
            Text(affirmation)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]),
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
                    .foregroundColor(.purple)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.purple)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

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

struct ResourceItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let imageName: String
    let description: String
}

let mentalHealthResources: [ResourceItem] = [
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
