import Combine
import CoreData
import CoreLocation
import Foundation

@MainActor
final class AddNoteViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var weatherSourceHint = ""

    private let weather: WeatherServicing
    private let locationService: LocationService
    private let repository: WeatherNoteRepository

    init(
        context _: NSManagedObjectContext,
        weather: WeatherServicing,
        locationService: LocationService,
        repository: WeatherNoteRepository
    ) {
        self.weather = weather
        self.locationService = locationService
        self.repository = repository
    }

    func save(trimmedText: String) async {
        guard !trimmedText.isEmpty else { return }

        isSaving = true
        errorMessage = nil
        weatherSourceHint = ""

        defer {
            isSaving = false
            weatherSourceHint = ""
        }

        do {
            let coord = await locationService.requestCoordinateOrNil()

            let snapshot: WeatherSnapshot
            if let coord = coord, coord.latitude.isFinite, coord.longitude.isFinite {
                weatherSourceHint = "Буде використано вашу геолокацію"
                snapshot = try await weather.fetchCurrentWeather(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            } else {
                weatherSourceHint = "Геолокація недоступна, використовуємо Київ"
                snapshot = try await weather.fetchCurrentWeather(cityQuery: "Kyiv,UA")
            }

            try repository.save(text: trimmedText, weather: snapshot)
        } catch {
            errorMessage = ukrainianUserMessage(for: error)
        }
    }

    private func ukrainianUserMessage(for error: Error) -> String {
        if let weather = error as? WeatherServiceError {
            return weather.errorDescription ?? "Не вдалося отримати погоду."
        }
        let ns = error as NSError
        if ns.domain == NSCocoaErrorDomain {
            return "Не вдалося зберегти нотатку. Спробуйте ще раз."
        }
        return "Сталася помилка. Спробуйте ще раз."
    }
}
