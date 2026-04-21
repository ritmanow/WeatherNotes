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
            return "OpenWeather API key is missing."
        case .invalidURL:
            return "Could not build a valid weather request URL."
        case .network(let urlError):
            return urlError.localizedDescription
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let statusCode, _):
            return "Weather request failed (HTTP \(statusCode))."
        case .decodingFailed:
            return "Could not read the weather response."
        case .missingWeatherPayload:
            return "The weather response did not include weather details."
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
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
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
}
