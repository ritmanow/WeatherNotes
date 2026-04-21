import Foundation

enum WindDirection {
    /// 16-point compass labels (N, NNE, NE, …) from meteorological degrees (0° = N, clockwise).
    static func cardinalSymbol(degrees: Double) -> String {
        guard degrees.isFinite else { return "—" }
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let rose = [
            "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW",
        ]
        let index = Int((normalized + 11.25) / 22.5) % 16
        return rose[index]
    }
}
