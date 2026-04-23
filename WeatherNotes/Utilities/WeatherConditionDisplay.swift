import Foundation

/// Maps OpenWeather `description` (often literal machine Ukrainian) to natural phrases.
/// Storage still keeps the API string; this is **display-only**.
enum WeatherConditionDisplay {
    static func phrase(apiDescription: String, weatherMain: String) -> String {
        let raw = apiDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty {
            let main = weatherMain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if main.isEmpty { return "—" }
            return phraseFromMainOnly(weatherMain)
        }

        let token = Self.normalizedToken(raw)
        let slug = Self.aliasToSlug[token] ?? Self.slugify(token)
        let lang = Locale.current.language.languageCode?.identifier ?? "uk"
        let main = weatherMain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if lang == "en" {
            if let p = phrasesEN[slug] { return p }
            if let p = mainFallbackEN[main] { return p }
            return Self.titleCaseEnglish(raw)
        }

        if let p = phrasesUK[slug] { return p }
        if let p = mainFallbackUK[main] { return p }
        return raw.capitalized(with: Locale(identifier: "uk_UA"))
    }

    private static func phraseFromMainOnly(_ weatherMain: String) -> String {
        let main = weatherMain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedMain = weatherMain.trimmingCharacters(in: .whitespacesAndNewlines)
        let lang = Locale.current.language.languageCode?.identifier ?? "uk"
        if lang == "en" {
            return mainFallbackEN[main] ?? trimmedMain.capitalized(with: .current)
        }
        return mainFallbackUK[main] ?? trimmedMain.capitalized(with: Locale(identifier: "uk_UA"))
    }

    private static func normalizedToken(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "`", with: "'")
            .replacingOccurrences(of: " +", with: " ", options: .regularExpression)
    }

    private static func slugify(_ token: String) -> String {
        token.replacingOccurrences(of: " ", with: "_")
    }

    private static func titleCaseEnglish(_ raw: String) -> String {
        raw.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
            .capitalized(with: .current)
    }

    /// Maps normalized API text (English or Ukrainian) to a stable slug.
    private static let aliasToSlug: [String: String] = {
        var m: [String: String] = [:]
        func a(_ phrases: [String], _ slug: String) {
            for p in phrases {
                m[Self.normalizedToken(p)] = slug
            }
        }

        a(["clear sky", "ясне небо", "ясно"], "clear_sky")
        a(["few clouds", "мало хмар", "малохмарно"], "few_clouds")
        a([
            "scattered clouds",
            "розсіяні хмари",
            "розірвані хмари",
            "мінлива хмарність",
            "уривчасті хмари",
            "уривчаста хмарність",
            "переміжна хмарність",
        ], "scattered_clouds")
        a([
            "broken clouds",
            "рвані хмари",
            "рвана хмара",
            "хмарно з проясненнями",
        ], "broken_clouds")
        a([
            "overcast clouds",
            "overcast",
            "суцільна хмарність",
            "похмура хмарність",
            "суцільні хмари",
        ], "overcast_clouds")

        a(["light rain", "легкий дощ", "невеликий дощ"], "light_rain")
        a(["moderate rain", "помірний дощ", "дощ"], "moderate_rain")
        a(["heavy intensity rain", "сильний дощ", "злива"], "heavy_rain")
        a(["very heavy rain", "дуже сильний дощ"], "very_heavy_rain")
        a(["extreme rain", "надзвичайно сильний дощ"], "extreme_rain")
        a(["freezing rain", "ожеледь", "крижаний дощ"], "freezing_rain")
        a(["light intensity shower rain", "невеликий зливаючий дощ"], "light_shower_rain")
        a(["shower rain", "зливаючий дощ", "злива"], "shower_rain")
        a(["heavy intensity shower rain", "сильний зливаючий дощ"], "heavy_shower_rain")
        a(["ragged shower rain", "нерівномірний зливаючий дощ"], "ragged_shower_rain")

        a(["light intensity drizzle", "легка морось"], "light_drizzle")
        a(["drizzle", "морось", "мряка"], "drizzle")
        a(["heavy intensity drizzle", "сильна морось"], "heavy_drizzle")

        a(["thunderstorm with light rain", "гроза з невеликим дощем"], "thunderstorm_light_rain")
        a(["thunderstorm with rain", "гроза з дощем"], "thunderstorm_rain")
        a(["thunderstorm with heavy rain", "гроза з сильним дощем"], "thunderstorm_heavy_rain")
        a(["light thunderstorm", "легка гроза"], "light_thunderstorm")
        a(["thunderstorm", "гроза"], "thunderstorm")
        a(["heavy thunderstorm", "сильна гроза"], "heavy_thunderstorm")
        a(["ragged thunderstorm", "розріджена гроза"], "ragged_thunderstorm")

        a(["light snow", "легкий сніг"], "light_snow")
        a(["snow", "сніг"], "snow")
        a(["heavy snow", "сильний сніг"], "heavy_snow")
        a(["sleet", "мокрий сніг", "дощ зі снігом"], "sleet")
        a(["shower sleet", "злива з мокрим снігом"], "shower_sleet")
        a(["light rain and snow", "дощ і сніг"], "rain_and_snow")

        a(["mist", "імла", "легкий туман"], "mist")
        a(["fog", "туман", "густий туман"], "fog")
        a(["haze", "димка", "смог"], "haze")
        a(["smoke", "дим"], "smoke")
        a(["sand", "пісок"], "sand")
        a(["dust", "пил"], "dust")
        a(["volcanic ash", "вулканічний попіл"], "volcanic_ash")
        a(["squalls", "шквали"], "squalls")
        a(["tornado", "торнадо", "смерч"], "tornado")

        return m
    }()

    private static let phrasesUK: [String: String] = [
        "clear_sky": "Ясно",
        "few_clouds": "Малохмарно",
        "scattered_clouds": "Мінлива хмарність",
        "broken_clouds": "Хмарно з проясненнями",
        "overcast_clouds": "Похмуро",

        "light_rain": "Невеликий дощ",
        "moderate_rain": "Дощ",
        "heavy_rain": "Сильний дощ",
        "very_heavy_rain": "Дуже сильний дощ",
        "extreme_rain": "Надзвичайно сильний дощ",
        "freezing_rain": "Крижаний дощ",
        "light_shower_rain": "Невеликий зливаючий дощ",
        "shower_rain": "Зливаючий дощ",
        "heavy_shower_rain": "Сильний зливаючий дощ",
        "ragged_shower_rain": "Нерівномірний зливаючий дощ",

        "light_drizzle": "Легка морось",
        "drizzle": "Морось",
        "heavy_drizzle": "Сильна морось",

        "thunderstorm_light_rain": "Гроза з невеликим дощем",
        "thunderstorm_rain": "Гроза з дощем",
        "thunderstorm_heavy_rain": "Гроза з сильним дощем",
        "light_thunderstorm": "Невелика гроза",
        "thunderstorm": "Гроза",
        "heavy_thunderstorm": "Сильна гроза",
        "ragged_thunderstorm": "Розріджена гроза",

        "light_snow": "Невеликий сніг",
        "snow": "Сніг",
        "heavy_snow": "Сильний сніг",
        "sleet": "Мокрий сніг",
        "shower_sleet": "Злива з мокрим снігом",
        "rain_and_snow": "Дощ і сніг",

        "mist": "Туман",
        "fog": "Густий туман",
        "haze": "Димка",
        "smoke": "Дим",
        "sand": "Пісок у повітрі",
        "dust": "Пил",
        "volcanic_ash": "Вулканічний попіл",
        "squalls": "Шквали",
        "tornado": "Смерч",
    ]

    private static let phrasesEN: [String: String] = [
        "clear_sky": "Clear",
        "few_clouds": "Mostly clear",
        "scattered_clouds": "Partly cloudy",
        "broken_clouds": "Mostly cloudy",
        "overcast_clouds": "Overcast",

        "light_rain": "Light rain",
        "moderate_rain": "Rain",
        "heavy_rain": "Heavy rain",
        "very_heavy_rain": "Very heavy rain",
        "extreme_rain": "Extreme rain",
        "freezing_rain": "Freezing rain",
        "light_shower_rain": "Light showers",
        "shower_rain": "Showers",
        "heavy_shower_rain": "Heavy showers",
        "ragged_shower_rain": "Showers",

        "light_drizzle": "Light drizzle",
        "drizzle": "Drizzle",
        "heavy_drizzle": "Heavy drizzle",

        "thunderstorm_light_rain": "Thunderstorm with light rain",
        "thunderstorm_rain": "Thunderstorm with rain",
        "thunderstorm_heavy_rain": "Thunderstorm with heavy rain",
        "light_thunderstorm": "Light thunderstorm",
        "thunderstorm": "Thunderstorm",
        "heavy_thunderstorm": "Heavy thunderstorm",
        "ragged_thunderstorm": "Thunderstorm",

        "light_snow": "Light snow",
        "snow": "Snow",
        "heavy_snow": "Heavy snow",
        "sleet": "Sleet",
        "shower_sleet": "Sleet showers",
        "rain_and_snow": "Rain and snow",

        "mist": "Mist",
        "fog": "Fog",
        "haze": "Haze",
        "smoke": "Smoke",
        "sand": "Sand",
        "dust": "Dust",
        "volcanic_ash": "Volcanic ash",
        "squalls": "Squalls",
        "tornado": "Tornado",
    ]

    private static let mainFallbackUK: [String: String] = [
        "clear": "Ясно",
        "clouds": "Хмарно",
        "rain": "Дощ",
        "drizzle": "Морось",
        "thunderstorm": "Гроза",
        "snow": "Сніг",
        "mist": "Туман",
        "smoke": "Дим",
        "haze": "Димка",
        "fog": "Туман",
        "dust": "Пил",
        "sand": "Пісок",
        "ash": "Попіл",
        "squall": "Шквал",
        "tornado": "Смерч",
    ]

    private static let mainFallbackEN: [String: String] = [
        "clear": "Clear",
        "clouds": "Cloudy",
        "rain": "Rain",
        "drizzle": "Drizzle",
        "thunderstorm": "Thunderstorm",
        "snow": "Snow",
        "mist": "Mist",
        "smoke": "Smoke",
        "haze": "Haze",
        "fog": "Fog",
        "dust": "Dust",
        "sand": "Sand",
        "ash": "Ash",
        "squall": "Squall",
        "tornado": "Tornado",
    ]
}
