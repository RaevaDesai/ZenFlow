//
//  ReminderView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

import EventKit

import UserNotifications



struct ReminderView: View {

    let name: String

    @State private var selectedDate = Date()

    @State private var events: [Event] = []

    @State private var showingAddEvent = false

    @State private var showingAddTodo = false

    @State private var todos: [Todo] = []

    @State private var reminderTime = Date()

    @State private var isReminderSet = false

    @State private var isBreathing = false

    @State private var breathingTimeRemaining = 300 // 5 minutes

    @State private var breathState = "Inhale"

    

    let eventStore = EKEventStore()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    

    var body: some View {

        NavigationView {

            ScrollView {

                VStack(spacing: 20) {

                    welcomeSection

                    dailyReminderSection

                    calendarSection

                    todoSection

                    breathingExerciseSection

                }

                .padding()

            }

            .sheet(isPresented: $showingAddEvent) {

                AddEventView(date: selectedDate, onSave: addEvent)

            }

            .sheet(isPresented: $showingAddTodo) {

                AddTodoView(onSave: addTodo)

            }

            .onAppear {

                requestCalendarAccess()

                loadEvents()

                loadTodos()

            }

        }

    }

    

    var welcomeSection: some View {

        Text("Welcome, \(name)")

            .font(.largeTitle)

            .fontWeight(.bold)

            .frame(maxWidth: .infinity, alignment: .leading)

    }

    

    var dailyReminderSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("Daily Mindfulness Reminder")

                .font(.headline)

            

            DatePicker("Set reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)

            

            Button(action: {

                isReminderSet.toggle()

                if isReminderSet {

                    scheduleReminder()

                } else {

                    cancelReminder()

                }

            }) {

                Text(isReminderSet ? "Reminder Set" : "Set Reminder")

                    .padding()

                    .background(isReminderSet ? Color.green : Color.blue)

                    .foregroundColor(.white)

                    .cornerRadius(10)

            }

        }

        .padding()

        .background(Color.gray.opacity(0.1))

        .cornerRadius(15)

    }

    

    var calendarSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("Calendar")

                .font(.headline)

            

            DatePicker(

                "Select Date",

                selection: $selectedDate,

                displayedComponents: [.date]

            )

            .datePickerStyle(GraphicalDatePickerStyle())

            .frame(height: 300)

            .onChange(of: selectedDate) { _ in

                loadEvents()

            }

            

            Button("Add Event") {

                showingAddEvent = true

            }

            .padding(.vertical)

            

            ForEach(events) { event in

                HStack {

                    VStack(alignment: .leading) {

                        Text(event.title)

                            .font(.subheadline)

                        Text(event.startDate, style: .time)

                            .font(.caption)

                    }

                    Spacer()

                    Button(action: {

                        deleteEvent(event)

                    }) {

                        Image(systemName: "trash")

                            .foregroundColor(.red)

                    }

                }

                .padding(.vertical, 5)

            }

        }

        .padding()

        .background(Color.gray.opacity(0.1))

        .cornerRadius(15)

    }

    

    var todoSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {

                Text("To-Do List")

                    .font(.headline)

                Spacer()

                Button("Add") {

                    showingAddTodo = true

                }

            }

            

            ForEach(todos) { todo in

                HStack {

                    Button(action: {

                        toggleTodo(todo)

                    }) {

                        Image(systemName: todo.isCompleted ? "checkmark.square" : "square")

                    }

                    Text(todo.title)

                    Spacer()

                    Button(action: {

                        deleteTodo(todo)

                    }) {

                        Image(systemName: "trash")

                            .foregroundColor(.red)

                    }

                }

            }

        }

        .padding()

        .background(Color.gray.opacity(0.1))

        .cornerRadius(15)

    }

    

    var breathingExerciseSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("Breathing Exercise")

                .font(.headline)

            

            if isBreathing {

                Text(timeString(time: breathingTimeRemaining))

                    .font(.largeTitle)

                    .padding()

                

                Text(breathState)

                    .font(.title)

                    .foregroundColor(.blue)

                    .padding()

                

                Button("Stop") {

                    isBreathing = false

                }

                .padding()

                .background(Color.red)

                .foregroundColor(.white)

                .cornerRadius(10)

            } else {

                Button("Start 5-min Breathing Exercise") {

                    startBreathing()

                }

                .padding()

                .background(Color.blue)

                .foregroundColor(.white)

                .cornerRadius(10)

            }

        }

        .padding()

        .background(Color.gray.opacity(0.1))

        .cornerRadius(15)

        .onReceive(timer) { _ in

            if isBreathing {

                if breathingTimeRemaining > 0 {

                    breathingTimeRemaining -= 1

                    updateBreathState()

                } else {

                    isBreathing = false

                }

            }

        }

    }

    

    func requestCalendarAccess() {

        eventStore.requestAccess(to: .event) { granted, error in

            if granted && error == nil {

                print("Calendar access granted")

            } else {

                print("Calendar access denied")

            }

        }

    }

    

    func loadEvents() {

        let calendar = Calendar.current

        let startDate = calendar.startOfDay(for: selectedDate)

        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

        let ekEvents = eventStore.events(matching: predicate)

        

        events = ekEvents.map { Event(ekEvent: $0) }

    }

    

    func addEvent(_ event: Event) {

        let ekEvent = EKEvent(eventStore: eventStore)

        ekEvent.title = event.title

        ekEvent.startDate = event.startDate

        ekEvent.endDate = event.endDate

        ekEvent.calendar = eventStore.defaultCalendarForNewEvents

        

        do {

            try eventStore.save(ekEvent, span: .thisEvent)

            loadEvents()

        } catch {

            print("Failed to save event with error: \(error)")

        }

    }

    

    func deleteEvent(_ event: Event) {

        guard let ekEvent = eventStore.event(withIdentifier: event.id) else { return }

        

        do {

            try eventStore.remove(ekEvent, span: .thisEvent)

            loadEvents()

        } catch {

            print("Failed to delete event with error: \(error)")

        }

    }

    

    func loadTodos() {

        if let data = UserDefaults.standard.data(forKey: "todos") {

            if let decoded = try? JSONDecoder().decode([Todo].self, from: data) {

                todos = decoded

            }

        }

    }

    

    func saveTodos() {

        if let encoded = try? JSONEncoder().encode(todos) {

            UserDefaults.standard.set(encoded, forKey: "todos")

        }

    }

    

    func addTodo(_ todo: Todo) {

        todos.append(todo)

        saveTodos()

    }

    

    func toggleTodo(_ todo: Todo) {

        if let index = todos.firstIndex(where: { $0.id == todo.id }) {

            todos[index].isCompleted.toggle()

            saveTodos()

        }

    }

    

    func deleteTodo(_ todo: Todo) {

        todos.removeAll { $0.id == todo.id }

        saveTodos()

    }

    

    func scheduleReminder() {

        let content = UNMutableNotificationContent()

        content.title = "Time for Mindfulness"

        content.body = "Take a moment for your daily mindfulness practice."

        content.sound = UNNotificationSound.default

        

        let calendar = Calendar.current

        var dateComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)

        dateComponents.second = 0

        

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyMindfulness", content: content, trigger: trigger)

        

        UNUserNotificationCenter.current().add(request) { error in

            if let error = error {

                print("Error scheduling notification: \(error)")

            }

        }

    }

    

    func cancelReminder() {

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMindfulness"])

    }

    

    func startBreathing() {

        isBreathing = true

        breathingTimeRemaining = 300 // 5 minutes

    }

    

    func updateBreathState() {

        let cycle = breathingTimeRemaining % 8

        if cycle < 4 {

            breathState = "Inhale"

        } else {

            breathState = "Exhale"

        }

    }

    

    func timeString(time: Int) -> String {

        let minutes = Int(time) / 60 % 60

        let seconds = Int(time) % 60

        return String(format:"%02i:%02i", minutes, seconds)

    }

}



struct Event: Identifiable {

    let id: String

    var title: String

    var startDate: Date

    var endDate: Date

    

    init(id: String = UUID().uuidString, title: String, startDate: Date, endDate: Date) {

        self.id = id

        self.title = title

        self.startDate = startDate

        self.endDate = endDate

    }

    

    init(ekEvent: EKEvent) {

        self.id = ekEvent.eventIdentifier

        self.title = ekEvent.title

        self.startDate = ekEvent.startDate

        self.endDate = ekEvent.endDate

    }

}



struct Todo: Codable, Identifiable {

    let id: String

    var title: String

    var isCompleted: Bool

    

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {

        self.id = id

        self.title = title

        self.isCompleted = isCompleted

    }

}



struct AddEventView: View {

    @State private var title = ""

    @State private var startDate: Date

    @State private var endDate: Date

    @Environment(\.presentationMode) var presentationMode

    let onSave: (Event) -> Void

    

    init(date: Date, onSave: @escaping (Event) -> Void) {

        _startDate = State(initialValue: date)

        _endDate = State(initialValue: date.addingTimeInterval(3600))

        self.onSave = onSave

    }

    

    var body: some View {

        NavigationView {

            Form {

                TextField("Title", text: $title)

                DatePicker("Start", selection: $startDate)

                DatePicker("End", selection: $endDate)

            }

            .navigationTitle("Add Event")

            .navigationBarItems(

                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },

                trailing: Button("Save") {

                    let newEvent = Event(title: title, startDate: startDate, endDate: endDate)

                    onSave(newEvent)

                    presentationMode.wrappedValue.dismiss()

                }

                .disabled(title.isEmpty)

            )

        }

    }

}



struct AddTodoView: View {

    @State private var title = ""

    @Environment(\.presentationMode) var presentationMode

    let onSave: (Todo) -> Void

    

    var body: some View {

        NavigationView {

            Form {

                TextField("Title", text: $title)

            }

            .navigationTitle("Add To-Do")

            .navigationBarItems(

                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },

                trailing: Button("Save") {

                    let newTodo = Todo(title: title)

                    onSave(newTodo)

                    presentationMode.wrappedValue.dismiss()

                }

                .disabled(title.isEmpty)

            )

        }

    }

}
