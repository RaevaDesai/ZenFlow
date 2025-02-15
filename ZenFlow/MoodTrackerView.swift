import SwiftUI

struct MoodTrackerView: View {
    @State private var selectedDate = Date()
    @State private var moodEntries: [Date: Mood] = [:]
    
    let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Mood Tracker")
                .font(.custom("Arial Rounded MT Bold", size: 24))
                .padding(.top)
            
            CalendarView(selectedDate: $selectedDate, moodEntries: $moodEntries)
            
            Text("How were you feeling on \(selectedDate, formatter: dateFormatter)?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: UIScreen.main.bounds.width * 0.8) // Explicit width, adjust as needed
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
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
        }
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
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
