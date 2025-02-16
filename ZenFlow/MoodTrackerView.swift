import SwiftUI
import CoreML

class AffirmationGenerator {
    private let model: PositiveAffirmationML

    init() {
        do {
            self.model = try PositiveAffirmationML(configuration: MLModelConfiguration())
        } catch {
            fatalError("Failed to initialize AffirmationGenerator: \(error)")
        }
    }

    func generateAffirmation(for mood: String) -> String {
        let category = mapMoodToCategory(mood)
        do {
            let input = PositiveAffirmationMLInput(text: category)
            let output = try model.prediction(input: input)
            return mapLabelToAffirmation(output.label)
        } catch {
            print("Error generating affirmation: \(error)")
            return "Each day is a new opportunity."
        }
    }

    private func mapMoodToCategory(_ mood: String) -> String {
        switch mood.lowercased() {
        case "tired", "stressed":
            return "sleep"
        case "sad", "depressed":
            return "happiness"
        case "angry", "anxious":
            return "spiritual"
        case "happy":
            return "blessing"
        case "grateful":
            return "gratitude"
        default:
            return "health"
        }
    }

    private func mapLabelToAffirmation(_ label: String) -> String {
        switch label.lowercased() {
        case "sleep":
            return "Rest is essential. Your body deserves peaceful sleep and rejuvenation."
        case "happiness":
            return "You deserve happiness. Embrace joy in the little things around you."
        case "spiritual":
            return "Find peace within yourself. Your inner strength is your greatest asset."
        case "blessing":
            return "You are blessed with countless opportunities. Recognize and appreciate them."
        case "gratitude":
            return "There is always something to be thankful for. Gratitude opens doors to positivity."
        case "health":
            return "Your well-being is paramount. Take care of your body and mind."
        default:
            return "Every day is a new beginning filled with potential."
        }
    }
}

struct MoodTrackerView: View {
    @State private var selectedDate = Date()
    @State private var moodEntries: [Date: Mood] = [:]
    @State private var currentAffirmation: String = ""
    @State private var showingAffirmation = false
    
    let calendar = Calendar.current
    let affirmationGenerator = AffirmationGenerator()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Mood Tracker")
                    .font(.custom("Arial Rounded MT Bold", size: 24))
                    .padding(.top)
                
                CalendarView(selectedDate: $selectedDate, moodEntries: $moodEntries)
                
                Text("How were you feeling on \(selectedDate, formatter: dateFormatter)?")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                    ForEach(Mood.allCases) { mood in
                        VStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(mood.color)
                                .frame(width: 40, height: 40)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Text(mood.rawValue.capitalized)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            moodEntries[calendar.startOfDay(for: selectedDate)] = mood
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
                
                Button(action: {
                    generateAffirmation()
                    showingAffirmation = true
                }) {
                    Text("Show Affirmation")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                if showingAffirmation {
                    DailyAffirmationView(affirmation: currentAffirmation)
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(), value: showingAffirmation)
                }
            }
            .padding()
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private func getMostFrequentMood() -> Mood? {
        let moodCounts = moodEntries.values.reduce(into: [:]) { counts, mood in
            counts[mood, default: 0] += 1
        }
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func generateAffirmation() {
        if let mostFrequentMood = getMostFrequentMood() {
            currentAffirmation = affirmationGenerator.generateAffirmation(for: mostFrequentMood.rawValue)
        } else {
            currentAffirmation = "Track your moods to get personalized affirmations!"
        }
    }
}


struct DailyAffirmationView: View {
    let affirmation: String
    
    var body: some View {
        Text(affirmation)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .foregroundColor(.white)
            .padding(.horizontal)
            .transition(.scale.combined(with: .opacity))
            .id(affirmation)
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: affirmation)
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var moodEntries: [Date: Mood]
    
    let calendar = Calendar.current
    
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: selectedDate)!
    }
    
    var body: some View {
        VStack {
            monthHeader
            weekdayHeader
            daysGrid
        }
        .background(Color.white.opacity(0.5))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
        .padding()
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(selectedDate, formatter: dateFormatter)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol.prefix(1))
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.system(size: 14, design: .rounded))
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }
    
    private var daysGrid: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        let firstWeekday = calendar.component(.weekday, from: month.start)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(0..<42) { index in
                if index < firstWeekday - 1 || index >= firstWeekday - 1 + daysInMonth {
                    Color.clear
                } else {
                    let date = calendar.date(byAdding: .day, value: index - (firstWeekday - 1), to: month.start)!
                    DayView(date: date, mood: moodEntries[calendar.startOfDay(for: date)])
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

struct DayView: View {
    let date: Date
    let mood: Mood?
    
    var body: some View {
        Text(String(Calendar.current.component(.day, from: date)))
            .font(.system(size: 14))
            .frame(width: 30, height: 30)
            .background(mood?.color ?? Color.clear)
            .clipShape(Circle())
    }
}

enum Mood: String, CaseIterable, Identifiable {
    case tired, sad, angry, happy, grateful, stressed, depressed, anxious
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .tired:       return Color(red: 0.6, green: 0.6, blue: 0.6)
        case .sad:         return Color(red: 0.2, green: 0.4, blue: 0.7)
        case .angry:       return Color(red: 0.8, green: 0.3, blue: 0.3)
        case .happy:       return Color(red: 0.9, green: 0.7, blue: 0.2)
        case .grateful:    return Color(red: 0.4, green: 0.7, blue: 0.4)
        case .stressed:    return Color(red: 0.6, green: 0.3, blue: 0.8)
        case .depressed:   return Color(red: 0.3, green: 0.2, blue: 0.6)
        case .anxious:     return Color(red: 0.8, green: 0.4, blue: 0.6)
        }
    }
    
}

func inspectModel() {
    guard let modelURL = Bundle.main.url(forResource: "PositiveAffirmationML", withExtension: "mlmodelc") else {
        print("Model file not found")
        return
    }
    
    do {
        let mlmodel = try MLModel(contentsOf: modelURL)
        let spec = mlmodel.modelDescription
        
        print("\nModel Outputs:")
        for output in spec.outputDescriptionsByName {
            print("- \(output.key): \(output.value.type)")
        }
    } catch {
        print("Error loading model: \(error)")
    }
}

