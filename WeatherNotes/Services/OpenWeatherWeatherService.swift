import Foundation

enum WeatherServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case network(URLError)
    case invalidResponse
    case httpError(statusCode: Int, body: String?)
    case decodingFailed(Error)
    case missingWeatherPayload

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return L10n.string("weather_service.error.missing_api_key")
        case .invalidURL:
            return L10n.string("weather_service.error.invalid_url")
        case .network(let urlError):
            return Self.ukrainianMessage(for: urlError)
        case .invalidResponse:
            return L10n.string("weather_service.error.invalid_response")
        case .httpError(let statusCode, _):
            return L10n.format("weather_service.error.http_status_format", statusCode as CVarArg)
        case .decodingFailed:
            return L10n.string("weather_service.error.decoding_failed")
        case .missingWeatherPayload:
            return L10n.string("weather_service.error.missing_payload")
        }
    }

    private static func ukrainianMessage(for urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet:
            return L10n.string("weather_service.error.network.offline")
        case .timedOut:
            return L10n.string("weather_service.error.network.timeout")
        case .cannotFindHost, .dnsLookupFailed:
            return L10n.string("weather_service.error.network.host_not_found")
        case .networkConnectionLost, .dataNotAllowed:
            return L10n.string("weather_service.error.network.connection_lost")
        case .secureConnectionFailed:
            return L10n.string("weather_service.error.network.secure_connection_failed")
        case .cancelled:
            return L10n.string("weather_service.error.network.cancelled")
        default:
            return L10n.string("weather_service.error.network.generic")
        }
    }

    var failureReason: String? {
        switch self {
        case .httpError(_, let body):
            return body
        case .decodingFailed(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

final class OpenWeatherWeatherService: WeatherServicing {
    private static let baseURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 12
            configuration.timeoutIntervalForResource = 20
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = JSONDecoder()
    }

    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot {
        try await performRequest(queryItems: [
            URLQueryItem(name: "lat", value: formatCoordinate(latitude)),
            URLQueryItem(name: "lon", value: formatCoordinate(longitude)),
        ])
    }

    func fetchCurrentWeather(cityQuery: String) async throws -> WeatherSnapshot {
        try await performRequest(queryItems: [
            URLQueryItem(name: "q", value: cityQuery),
        ])
    }

    private func performRequest(queryItems: [URLQueryItem]) async throws -> WeatherSnapshot {
        let key = OpenWeatherAPIKey.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw WeatherServiceError.missingAPIKey }

        var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
        var items = queryItems
        items.append(URLQueryItem(name: "units", value: "metric"))
        items.append(URLQueryItem(name: "lang", value: Self.openWeatherLanguageCode()))
        items.append(URLQueryItem(name: "appid", value: key))
        components?.queryItems = items

        guard let url = components?.url else { throw WeatherServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw WeatherServiceError.network(error)
        } catch {
            throw error
        }

        guard let http = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        let bodyString = String(data: data, encoding: .utf8)

        guard (200...299).contains(http.statusCode) else {
            throw WeatherServiceError.httpError(statusCode: http.statusCode, body: bodyString)
        }

        let decoded: OpenWeatherCurrentResponse
        do {
            decoded = try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
        } catch {
            throw WeatherServiceError.decodingFailed(error)
        }

        guard let first = decoded.weather.first else {
            throw WeatherServiceError.missingWeatherPayload
        }

        return mapSnapshot(response: decoded, firstWeather: first)
    }

    private func mapSnapshot(
        response: OpenWeatherCurrentResponse,
        firstWeather: OpenWeatherCurrentResponse.WeatherElement
    ) -> WeatherSnapshot {
        let visibilityKm: Int
        if let meters = response.visibility {
            visibilityKm = Int((Double(meters) / 1000.0).rounded())
        } else {
            visibilityKm = 0
        }

        let rawWind = response.wind?.speed?.finiteOrZero ?? 0
        let windSpeed = ((rawWind * 10).rounded() / 10).finiteOrZero
        let windDirection = response.wind?.deg?.finiteOrZero ?? 0

        let country = response.sys.country?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let locationDisplay: String
        if country.isEmpty {
            locationDisplay = response.name
        } else {
            locationDisplay = "\(response.name), \(country)"
        }

        let temp = response.main.temp.finiteOrZero
        let feels = response.main.feelsLike.finiteOrZero
        let lat = response.coord.lat.finiteOrZero
        let lon = response.coord.lon.finiteOrZero

        return WeatherSnapshot(
            temperature: Int(temp.rounded()),
            feelsLike: Int(feels.rounded()),
            weatherDescription: firstWeather.description,
            weatherMain: firstWeather.main.lowercased(),
            owmIconId: firstWeather.icon,
            humidity: response.main.humidity,
            pressure: response.main.pressure,
            visibilityKm: visibilityKm,
            clouds: response.clouds.all,
            windSpeed: windSpeed,
            windDirection: windDirection,
            locationDisplay: locationDisplay,
            latitude: lat,
            longitude: lon
        )
    }

    private func formatCoordinate(_ value: Double) -> String {
        String(format: "%.6f", value)
    }

    /// OpenWeather `lang` parameter aligned with the user’s primary UI language (`en` vs `uk`).
    private static func openWeatherLanguageCode() -> String {
        Locale.current.language.languageCode?.identifier == "en" ? "en" : "uk"
    }
}
