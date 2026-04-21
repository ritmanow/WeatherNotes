import Foundation

/// Domain snapshot of current weather. `visibilityKm` is 0 when the API omits `visibility` (meters).
struct WeatherSnapshot: Equatable {
    var temperature: Int
    var feelsLike: Int
    var weatherDescription: String
    var weatherMain: String
    var owmIconId: String
    var humidity: Int
    var pressure: Int
    var visibilityKm: Int
    var clouds: Int
    var windSpeed: Double
    var windDirection: Double
    var locationDisplay: String
    var latitude: Double
    var longitude: Double
}
