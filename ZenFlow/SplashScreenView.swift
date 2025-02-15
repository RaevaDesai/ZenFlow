//
//  SplashScreenView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var navigateToForm = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var navigateToOptions = false

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
    @State private var dietaryRestrictions = Set<String>()
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
    
    @State private var currentOptionsView: OptionsView?


    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if !navigateToForm {
                Image("splash_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                scale = 1.2
                                opacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                navigateToForm = true
                            }
                        }
                    }
            } else {
                HealthFormView(
                    shouldShowOptions: navigateToOptions,
                    onShouldShowOptionsChange: { newValue in
                        navigateToOptions = newValue
                    },
                    onSubmit: { optionsView in
                        self.currentOptionsView = optionsView
                        navigateToOptions = true
                    }
                )
                .fullScreenCover(isPresented: $navigateToOptions) {
                    if let optionsView = currentOptionsView {
                        optionsView
                    } else {
                        Text("Loading...")
                    }
                }
            }
        }
    }
}
