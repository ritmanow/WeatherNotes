import SwiftUI

enum ThemePreference: String, CaseIterable {
    case system
    case light
    case dark

    /// Persisted in `UserDefaults` via `@AppStorage`.
    static let storageKey = "weatherNotes.colorSchemePreference"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var toolbarIconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .system: L10n.string("theme.accessibility.system")
        case .light: L10n.string("theme.accessibility.light")
        case .dark: L10n.string("theme.accessibility.dark")
        }
    }

    func next() -> ThemePreference {
        let cases = Self.allCases
        let i = cases.firstIndex(of: self) ?? 0
        return cases[(i + 1) % cases.count]
    }
}
