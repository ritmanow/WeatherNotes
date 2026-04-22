import SwiftUI

// MARK: - DetailScreen palette (Figma light 1:378 / 1:496, dark 1:616 / 1:734)

private enum DetailColors {
    static func canvas(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
            : Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
    }

    static func navBar(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color.white
    }

    static func cardFill(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color.white
    }

    static func cardBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
    }

    static func primaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
    }

    static func secondaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255)
    }

    static func metricLabel(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func metaBullet(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
            : Color(red: 209 / 255, green: 213 / 255, blue: 220 / 255)
    }

    static func accentBlue(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 21 / 255, green: 93 / 255, blue: 252 / 255)
            : Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }

    static func cardShadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.1)
    }

    static func coordinatesBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
            : Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
    }

    // Icon wells (Figma dark uses translucent tints)
    static func humidityWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 28 / 255, green: 57 / 255, blue: 142 / 255).opacity(0.3)
            : Color(red: 239 / 255, green: 246 / 255, blue: 255 / 255)
    }

    static func visibilityWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 89 / 255, green: 22 / 255, blue: 139 / 255).opacity(0.3)
            : Color(red: 250 / 255, green: 245 / 255, blue: 255 / 255)
    }

    static func pressureWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 126 / 255, green: 42 / 255, blue: 12 / 255).opacity(0.3)
            : Color(red: 255 / 255, green: 247 / 255, blue: 237 / 255)
    }

    static func cloudsWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
    }

    static func windWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 11 / 255, green: 79 / 255, blue: 74 / 255).opacity(0.3)
            : Color(red: 240 / 255, green: 253 / 255, blue: 250 / 255)
    }

    /// SF Symbol on metric / wind wells: colored in light, white in dark (Figma).
    static func metricIconForeground(
        _ scheme: ColorScheme,
        lightAccent: Color
    ) -> Color {
        scheme == .dark ? Color.white : lightAccent
    }

    static let humidityAccent = Color(red: 43 / 255, green: 127 / 255, blue: 255 / 255)
    static let visibilityAccent = Color(red: 147 / 255, green: 51 / 255, blue: 234 / 255)
    static let pressureAccent = Color(red: 234 / 255, green: 88 / 255, blue: 12 / 255)
    static let cloudsAccent = Color(red: 107 / 255, green: 114 / 255, blue: 128 / 255)
    static let windAccent = Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255)
}

struct NoteDetailView: View {
    @Environment(\.colorScheme) private var colorScheme

    let note: WeatherNote

    private let metricColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                noteCard
                weatherHeroCard
                metricsGrid
                windCard
                coordinatesStrip
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(DetailColors.canvas(colorScheme))
        .navigationTitle(L10n.string("note_detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DetailColors.navBar(colorScheme), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(DetailColors.accentBlue(colorScheme))
    }

    // MARK: - Cards

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(note.text ?? "")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(DetailColors.primaryText(colorScheme))
                .tracking(0.07)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let createdAt = note.createdAt {
                noteMetaRow(date: createdAt)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(detailCardChrome(cornerRadius: 16))
    }

    private func noteMetaRow(date: Date) -> some View {
        HStack(spacing: 8) {
            Text(noteMetaLeading(date: date))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DetailColors.secondaryText(colorScheme))
                .tracking(-0.15)
            Text("•")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DetailColors.metaBullet(colorScheme))
                .tracking(-0.15)
            Text(noteMetaTime(date: date))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DetailColors.secondaryText(colorScheme))
                .tracking(-0.15)
        }
    }

    private var weatherHeroCard: some View {
        let style = heroStyle(for: note.weatherMain ?? "")
        let loc = LocationDisplayFormatting.displayString(note.locationDisplay ?? "—")
        let condition = WeatherConditionDisplay.phrase(
            apiDescription: note.weatherDescription ?? "",
            weatherMain: note.weatherMain ?? ""
        )
        let feels = safeIntDegrees(note.feelsLike)

        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 20, weight: .medium))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.white.opacity(0.95))
                    Text(loc)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .tracking(-0.31)
                        .lineLimit(2)
                }
                .padding(.bottom, 16)

                Text("\(safeIntDegrees(note.temperature))°")
                    .font(.system(size: 72, weight: .light))
                    .tracking(0.12)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)

                Text(condition)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white.opacity(0.95))
                    .tracking(-0.45)
                    .padding(.top, 4)

                Text(L10n.format("note_detail.hero.feels_like_format", feels as CVarArg))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(-0.31)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: style.symbolName)
                .font(.system(size: 120, weight: .regular))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.white.opacity(0.9))
                .offset(x: 4, y: 8)
                .accessibilityHidden(true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(style.gradient)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: metricColumns, spacing: 12) {
            metricTile(
                title: L10n.string("note_detail.metric.humidity"),
                mainValue: "\(note.humidity)",
                unit: "%",
                systemImage: "humidity",
                iconWell: DetailColors.humidityWell(colorScheme),
                iconAccent: DetailColors.humidityAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.visibility"),
                mainValue: visibilityMainText(note.visibilityKm),
                unit: visibilityUnitText(note.visibilityKm),
                systemImage: "eye",
                iconWell: DetailColors.visibilityWell(colorScheme),
                iconAccent: DetailColors.visibilityAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.pressure"),
                mainValue: "\(note.pressure)",
                unit: L10n.string("note_detail.metric.pressure.unit"),
                systemImage: "gauge.with.dots.needle.67percent",
                iconWell: DetailColors.pressureWell(colorScheme),
                iconAccent: DetailColors.pressureAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.clouds"),
                mainValue: "\(note.clouds)",
                unit: "%",
                systemImage: "cloud",
                iconWell: DetailColors.cloudsWell(colorScheme),
                iconAccent: DetailColors.cloudsAccent
            )
        }
    }

    private var windCard: some View {
        let deg = note.windDirection
        let cardinal = WindDirection.cardinalSymbol(degrees: deg)
        let speed = note.windSpeed.finiteOrZero

        return VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(DetailColors.windWell(colorScheme))
                        .frame(width: 48, height: 48)
                    Image(systemName: "wind")
                        .font(.system(size: 22, weight: .medium))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(DetailColors.metricIconForeground(colorScheme, lightAccent: DetailColors.windAccent))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.string("note_detail.wind.title"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DetailColors.primaryText(colorScheme))
                        .tracking(-0.44)
                    Text(L10n.string("note_detail.wind.subtitle"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DetailColors.secondaryText(colorScheme))
                        .tracking(-0.15)
                }
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.string("note_detail.wind.speed_label"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DetailColors.secondaryText(colorScheme))
                        .tracking(-0.15)
                    windValueLine(main: String(format: "%.1f", speed), unit: L10n.string("note_detail.wind.speed.unit"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(L10n.string("note_detail.wind.direction_label"))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(DetailColors.secondaryText(colorScheme))
                            .tracking(-0.15)
                        windDirectionValue(degrees: deg, cardinal: cardinal)
                    }
                    windCompass(degrees: deg)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(detailCardChrome(cornerRadius: 16))
    }

    private var coordinatesStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.string("note_detail.coordinates.title"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DetailColors.secondaryText(colorScheme))
            HStack {
                coordinateInline(label: L10n.string("note_detail.coordinates.latitude"), value: formatCoordDegrees(note.latitude))
                Spacer(minLength: 16)
                coordinateInline(label: L10n.string("note_detail.coordinates.longitude"), value: formatCoordDegrees(note.longitude))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: coordinatesGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DetailColors.coordinatesBorder(colorScheme), lineWidth: 0.67)
                )
        )
    }

    private var coordinatesGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255),
                Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255),
            ]
        }
        return [
            Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255),
            Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255),
        ]
    }

    // MARK: - Subviews / chrome

    private func detailCardChrome(cornerRadius: CGFloat) -> some View {
        let shadow = DetailColors.cardShadow(colorScheme)
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DetailColors.cardFill(colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DetailColors.cardBorder(colorScheme), lineWidth: 0.67)
            )
            .shadow(color: shadow, radius: 1, x: 0, y: 1)
            .shadow(color: shadow, radius: 2, x: 0, y: 1)
    }

    private func metricTile(
        title: String,
        mainValue: String,
        unit: String,
        systemImage: String,
        iconWell: Color,
        iconAccent: Color
    ) -> some View {
        let iconFg = DetailColors.metricIconForeground(colorScheme, lightAccent: iconAccent)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconWell)
                        .frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(iconFg)
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DetailColors.metricLabel(colorScheme))
                    .tracking(-0.15)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            metricValueText(main: mainValue, unit: unit)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(detailCardChrome(cornerRadius: 16))
    }

    private func metricValueText(main: String, unit: String) -> Text {
        let mainFont = Font.system(size: 30, weight: .semibold)
        let unitFont = Font.system(size: 18, weight: .semibold)
        let fg = DetailColors.primaryText(colorScheme)
        if unit == "%" {
            return Text(main + unit)
                .font(mainFont)
                .foregroundStyle(fg)
                .tracking(0.4)
                .monospacedDigit()
        }
        if unit.isEmpty {
            return Text(main)
                .font(mainFont)
                .foregroundStyle(fg)
                .tracking(0.4)
                .monospacedDigit()
        }
        return Text(main)
            .font(mainFont)
            .foregroundStyle(fg)
            .tracking(0.4)
            .monospacedDigit()
            + Text(unit)
            .font(unitFont)
            .foregroundStyle(fg)
            .tracking(-0.44)
    }

    private func windValueLine(main: String, unit: String) -> some View {
        let fg = DetailColors.primaryText(colorScheme)
        return (Text(main)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(fg)
            .tracking(0.4)
            .monospacedDigit()
            + Text(unit)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(fg)
            .tracking(-0.44))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    /// Figma: direction column shows cardinal (e.g. ENE) prominently.
    private func windDirectionValue(degrees: Double, cardinal: String) -> some View {
        Group {
            if degrees.isFinite {
                Text(cardinal)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DetailColors.primaryText(colorScheme))
                    .tracking(0.07)
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DetailColors.primaryText(colorScheme))
            }
        }
        .multilineTextAlignment(.trailing)
    }

    private func windCompass(degrees: Double) -> some View {
        ZStack {
            Circle()
                .fill(DetailColors.windWell(colorScheme))
                .frame(width: 48, height: 48)
            Image(systemName: "location.north.line")
                .font(.system(size: 22, weight: .medium))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(DetailColors.metricIconForeground(colorScheme, lightAccent: DetailColors.windAccent))
                .rotationEffect(.degrees(degrees.isFinite ? degrees : 0))
                .accessibilityLabel(L10n.string("note_detail.wind_compass.accessibility"))
        }
    }

    private func coordinateInline(label: String, value: String) -> some View {
        (Text("\(label): ")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(DetailColors.metricLabel(colorScheme))
            .tracking(-0.15)
            + Text(value)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(DetailColors.primaryText(colorScheme)))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    private func heroStyle(for weatherMain: String) -> (gradient: LinearGradient, symbolName: String) {
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
            return (grayMistHeroGradient, "cloud")
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
            return (grayMistHeroGradient, "cloud.fog")
        default:
            return (grayMistHeroGradient, "cloud.sun")
        }
    }

    private var grayMistHeroGradient: LinearGradient {
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

    // MARK: - Formatting (existing guards)

    private func visibilityMainText(_ km: Double) -> String {
        let v = km.finiteOrZero
        if v <= 0 { return "—" }
        return String(format: "%.0f", v)
    }

    private func visibilityUnitText(_ km: Double) -> String {
        let v = km.finiteOrZero
        if v <= 0 { return "" }
        return L10n.string("note_detail.metric.visibility.unit")
    }

    private func formatCoordDegrees(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        return String(format: "%.4f°", value)
    }

    private func safeIntDegrees(_ value: Double) -> Int {
        guard value.isFinite else { return 0 }
        return Int(value.rounded())
    }

    private func noteMetaLeading(date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return L10n.string("common.relative.today") }
        if cal.isDateInYesterday(date) { return L10n.string("common.relative.yesterday") }
        return date.formatted(.dateTime.day().month(.wide))
    }

    private func noteMetaTime(date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened))
    }
}
