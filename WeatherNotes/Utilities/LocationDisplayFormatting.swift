import Foundation

/// Replaces trailing ISO-3166 alpha-2 country codes with Ukrainian names when the UI is Ukrainian.
enum LocationDisplayFormatting {
    static func displayString(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return raw }

        guard Locale.current.language.languageCode?.identifier == "uk" else { return raw }

        guard let comma = trimmed.lastIndex(of: ",") else { return raw }
        let head = trimmed[..<comma].trimmingCharacters(in: .whitespaces)
        let tail = trimmed[trimmed.index(after: comma)...].trimmingCharacters(in: .whitespaces)
        guard tail.count == 2, tail == tail.uppercased() else { return raw }
        let code = tail.uppercased()
        guard let country = iso2Ukrainian[code] else { return raw }
        return "\(head), \(country)"
    }

    private static let iso2Ukrainian: [String: String] = [
        "UA": "Україна",
        "US": "США",
        "GB": "Велика Британія",
        "CA": "Канада",
        "DE": "Німеччина",
        "FR": "Франція",
        "PL": "Польща",
        "IT": "Італія",
        "ES": "Іспанія",
        "PT": "Португалія",
        "NL": "Нідерланди",
        "BE": "Бельгія",
        "CH": "Швейцарія",
        "AT": "Австрія",
        "CZ": "Чехія",
        "SK": "Словаччина",
        "HU": "Угорщина",
        "RO": "Румунія",
        "MD": "Молдова",
        "BG": "Болгарія",
        "GR": "Греція",
        "TR": "Туреччина",
        "SE": "Швеція",
        "NO": "Норвегія",
        "FI": "Фінляндія",
        "DK": "Данія",
        "IE": "Ірландія",
        "IS": "Ісландія",
        "EE": "Естонія",
        "LV": "Латвія",
        "LT": "Литва",
        "JP": "Японія",
        "CN": "Китай",
        "KR": "Південна Корея",
        "IN": "Індія",
        "AU": "Австралія",
        "NZ": "Нова Зеландія",
        "BR": "Бразилія",
        "AR": "Аргентина",
        "MX": "Мексика",
        "EG": "Єгипет",
        "ZA": "ПАР",
        "AE": "ОАЕ",
        "SA": "Саудівська Аравія",
        "IL": "Ізраїль",
        "GE": "Грузія",
        "AM": "Вірменія",
        "AZ": "Азербайджан",
        "KZ": "Казахстан",
        "BY": "Білорусь",
        "RS": "Сербія",
        "HR": "Хорватія",
        "SI": "Словенія",
        "BA": "Боснія і Герцеговина",
        "MK": "Північна Македонія",
        "AL": "Албанія",
        "ME": "Чорногорія",
        "LU": "Люксембург",
        "MT": "Мальта",
        "CY": "Кіпр",
        "UK": "Велика Британія",
    ]
}
