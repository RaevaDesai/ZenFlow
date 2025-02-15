import SwiftUI
import Charts

struct MoodTrackerView: View {
    @State private var selectedMood: Mood = .neutral
    @State private var moodNote: String = ""
    @State private var showingAddMood = false
    @State private var moodEntries: [MoodEntry] = []
    
    let moodColors: [Mood: Color] = [
        .terrible: .red,
        .bad: .orange,
        .neutral: .yellow,
        .good: .green,
        .great: .blue
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                moodChart
                moodList
            }
            .navigationTitle("Mood Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMood) {
                addMoodView
            }
        }
    }
    
    var moodChart: some View {
        Chart(moodEntries) { entry in
            PointMark(
                x: .value("Date", entry.date),
                y: .value("Mood", entry.mood.rawValue)
            )
            .foregroundStyle(moodColors[entry.mood] ?? .gray)
        }
        .frame(height: 200)
        .padding()
    }
    
    var moodList: some View {
        List(moodEntries.sorted(by: { $0.date > $1.date })) { entry in
            HStack {
                Text(entry.date, style: .date)
                Spacer()
                Text(entry.mood.emoji)
                    .font(.title)
                Text(entry.note)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var addMoodView: some View {
        NavigationView {
            Form {
                Picker("How are you feeling?", selection: $selectedMood) {
                    ForEach(Mood.allCases) { mood in
                        Text(mood.emoji).tag(mood)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Add a note (optional)", text: $moodNote)
                
                Button("Save") {
                    let newEntry = MoodEntry(mood: selectedMood, note: moodNote, date: Date())
                    moodEntries.append(newEntry)
                    showingAddMood = false
                    moodNote = ""
                }
            }
            .navigationTitle("Add Mood")
            .navigationBarItems(trailing: Button("Cancel") {
                showingAddMood = false
            })
        }
    }
}

struct MoodEntry: Identifiable {
    let id = UUID()
    let mood: Mood
    let note: String
    let date: Date
}

enum Mood: Int, CaseIterable, Identifiable {
    case terrible = 1, bad, neutral, good, great
    
    var id: Int { self.rawValue }
    
    var emoji: String {
        switch self {
        case .terrible: return "😢"
        case .bad: return "😕"
        case .neutral: return "😐"
        case .good: return "😊"
        case .great: return "😃"
        }
    }
}
