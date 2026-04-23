import CoreData
import Foundation
import SwiftUI

/// Snapshot-driven copy and formatting for the note detail screen (OpenWeather fields as stored in Core Data).
@MainActor
final class NoteDetailViewModel: ObservableObject {
    let note: WeatherNote

    init(note: WeatherNote) {
        self.note = note
    }

    var noteText: String { note.text ?? "" }

    var locationDisplayFormatted: String {
        LocationDisplayFormatting.displayString(note.locationDisplay ?? "—")
    }

    /// Hero condition line: mapped for natural Ukrainian/English; raw API text remains in Core Data for mapping.
    var heroWeatherDescription: String {
        WeatherConditionDisplay.phrase(
            apiDescription: note.weatherDescription ?? "",
            weatherMain: note.weatherMain ?? ""
        )
    }

    var heroTemperature: Int {
        safeIntDegrees(note.temperature)
    }

    var feelsLike: Int {
        safeIntDegrees(note.feelsLike)
    }

    func noteMetaLeading(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return L10n.string("common.relative.today") }
        if cal.isDateInYesterday(date) { return L10n.string("common.relative.yesterday") }
        return date.formatted(.dateTime.day().month(.wide))
    }

    func noteMetaTime(for date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened))
    }

    func visibilityMainText() -> String {
        let v = note.visibilityKm.finiteOrZero
        if v <= 0 { return "—" }
        return String(format: "%.0f", v)
    }

    func visibilityUnitText() -> String {
        let v = note.visibilityKm.finiteOrZero
        if v <= 0 { return "" }
        return L10n.string("note_detail.metric.visibility.unit")
    }

    func formatCoordDegrees(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        return String(format: "%.4f°", value)
    }

    func windSpeedFormatted() -> String {
        String(format: "%.1f", note.windSpeed.finiteOrZero)
    }

    /// Numeric wind direction in degrees (OpenWeather `wind.deg`), for display next to the cardinal label.
    func windDirectionDegreesText() -> String {
        let deg = note.windDirection
        guard deg.isFinite else { return "—" }
        let normalized = (deg.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return String(format: "%.0f°", normalized)
    }

    func windCardinalSymbol() -> String {
        WindDirection.cardinalSymbol(degrees: note.windDirection)
    }

    func heroStyle(for weatherMain: String) -> (gradient: LinearGradient, symbolName: String) {
        switch weatherMain.lowercased() {
        case "clear":
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.55, blue: 0.95),
                        Color(red: 0.98, green: 0.75, blue: 0.35),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "sun.max"
            )
        case "clouds":
            return (Self.grayMistHeroGradient, "cloud")
        case "rain", "drizzle":
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.22, green: 0.35, blue: 0.52),
                        Color(red: 0.38, green: 0.42, blue: 0.48),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.rain"
            )
        case "thunderstorm":
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.22, blue: 0.45),
                        Color(red: 0.45, green: 0.35, blue: 0.55),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.bolt.rain"
            )
        case "snow":
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.72, blue: 0.88),
                        Color(red: 0.88, green: 0.92, blue: 0.96),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.snow"
            )
        case "mist", "fog", "haze":
            return (Self.grayMistHeroGradient, "cloud.fog")
        default:
            return (Self.grayMistHeroGradient, "cloud.sun")
        }
    }

    private static var grayMistHeroGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 209 / 255, green: 213 / 255, blue: 220 / 255), location: 0),
                .init(color: Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255), location: 0.5),
                .init(color: Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255), location: 1),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func safeIntDegrees(_ value: Double) -> Int {
        guard value.isFinite else { return 0 }
        return Int(value.rounded())
    }
}
