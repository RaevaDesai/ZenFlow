import SwiftUI
struct HealthFormView: View {
    var shouldShowOptions: Bool
    var onShouldShowOptionsChange: (Bool) -> Void
    @State private var name = ""
    @State private var age = ""
    @State private var gradeLevel = ""
    @State private var sleepHours = 7.0
    @State private var stressLevel = 5
    @State private var anxietyLevel = 5
    @State private var moodRating = 5
    @State private var studyHours = 2.0
    @State private var screenTime = 4.0
    @State private var exerciseHours = 1.0
    @State private var yogaExperience = 0
    @State private var meditationFrequency = 0.0
    @State private var concentrationLevel = 5
    @State private var energyLevel = 5
    @State private var socialConnectionRating = 5
    @State private var academicPerformance = 5
    @State private var extracurricularHours = 2.0
    
    @State private var hasRegularRoutine = false
    @State private var experiencesTestAnxiety = false
    @State private var hasDifficultiesConcentrating = false
    @State private var feelsOverwhelmed = false
    @State private var practicesMindfullness = false
    @State private var hasHealthyDiet = false
    @State private var participatesInSports = false
    @State private var enjoysSchool = false
    @State private var hasSupportSystem = false
    @State private var usesRelaxationTechniques = false
    @State private var interestedInYoga = false

    let gradeLevelOptions = ["6th", "7th", "8th", "9th", "10th", "11th", "12th"]
    let yogaExperienceOptions = ["None", "Beginner", "Intermediate", "Advanced"]
    let academicGoals = ["Improve Grades", "Reduce Stress", "Better Time Management", "Enhance Focus", "Balance School and Life"]
    let mentalHealthGoals = ["Reduce Anxiety", "Improve Mood", "Better Sleep", "Increase Self-esteem", "Manage Stress"]
    let yogaInterests = ["Flexibility", "Strength", "Balance", "Relaxation", "Mindfulness"]
    let studyHabits = ["Note-taking", "Flashcards", "Group Study", "Online Resources", "Tutoring"]

    @State private var selectedAcademicGoals = Set<String>()
    @State private var selectedMentalHealthGoals = Set<String>()
    @State private var selectedYogaInterests = Set<String>()
    @State private var selectedStudyHabits = Set<String>()

    var onSubmit: (OptionsView) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Student Wellness Profile")
                    .font(.custom("AvenirNext-Heavy", size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding()

                Group {
                    textField(question: "What is your name?", text: $name, color: .purple)
                    textField(question: "What is your age?", text: $age, color: .purple)

                    VStack(alignment: .leading) {
                        Text("What is your grade level?")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(.purple)
                        Picker("Grade Level", selection: $gradeLevel) {
                            ForEach(gradeLevelOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Group {
                    customSlider(title: "Hours of Sleep per Night", value: $sleepHours, range: 4...12, step: 0.5)
                    customSlider(title: "Stress Level", value: Binding(get: { Double(stressLevel) }, set: { stressLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Anxiety Level", value: Binding(get: { Double(anxietyLevel) }, set: { anxietyLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Mood Rating", value: Binding(get: { Double(moodRating) }, set: { moodRating = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Daily Study Hours", value: $studyHours, range: 0...8, step: 0.5)
                    customSlider(title: "Daily Screen Time (hours)", value: $screenTime, range: 0...12, step: 0.5)
                    customSlider(title: "Weekly Exercise Hours", value: $exerciseHours, range: 0...14, step: 0.5)
                    customSlider(title: "Concentration Level", value: Binding(get: { Double(concentrationLevel) }, set: { concentrationLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Energy Level", value: Binding(get: { Double(energyLevel) }, set: { energyLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Social Connection Rating", value: Binding(get: { Double(socialConnectionRating) }, set: { socialConnectionRating = Int($0) }), range: 1...10, step: 1)
                }
                Group {
                    customSlider(title: "Academic Performance Rating", value: Binding(get: { Double(academicPerformance) }, set: { academicPerformance = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Weekly Extracurricular Hours", value: $extracurricularHours, range: 0...20, step: 0.5)
                    customSlider(title: "Meditation Frequency (times per week)", value: $meditationFrequency, range: 0...7, step: 1)
                    
                    VStack(alignment: .leading) {
                        Text("Yoga Experience Level")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(.purple)
                        Picker("Yoga Experience", selection: $yogaExperience) {
                            ForEach(0..<yogaExperienceOptions.count) {
                                Text(self.yogaExperienceOptions[$0])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Group {
                    Text("Yes/No Questions")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.purple)
                        .padding(.top)

                    ForEach([
                        ("Do you have a regular daily routine?", $hasRegularRoutine),
                        ("Do you experience test anxiety?", $experiencesTestAnxiety),
                        ("Do you have difficulties concentrating?", $hasDifficultiesConcentrating),
                        ("Do you often feel overwhelmed?", $feelsOverwhelmed),
                        ("Do you practice mindfulness?", $practicesMindfullness),
                        ("Do you maintain a healthy diet?", $hasHealthyDiet),
                        ("Do you participate in school sports?", $participatesInSports),
                        ("Do you enjoy going to school?", $enjoysSchool),
                        ("Do you have a good support system?", $hasSupportSystem),
                        ("Do you use relaxation techniques?", $usesRelaxationTechniques),
                        ("Are you interested in trying yoga?", $interestedInYoga)
                    ], id: \.0) { question, binding in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(question)
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .foregroundColor(.purple)
                            
                            Toggle("", isOn: binding)
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                                .labelsHidden()
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Button(action: {
                    print("Name in HealthFormView: \(name)")
                    let optionsView = OptionsView(
                        name: name,
                        age: age,
                        gradeLevel: gradeLevel,
                        sleepHours: sleepHours,
                        stressLevel: stressLevel,
                        anxietyLevel: anxietyLevel,
                        moodRating: moodRating,
                        studyHours: studyHours,
                        screenTime: screenTime,
                        exerciseHours: exerciseHours,
                        yogaExperience: yogaExperienceOptions[yogaExperience],
                        meditationFrequency: meditationFrequency,
                        concentrationLevel: concentrationLevel,
                        energyLevel: energyLevel,
                        socialConnectionRating: socialConnectionRating,
                        academicPerformance: academicPerformance,
                        extracurricularHours: extracurricularHours,
                        hasRegularRoutine: hasRegularRoutine,
                        experiencesTestAnxiety: experiencesTestAnxiety,
                        hasDifficultiesConcentrating: hasDifficultiesConcentrating,
                        feelsOverwhelmed: feelsOverwhelmed,
                        practicesMindfullness: practicesMindfullness,
                        hasHealthyDiet: hasHealthyDiet,
                        participatesInSports: participatesInSports,
                        enjoysSchool: enjoysSchool,
                        hasSupportSystem: hasSupportSystem,
                        usesRelaxationTechniques: usesRelaxationTechniques,
                        interestedInYoga: interestedInYoga,
                        academicGoals: selectedAcademicGoals,
                        mentalHealthGoals: selectedMentalHealthGoals,
                        yogaInterests: selectedYogaInterests,
                        studyHabits: selectedStudyHabits,
                        onWellnessAnalyzer: {
                        },
                        onYogaPlan: {
                        }
                    )
                    print("OptionsView created with name: \(optionsView.name)")
                    onSubmit(optionsView)
                    onShouldShowOptionsChange(true)
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .font(.custom("AvenirNext-Bold", size: 20))
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }

}


private func textField(question: String, text: Binding<String>, color: Color) -> some View {
    VStack(alignment: .leading) {
        Text(question)
            .font(.custom("AvenirNext-Bold", size: 18))
            .foregroundColor(color)
        TextField("Enter your answer", text: text)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .font(.custom("AvenirNext-Regular", size: 18))
    }
}

    
    private func customSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(.purple)
            HStack {
                Slider(value: value, in: range, step: step)
                    .accentColor(.purple)
                Text(String(format: "%.1f", value.wrappedValue))
                    .font(.custom("AvenirNext-Regular", size: 16))
            }
        }
    }

