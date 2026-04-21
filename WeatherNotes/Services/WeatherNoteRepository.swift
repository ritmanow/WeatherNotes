import CoreData
import Foundation

/// Persists weather notes. Callers should use a context bound to the main queue (e.g. `viewContext`) so work aligns with `@MainActor`.
@MainActor
final class WeatherNoteRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Creates a `WeatherNote`, inserts it into `context` via `WeatherNote(context:)`, and saves so the write is committed before return.
    func save(text: String, weather snapshot: WeatherSnapshot) throws {
        let note = WeatherNote(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.text = text
        note.temperature = Double(snapshot.temperature).finiteOrZero
        note.feelsLike = Double(snapshot.feelsLike).finiteOrZero
        note.weatherDescription = snapshot.weatherDescription
        note.weatherMain = snapshot.weatherMain
        note.owmIconId = snapshot.owmIconId
        note.humidity = Int32(snapshot.humidity)
        note.pressure = Int32(snapshot.pressure)
        note.visibilityKm = Double(snapshot.visibilityKm).finiteOrZero
        note.clouds = Int32(snapshot.clouds)
        note.windSpeed = snapshot.windSpeed.finiteOrZero
        note.windDirection = snapshot.windDirection.finiteOrZero
        note.locationDisplay = snapshot.locationDisplay
        note.latitude = snapshot.latitude.finiteOrZero
        note.longitude = snapshot.longitude.finiteOrZero
        try context.save()
    }
}
