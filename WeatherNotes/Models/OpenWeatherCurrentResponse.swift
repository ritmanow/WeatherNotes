import Foundation

struct OpenWeatherCurrentResponse: Decodable {
    let coord: Coord
    let weather: [WeatherElement]
    let main: Main
    let wind: Wind?
    let clouds: Clouds
    let visibility: Int?
    let name: String
    let sys: Sys

    struct Coord: Decodable {
        let lon: Double
        let lat: Double
    }

    struct WeatherElement: Decodable {
        let main: String
        let description: String
        let icon: String
    }

    struct Main: Decodable {
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case pressure
            case humidity
        }
    }

    struct Wind: Decodable {
        let speed: Double?
        let deg: Double?
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct Sys: Decodable {
        let country: String?
    }
}
