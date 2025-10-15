import SwiftUI

struct MyJournalView: View {
    @EnvironmentObject private var journalStore: JournalStore

    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    private let prompts = RitualLibrary.prompts
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 2 // 以星期一为一周起始
        return calendar
    }()

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    private let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    monthHeader
                    weekdayHeader
                    calendarGrid
                    detailSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "FFECD1"), Color(hex: "FFC2E1")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let today = calendar.startOfDay(for: Date())
                displayedMonth = calendar.startOfMonth(for: today)
                selectedDate = today
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "4C2A1C"))
                    .padding(8)
                    .background(Color.white.opacity(0.6), in: Circle())
            }

            Spacer()

            Text(monthFormatter.string(from: displayedMonth))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "4C2A1C"))

            Spacer()

            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "4C2A1C"))
                    .padding(8)
                    .background(Color.white.opacity(0.6), in: Circle())
            }
        }
    }

    private var weekdayHeader: some View {
        let symbols = reorderedWeekdaySymbols()
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "6E4733").opacity(0.8))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = generateDays(for: displayedMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
            ForEach(days) { day in
                dayCell(for: day)
            }
        }
    }

    private func dayCell(for day: CalendarDay) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let hasEntry = journalStore.entry(for: day.date) != nil
        let textColor: Color = day.isWithinDisplayedMonth ? Color(hex: "4C2A1C") : Color(hex: "6E4733").opacity(0.3)

        return Button(action: {
            selectedDate = calendar.startOfDay(for: day.date)
        }) {
            VStack(spacing: 6) {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : textColor)

                Circle()
                    .fill(Color(hex: "FF8A5B"))
                    .frame(width: 6, height: 6)
                    .opacity(hasEntry ? 1 : 0)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF8866"), Color(hex: "FFA552"), Color(hex: "FFC95C")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FF8A5B").opacity(0.35), radius: 10, x: 0, y: 6)
                    } else if hasEntry {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.65))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(day.isWithinDisplayedMonth ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    private var detailSection: some View {
        let entry = journalStore.entry(for: selectedDate)

        return VStack(alignment: .leading, spacing: 18) {
            Text(detailDateFormatter.string(from: selectedDate))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "4C2A1C"))

            if let entry = entry {
                VStack(spacing: 18) {
                    ForEach(prompts, id: \.id) { prompt in
                        let raw = entry.responses[prompt.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let display = raw.isEmpty ? "当日未留下文字。" : raw

                        VStack(alignment: .leading, spacing: 10) {
                            Text(prompt.title)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "4C2A1C"))
                            Text(display)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "6E4733").opacity(0.82))
                            .lineSpacing(5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.55), lineWidth: 1)
                        )
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(Color(hex: "FF8A5B"))
                    Text("暂无日志")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "4C2A1C"))
                    Text("点击带有小圆点的日期，回看那一天的晨间仪式文字。")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "6E4733").opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.82))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
    }

    private func shiftMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = calendar.startOfMonth(for: newMonth)
        if !calendar.isDate(selectedDate, equalTo: displayedMonth, toGranularity: .month) {
            selectedDate = displayedMonth
        }
    }

    private func reorderedWeekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        guard let symbols = formatter.shortStandaloneWeekdaySymbols else { return ["日","一","二","三","四","五","六"] }
        let shift = calendar.firstWeekday - 1
        let prefix = symbols[..<symbols.index(symbols.startIndex, offsetBy: shift)]
        let suffix = symbols[symbols.index(symbols.startIndex, offsetBy: shift)...]
        return Array(suffix + prefix)
    }

    private func generateDays(for month: Date) -> [CalendarDay] {
        let startOfMonth = calendar.startOfMonth(for: month)
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        let totalDays = range.count
        let totalCells = ((offset + totalDays + 6) / 7) * 7

        return (0..<totalCells).compactMap { index in
            guard let date = calendar.date(byAdding: .day, value: index - offset, to: startOfMonth) else { return nil }
            let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
            return CalendarDay(date: date, isWithinDisplayedMonth: isCurrentMonth)
        }
    }
}

private struct CalendarDay: Identifiable {
    var id: Date { date }
    let date: Date
    let isWithinDisplayedMonth: Bool
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    MyJournalView()
        .environmentObject(JournalStore())
}
