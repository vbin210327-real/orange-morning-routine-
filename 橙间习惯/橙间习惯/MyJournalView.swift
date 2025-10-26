import SwiftUI

struct MyJournalView: View {
    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.colorScheme) private var colorScheme

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

    private var palette: ThemePalette {
        ThemePalette(colorScheme: colorScheme)
    }

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
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .background(
                palette.background
                    .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
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
                    .foregroundColor(palette.primaryInk)
                    .padding(8)
                    .background(palette.toolbarButtonBackground, in: Circle())
            }

            Spacer()

            Text(monthFormatter.string(from: displayedMonth))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryInk)

            Spacer()

            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(palette.primaryInk)
                    .padding(8)
                    .background(palette.toolbarButtonBackground, in: Circle())
            }
        }
    }

    private var weekdayHeader: some View {
        let symbols = reorderedWeekdaySymbols()
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryInk.opacity(0.75))
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
        let textColor = palette.calendarDayTextColor(isWithinMonth: day.isWithinDisplayedMonth)

        return Button(action: {
            selectedDate = calendar.startOfDay(for: day.date)
        }) {
            VStack(spacing: 6) {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : textColor)

                Circle()
                    .fill(palette.calendarAccent)
                    .frame(width: 6, height: 6)
                    .opacity(hasEntry ? 1 : 0)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.calendarSelectedFill)
                            .shadow(color: palette.calendarSelectedShadow, radius: 10, x: 0, y: 6)
                    } else if hasEntry {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.cardFill(isActive: true))
                            .shadow(color: palette.calendarCellShadow, radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(day.isWithinDisplayedMonth ? palette.calendarCellFill : palette.calendarCellInactiveFill)
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
                .foregroundStyle(palette.primaryInk)
                .padding(.bottom, LayoutSpacing.titleBottom)

            if let entry = entry {
                entryDetailContent(for: entry)
            } else {
                emptyJournalView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.detailPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(palette.detailPanelStroke, lineWidth: 1)
        )
        .shadow(color: palette.entryShadow, radius: 18, x: 0, y: 10)
    }

    @ViewBuilder
    private func entryDetailContent(for entry: JournalEntry) -> some View {
        VStack(spacing: 18) {
            ForEach(prompts, id: \.id) { prompt in
                let raw = entry.responses[prompt.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let display = raw.isEmpty ? "当日未留下文字。" : raw

                VStack(alignment: .leading, spacing: 0) {
                    Text(prompt.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.primaryInk)
                        .padding(.bottom, LayoutSpacing.titleBottom)

                    Text(Typography.bodyAttributed(display))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.secondaryInk)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(palette.detailCardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(palette.detailCardStroke, lineWidth: 1)
                )
            }
        }
    }

    private func emptyJournalView() -> some View {
        VStack(spacing: 20) {
            Image("JournalEmpty")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .cornerRadius(28)
                .shadow(color: palette.entryShadow, radius: 14, x: 0, y: 10)

            Text("暂无日志")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.primaryInk)

            Text(Typography.bodyAttributed("别担心，每一天都是新的开始。从今天起，让我们一起记录美好吧！"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(palette.tertiaryInk)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.emptyCardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(palette.detailCardStroke, lineWidth: 1)
        )
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
