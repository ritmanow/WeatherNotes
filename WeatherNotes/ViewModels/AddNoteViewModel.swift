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
                snapshot = try await fetchWeatherSnapshotWithTimeout(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            } else {
                weatherSourceHint = "Геолокація недоступна, використовуємо Київ"
                snapshot = try await fetchWeatherSnapshotWithTimeout(cityQuery: "Kyiv,UA")
            }

            try repository.save(text: trimmedText, weather: snapshot)
        } catch {
            if let urlError = error as? URLError, urlError.code == .timedOut {
                errorMessage = "Не вдалося отримати погоду вчасно. Перевірте мережу та спробуйте ще раз."
            } else {
                errorMessage = ukrainianUserMessage(for: error)
            }
        }
    }

    /// Hard cap so a stuck OpenWeather request cannot block the save flow indefinitely (URLSession timeouts are a second layer).
    private func fetchWeatherSnapshotWithTimeout(
        latitude: Double,
        longitude: Double,
        timeoutSeconds: TimeInterval = 12
    ) async throws -> WeatherSnapshot {
        try await fetchWeatherSnapshotWithTimeout(
            timeoutSeconds: timeoutSeconds,
            operation: { try await self.weather.fetchCurrentWeather(latitude: latitude, longitude: longitude) }
        )
    }

    private func fetchWeatherSnapshotWithTimeout(
        cityQuery: String,
        timeoutSeconds: TimeInterval = 12
    ) async throws -> WeatherSnapshot {
        try await fetchWeatherSnapshotWithTimeout(
            timeoutSeconds: timeoutSeconds,
            operation: { try await self.weather.fetchCurrentWeather(cityQuery: cityQuery) }
        )
    }

    private func fetchWeatherSnapshotWithTimeout(
        timeoutSeconds: TimeInterval,
        operation: @escaping () async throws -> WeatherSnapshot
    ) async throws -> WeatherSnapshot {
        try await withThrowingTaskGroup(of: WeatherSnapshot.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                let nanoseconds = UInt64(timeoutSeconds * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)
                throw URLError(.timedOut)
            }
            guard let snapshot = try await group.next() else {
                throw URLError(.unknown)
            }
            group.cancelAll()
            return snapshot
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
