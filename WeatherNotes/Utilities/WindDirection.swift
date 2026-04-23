import Foundation

enum WindDirection {
    /// Eight main wind directions (0° = N, clockwise), labels from String Catalog (`wind.octant.*`).
    static func cardinalSymbol(degrees: Double) -> String {
        guard degrees.isFinite else { return "—" }
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let octant = Int((normalized + 22.5) / 45.0) % 8
        switch octant {
        case 0: return L10n.string("wind.octant.n")
        case 1: return L10n.string("wind.octant.ne")
        case 2: return L10n.string("wind.octant.e")
        case 3: return L10n.string("wind.octant.se")
        case 4: return L10n.string("wind.octant.s")
        case 5: return L10n.string("wind.octant.sw")
        case 6: return L10n.string("wind.octant.w")
        case 7: return L10n.string("wind.octant.nw")
        default: return L10n.string("wind.octant.n")
        }
    }
}
