//
//  HealthFormView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

struct MultiSelector<T: Hashable>: View {
    let label: Text
    let options: [T]
    let optionToString: (T) -> String
    
    @Binding var selected: Set<T>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            label
            ForEach(options, id: \.self) { option in
                Button(action: { toggleSelection(option: option) }) {
                    HStack {
                        Image(systemName: selected.contains(option) ? "checkmark.square.fill" : "square")
                            .foregroundColor(selected.contains(option) ? .orange : .gray)
                        Text(optionToString(option))
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    private func toggleSelection(option: T) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}

struct HealthFormView: View {
    var shouldShowOptions: Bool
    var onShouldShowOptionsChange: (Bool) -> Void
    @State private var name = ""
    @State private var currentWeight = ""
    @State private var goalWeight = ""
    @State private var height = ""
    @State private var age = ""
    @State private var gender = 0
    @State private var activityLevel = 2.0
    @State private var dailyWaterIntake = 2.0
    @State private var exerciseHours = 3.0
    @State private var sleepHours = 7.0
    @State private var stressLevel = 5
    @State private var energyLevel = 5
    @State private var moodRating = 5
    @State private var sittingHours = 6.0
    @State private var motivationLevel = 5
    @State private var fitnessGoals = Set<String>()
    @State private var exercisePreferences = Set<String>()
    @State private var supplements = Set<String>()
    @State private var medicalConditions = Set<String>()
    
    @State private var isVegan = false
    @State private var isVegetarian = false
    @State private var isLactoseIntolerant = false
    @State private var wantsClearSkin = false
    @State private var participatesInSports = false
    @State private var hasRegularMealSchedule = false
    @State private var studiesLate = false
    @State private var usesScreenBeforeBed = false
    @State private var hasExtracurricularActivities = false
    @State private var experiencesTestAnxiety = false
    @State private var hasDifficultiesConcentrating = false

    let genderOptions = ["Male", "Female", "Other"]
    let fitnessGoalOptions = ["Weight Loss", "Muscle Gain", "Improve Endurance", "Increase Flexibility", "Maintain Current Fitness"]
    let exercisePreferenceOptions = ["Cardio", "Strength Training", "Yoga", "Sports", "HIIT", "Swimming", "Cycling"]
    let supplementOptions = ["Multivitamin", "Protein", "Omega-3", "Vitamin D", "Probiotics"]
    let medicalConditionOptions = ["None", "Asthma", "Allergies", "ADHD", "Anxiety", "Depression"]

    var onSubmit: (OptionsView) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Health Profile")
                    .font(.custom("AvenirNext-Heavy", size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding()

                Group {
                    textField(question: "What is your name?", text: $name)
                    textField(question: "What is your current weight in kg?", text: $currentWeight)
                    textField(question: "What is your goal weight in kg?", text: $goalWeight)
                    textField(question: "What is your height in cm?", text: $height)
                    textField(question: "What is your age?", text: $age)
                    
                    VStack(alignment: .leading) {
                        Text("What is your gender?")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(.orange)
                        Picker("Gender", selection: $gender) {
                            ForEach(0..<genderOptions.count) {
                                Text(self.genderOptions[$0])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Group {
                    customSlider(title: "Activity Level", value: $activityLevel, range: 1...5, step: 1)
                    customSlider(title: "Daily Water Intake (liters)", value: $dailyWaterIntake, range: 0...5, step: 0.1)
                    customSlider(title: "Weekly Exercise Hours", value: $exerciseHours, range: 0...20, step: 0.5)
                    customSlider(title: "Hours of Sleep per Night", value: $sleepHours, range: 4...12, step: 0.5)
                    customSlider(title: "Stress Level", value: Binding(get: { Double(stressLevel) }, set: { stressLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Energy Level", value: Binding(get: { Double(energyLevel) }, set: { energyLevel = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Mood Rating", value: Binding(get: { Double(moodRating) }, set: { moodRating = Int($0) }), range: 1...10, step: 1)
                    customSlider(title: "Hours Spent Sitting", value: $sittingHours, range: 0...16, step: 0.5)
                    customSlider(title: "Motivation Level", value: Binding(get: { Double(motivationLevel) }, set: { motivationLevel = Int($0) }), range: 1...10, step: 1)
                }

                Group {
                    Text("Yes/No Questions")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.orange)
                        .padding(.top)

                    ForEach([
                        ("Are you vegan?", $isVegan),
                        ("Are you vegetarian?", $isVegetarian),
                        ("Are you lactose intolerant?", $isLactoseIntolerant),
                        ("Do you want to improve your skin?", $wantsClearSkin),
                        ("Do you participate in school sports?", $participatesInSports),
                        ("Do you have a regular meal schedule?", $hasRegularMealSchedule),
                        ("Do you often study late into the night?", $studiesLate),
                        ("Do you use screens (phone, computer) right before bed?", $usesScreenBeforeBed),
                        ("Do you participate in extracurricular activities?", $hasExtracurricularActivities),
                        ("Do you experience test anxiety?", $experiencesTestAnxiety),
                        ("Do you have difficulties concentrating?", $hasDifficultiesConcentrating)
                    ], id: \.0) { question, binding in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(question)
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .foregroundColor(.orange)
                            
                            Toggle("", isOn: binding)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .labelsHidden()
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Group {
                    MultiSelector(
                        label: Text("What are your fitness goals?").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(.orange),
                        options: fitnessGoalOptions,
                        optionToString: { $0 },
                        selected: $fitnessGoals
                    )
                    
                    MultiSelector(
                        label: Text("What types of exercise do you prefer?").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(.orange),
                        options: exercisePreferenceOptions,
                        optionToString: { $0 },
                        selected: $exercisePreferences
                    )
                    
                    MultiSelector(
                        label: Text("Do you take any supplements?").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(.orange),
                        options: supplementOptions,
                        optionToString: { $0 },
                        selected: $supplements
                    )
                    
                    MultiSelector(
                        label: Text("Do you have any medical conditions?").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(.orange),
                        options: medicalConditionOptions,
                        optionToString: { $0 },
                        selected: $medicalConditions
                    )
                }
                Button(action: {
                    print("Name in HealthFormView: \(name)")
                    let optionsView = OptionsView(
                        name: name,
                        currentWeight: currentWeight,
                        goalWeight: goalWeight,
                        height: height,
                        age: age,
                        gender: gender,
                        activityLevel: activityLevel,
                        dailyWaterIntake: dailyWaterIntake,
                        exerciseHours: exerciseHours,
                        sleepHours: sleepHours,
                        stressLevel: stressLevel,
                        energyLevel: energyLevel,
                        moodRating: moodRating,
                        sittingHours: sittingHours,
                        motivationLevel: motivationLevel,
                        fitnessGoals: fitnessGoals,
                        exercisePreferences: exercisePreferences,
                        supplements: supplements,
                        medicalConditions: medicalConditions,
                        isVegan: isVegan,
                        isVegetarian: isVegetarian,
                        isLactoseIntolerant: isLactoseIntolerant,
                        wantsClearSkin: wantsClearSkin,
                        participatesInSports: participatesInSports,
                        hasRegularMealSchedule: hasRegularMealSchedule,
                        studiesLate: studiesLate,
                        usesScreenBeforeBed: usesScreenBeforeBed,
                        hasExtracurricularActivities: hasExtracurricularActivities,
                        experiencesTestAnxiety: experiencesTestAnxiety,
                        hasDifficultiesConcentrating: hasDifficultiesConcentrating,
                        onNutritionAnalyzer: {
                            // Add your nutrition analyzer action here
                        },
                        onDietWaterPlan: {
                            // Add your diet/water plan action here
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
                        .background(Color.orange)
                        .cornerRadius(10)
                        .font(.custom("AvenirNext-Bold", size: 20))
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }

    private func textField(question: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(question)
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(.orange)
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
                .foregroundColor(.orange)
            HStack {
                Slider(value: value, in: range, step: step)
                    .accentColor(.orange)
                Text(String(format: "%.1f", value.wrappedValue))
                    .font(.custom("AvenirNext-Regular", size: 16))
            }
        }
    }
}
