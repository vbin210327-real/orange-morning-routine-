import Foundation
import Combine

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var responses: [String: String]

    init(id: UUID = UUID(), date: Date, responses: [String: String]) {
        self.id = id
        self.date = date
        self.responses = responses
    }
}

final class JournalStore: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ??
        fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("journal_entries.json")

        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        load()
    }

    func entry(for date: Date) -> JournalEntry? {
        let day = Calendar.current.startOfDay(for: date)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    func saveEntry(for date: Date, responses: [String: String]) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            entries[index].responses = responses
            entries[index].date = day
        } else {
            entries.append(JournalEntry(date: day, responses: responses))
        }
        persist()
    }

    func sortedEntries() -> [JournalEntry] {
        entries.sorted { $0.date > $1.date }
    }

    #if DEBUG
    func deleteEntry(for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: day) }
        persist()
    }
    #endif

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode([JournalEntry].self, from: data)
            entries = decoded
        } catch {
            print("Failed to load journal entries:", error)
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save journal entries:", error)
        }
    }
}
