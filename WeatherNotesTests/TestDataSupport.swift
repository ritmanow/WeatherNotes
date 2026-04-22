import CoreData
import Foundation
@testable import WeatherNotes

enum TestDataSupport {
    static func inMemoryViewContext() throws -> NSManagedObjectContext {
        let bundle = Bundle(for: WeatherNote.self)
        guard let modelURL = bundle.url(forResource: "WeatherNotes", withExtension: "momd") else {
            throw NSError(domain: "WeatherNotesTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing WeatherNotes.momd"])
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw NSError(domain: "WeatherNotesTests", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not load model"])
        }
        let container = NSPersistentContainer(name: "InMemoryWeatherNotesTests", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError { throw loadError }
        return container.viewContext
    }

    @discardableResult
    static func insertSampleNote(
        context: NSManagedObjectContext,
        weatherDescription: String = "легкий дощ",
        weatherMain: String = "rain",
        windDirection: Double = 182.4
    ) throws -> WeatherNote {
        let note = WeatherNote(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.text = "Test note"
        note.temperature = 12
        note.feelsLike = 11
        note.weatherDescription = weatherDescription
        note.weatherMain = weatherMain
        note.owmIconId = "10d"
        note.humidity = 80
        note.pressure = 1000
        note.visibilityKm = 8
        note.clouds = 90
        note.windSpeed = 4.2
        note.windDirection = windDirection
        note.locationDisplay = "Kyiv, UA"
        note.latitude = 50.45
        note.longitude = 30.52
        try context.save()
        return note
    }
}
