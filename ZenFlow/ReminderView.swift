//
//  ReminderView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

struct ReminderView: View {
    let name: String
    @State private var reminderTime = Date()
    @State private var isReminderSet = false
    @State private var isMeditating = false
    @State private var isBreathing = false
    @State private var timeRemaining = 0
    @State private var breathState = "Inhale"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !isMeditating && !isBreathing {
                    Text("Welcome to your daily mindfulness practice, \(name)!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    DatePicker("Set daily reminder", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .padding()
                    
                    Button(action: {
                        isReminderSet = true
                        scheduleReminder()
                    }) {
                        Text(isReminderSet ? "Reminder Set" : "Set Reminder")
                            .padding()
                            .background(isReminderSet ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        startMeditation()
                    }) {
                        Text("Start 10-min Meditation")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        startBreathing()
                    }) {
                        Text("Start 5-min Breathing Exercise")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else if isMeditating {
                    Text("10-Minute Meditation")
                        .font(.largeTitle)
                        .padding()
                    
                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 50))
                        .padding()
                    
                    Text("Close your eyes and focus on your breath...")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        isMeditating = false
                    }) {
                        Text("End Meditation")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else if isBreathing {
                    Text("5-Minute Breathing Exercise")
                        .font(.largeTitle)
                        .padding()
                    
                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 50))
                        .padding()
                    
                    Text(breathState)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("Focus on your breath...")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        isBreathing = false
                    }) {
                        Text("End Breathing Exercise")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Daily Mindfulness")
        }
        .onReceive(timer) { _ in
            if isMeditating || isBreathing {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if isBreathing {
                        updateBreathState()
                    }
                } else {
                    isMeditating = false
                    isBreathing = false
                }
            }
        }
    }
    
    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time for Mindfulness"
        content.body = "It's time for your daily meditation and breathing exercises."
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Reminder notification scheduled successfully")
            }
        }
    }

    
    func startMeditation() {
        isMeditating = true
        timeRemaining = 600 // 10 minutes
    }
    
    func startBreathing() {
        isBreathing = true
        timeRemaining = 300 // 5 minutes
    }
    
    func timeString(time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func updateBreathState() {
        let cycle = timeRemaining % 8
        if cycle < 4 {
            breathState = "Inhale"
        } else {
            breathState = "Exhale"
        }
    }
}
