import Foundation

protocol WeatherServicing {
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot
    func fetchCurrentWeather(cityQuery: String) async throws -> WeatherSnapshot
}
