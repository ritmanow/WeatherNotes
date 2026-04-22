import Combine
import CoreData
import CoreLocation
import Foundation

@MainActor
final class AddNoteViewModel: ObservableObject {
    private enum SaveFlowError: LocalizedError {
        case weatherTimeout

        var errorDescription: String? {
            switch self {
            case .weatherTimeout:
                return L10n.string("add_note.save_flow.weather_timeout")
            }
        }
    }

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

    /// Bold location segment in the info card; follows `weatherSourceHint` during save, else defaults to Kyiv.
    var infoCardLocationHighlight: String {
        if !weatherSourceHint.isEmpty {
            if weatherSourceHint.contains(L10n.string("add_note.weather_source.substring.kyiv")) {
                return L10n.string("add_note.location.highlight.kyiv")
            }
            if weatherSourceHint.contains(L10n.string("add_note.weather_source.substring.geolocation")) {
                return L10n.string("add_note.location.highlight.current")
            }
        }
        return L10n.string("add_note.location.highlight.kyiv")
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
                weatherSourceHint = L10n.string("add_note.weather_source.current_location")
                snapshot = try await fetchWeatherWithTimeout {
                    try await self.weather.fetchCurrentWeather(
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                }
            } else {
                weatherSourceHint = L10n.string("add_note.weather_source.fallback_kyiv")
                snapshot = try await fetchWeatherWithTimeout {
                    try await self.weather.fetchCurrentWeather(cityQuery: "Kyiv,UA")
                }
            }

            try repository.save(text: trimmedText, weather: snapshot)
        } catch {
            errorMessage = ukrainianUserMessage(for: error)
        }
    }

    private func ukrainianUserMessage(for error: Error) -> String {
        if let weather = error as? WeatherServiceError {
            return weather.errorDescription ?? L10n.string("add_note.error.weather_fallback")
        }
        let ns = error as NSError
        if ns.domain == NSCocoaErrorDomain {
            return L10n.string("add_note.error.save_failed")
        }
        return L10n.string("add_note.error.generic")
    }

    private func fetchWeatherWithTimeout(
        timeoutSeconds: TimeInterval = 12,
        operation: @escaping () async throws -> WeatherSnapshot
    ) async throws -> WeatherSnapshot {
        try await withThrowingTaskGroup(of: WeatherSnapshot.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                let nanoseconds = UInt64(timeoutSeconds * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)
                throw SaveFlowError.weatherTimeout
            }

            defer { group.cancelAll() }
            guard let first = try await group.next() else {
                throw SaveFlowError.weatherTimeout
            }
            return first
        }
    }
}
