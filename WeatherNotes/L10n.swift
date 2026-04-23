import Foundation

enum L10n {
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .main)
    }

    static func format(_ key: String.LocalizationValue, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: .autoupdatingCurrent, arguments: arguments)
    }
}
