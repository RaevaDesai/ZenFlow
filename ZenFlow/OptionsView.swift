import SwiftUI
import HealthKit

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
    @State private var showSleepTracker = false // New sleep tracker state
    @State private var dailyAffirmation = "You are capable of amazing things!"
    @State private var sleepData: [SleepData] = [] // Placeholder for sleep data

    // HealthKit setup
    let healthStore = HKHealthStore()

    init(name: String, age: String, gradeLevel: String, sleepHours: Double, stressLevel: Int, anxietyLevel: Int, moodRating: Int, studyHours: Double, screenTime: Double, exerciseHours: Double, yogaExperience: String, meditationFrequency: Double, concentrationLevel: Int, energyLevel: Int, socialConnectionRating: Int, academicPerformance: Int, extracurricularHours: Double, hasRegularRoutine: Bool, experiencesTestAnxiety: Bool, hasDifficultiesConcentrating: Bool, feelsOverwhelmed: Bool, practicesMindfullness: Bool, hasHealthyDiet: Bool, participatesInSports: Bool, enjoysSchool: Bool, hasSupportSystem: Bool, usesRelaxationTechniques: Bool, interestedInYoga: Bool, academicGoals: Set<String>, mentalHealthGoals: Set<String>, yogaInterests: Set<String>, studyHabits: Set<String>, onWellnessAnalyzer: @escaping () -> Void, onYogaPlan: @escaping () -> Void) {
        self.name = name
        self.age = age
        self.gradeLevel = gradeLevel
        self.sleepHours = sleepHours
        self.stressLevel = stressLevel
        self.anxietyLevel = anxietyLevel
        self.moodRating = moodRating
        self.studyHours = studyHours
        self.screenTime = screenTime
        self.exerciseHours = exerciseHours
        self.yogaExperience = yogaExperience
        self.meditationFrequency = meditationFrequency
        self.concentrationLevel = concentrationLevel
        self.energyLevel = energyLevel
        self.socialConnectionRating = socialConnectionRating
        self.academicPerformance = academicPerformance
        self.extracurricularHours = extracurricularHours
        self.hasRegularRoutine = hasRegularRoutine
        self.experiencesTestAnxiety = experiencesTestAnxiety
        self.hasDifficultiesConcentrating = hasDifficultiesConcentrating
        self.feelsOverwhelmed = feelsOverwhelmed
        self.practicesMindfullness = practicesMindfullness
        self.hasHealthyDiet = hasHealthyDiet
        self.participatesInSports = participatesInSports
        self.enjoysSchool = enjoysSchool
        self.hasSupportSystem = hasSupportSystem
        self.usesRelaxationTechniques = usesRelaxationTechniques
        self.interestedInYoga = interestedInYoga
        self.academicGoals = academicGoals
        self.mentalHealthGoals = mentalHealthGoals
        self.yogaInterests = yogaInterests
        self.studyHabits = studyHabits
        self.onWellnessAnalyzer = onWellnessAnalyzer
        self.onYogaPlan = onYogaPlan

        // Request authorization for sleep analysis
        requestSleepAuthorization()
    }
    
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
                        showFitnessTracker = true
                    })
                    TabButton(title: "Sleep", imageName: "bed.double", action: {  //sleep tab
                        showSleepTracker = true
                    })
                }
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.9))}
        }
        .edgesIgnoringSafeArea(.bottom)

        .sheet(isPresented: $showExerciseAnalyzer) {
            ExerciseAnalyzerView()
        }
        /*.sheet(isPresented: $showFitnessTracker) {
            FitnessTrackerView(
                fitnessGoals: academicGoals,
                name: name,
                currentWeight: "50",
                goalWeight: "50",
                activityLevel: 3.0
            )
        } */
        .sheet(isPresented: $showSleepTracker) { // New sleep tracker sheet
            SleepTrackerView(sleepData: $sleepData)

        }
    }

    // HealthKit authorization request
    func requestSleepAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        healthStore.requestAuthorization(toShare: nil, read: Set([sleepType])) { (success, error) in
            if success {
                print("Authorization granted for sleep analysis.")
                // Fetch sleep data after authorization
                fetchSleepData()
            } else {
                print("Authorization denied. Error: \(String(describing: error))")
            }
        }
    }

    // Function to fetch sleep data from HealthKit
    func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                return
            }

            guard let sleepAnalysis = results as? [HKCategorySample] else {
                print("Could not convert results to HKCategorySample")
                return
            }

            // Process sleep analysis data
            var fetchedSleepData: [SleepData] = []
            for sample in sleepAnalysis {
                let startDate = sample.startDate
                let endDate = sample.endDate
                let value = sample.value

                // Convert HKCategoryValueSleepAnalysis to String
                var sleepStage: String
                switch value {
                case HKCategoryValueSleepAnalysis.inBed.rawValue:
                    sleepStage = "In Bed"
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    sleepStage = "Asleep REM"
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    sleepStage = "Asleep Core"
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    sleepStage = "Asleep Deep"
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    sleepStage = "Awake"
                default:
                    sleepStage = "Unknown"
                }

                let sleepEntry = SleepData(startDate: startDate, endDate: endDate, sleepStage: sleepStage)
                fetchedSleepData.append(sleepEntry)
            }

            // Update the state variable on the main thread
            DispatchQueue.main.async {
                self.sleepData = fetchedSleepData
            }
        }

        healthStore.execute(query)
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

struct ResourceItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let imageName: String
    let description: String
}

// Sleep Data Struct
struct SleepData: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let sleepStage: String // e.g., "Asleep Core", "Awake", "In Bed"
}

// Sleep Tracker View (to be displayed in the sheet)
struct SleepTrackerView: View {
    @Binding var sleepData: [SleepData]

    var body: some View {
        VStack {
            Text("Sleep Tracker")
                .font(.largeTitle)
                .padding()

            if sleepData.isEmpty {
                Text("No sleep data available.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(sleepData) { sleepEntry in
                        HStack {
                            Text("\(sleepEntry.startDate, formatter: dateFormatter) - \(sleepEntry.endDate, formatter: timeFormatter)")
                            Spacer()
                            Text(sleepEntry.sleepStage)
                        }
                    }
                }
            }

        }
    }

    // Date and time formatters
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
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
