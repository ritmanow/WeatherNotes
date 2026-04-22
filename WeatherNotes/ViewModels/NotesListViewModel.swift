import Combine
import CoreData
import Foundation

/// Owns list data (`NSFetchedResultsController`) and presentation logic for the notes list.
@MainActor
final class NotesListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published private(set) var notes: [WeatherNote] = []

    private let viewContext: NSManagedObjectContext
    private let fetchController: NSFetchedResultsController<WeatherNote>

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        let request = NSFetchRequest<WeatherNote>(entityName: "WeatherNote")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeatherNote.createdAt, ascending: false)]
        fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
        } catch {
            notes = []
        }
        refreshPublishedNotes()
    }

    private func refreshPublishedNotes() {
        notes = fetchController.fetchedObjects ?? []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        refreshPublishedNotes()
    }

    var isEmpty: Bool { notes.isEmpty }

    func delete(_ note: WeatherNote) {
        viewContext.delete(note)
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }

    /// Natural Ukrainian/English condition line for the list (API string is mapped in `WeatherConditionDisplay`; storage unchanged).
    func listConditionLine(for note: WeatherNote) -> String {
        WeatherConditionDisplay.phrase(
            apiDescription: note.weatherDescription ?? "",
            weatherMain: note.weatherMain ?? ""
        )
    }

    func listTemperature(for note: WeatherNote) -> Int {
        let t = note.temperature
        guard t.isFinite else { return 0 }
        return Int(t.rounded())
    }

    func symbolName(for weatherMain: String) -> String {
        switch weatherMain.lowercased() {
        case "clear": return "sun.max"
        case "clouds": return "cloud"
        case "rain": return "cloud.rain"
        case "drizzle": return "cloud.drizzle"
        case "thunderstorm": return "cloud.bolt.rain"
        case "snow": return "cloud.snow"
        case "mist", "fog", "haze": return "cloud.fog"
        case "smoke", "dust", "sand", "ash", "squall", "tornado": return "wind"
        default: return "cloud.sun"
        }
    }

    func relativeDayLabel(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return L10n.string("common.relative.today") }
        if cal.isDateInYesterday(date) { return L10n.string("common.relative.yesterday") }
        return date.formatted(
            .dateTime.day().month(.abbreviated)
                .locale(.autoupdatingCurrent)
        )
    }

    func timePortion(for date: Date) -> String {
        date.formatted(
            .dateTime.hour().minute()
                .locale(.autoupdatingCurrent)
        )
    }

    func noteCountSubtitle(for count: Int) -> String {
        Self.noteCountSubtitle(forCount: count)
    }

    /// Pure pluralization for tests and UI.
    static func noteCountSubtitle(forCount count: Int) -> String {
        let lang = Locale.current.language.languageCode?.identifier ?? "uk"
        let word: String
        if lang == "en" {
            word = (count == 1)
                ? L10n.string("notes_list.count.note.one")
                : L10n.string("notes_list.count.note.many")
        } else {
            let n10 = count % 10
            let n100 = count % 100
            if (11 ... 14).contains(n100) {
                word = L10n.string("notes_list.count.note.many")
            } else if n10 == 1 {
                word = L10n.string("notes_list.count.note.one")
            } else if (2 ... 4).contains(n10) {
                word = L10n.string("notes_list.count.note.few")
            } else {
                word = L10n.string("notes_list.count.note.many")
            }
        }
        return "\(count) \(word)"
    }
}
