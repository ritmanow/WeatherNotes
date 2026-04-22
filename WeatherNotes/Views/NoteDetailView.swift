import SwiftUI

struct NoteDetailView: View {
    let note: WeatherNote

    private let metricColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    /// Design tokens (Figma DetailScreen 1:380 — light baseline; cards use system background for dark mode).
    private enum Tok {
        static let canvas = Color(uiColor: .systemGroupedBackground)
        static let primaryText = Color.primary
        static let label = Color(uiColor: .secondaryLabel)
        static let meta = Color.secondary
        static let bullet = Color(uiColor: .tertiaryLabel)
        static let cardBorder = Color(uiColor: .separator).opacity(0.35)
        static let stripBorder = Color(uiColor: .separator)
        static let humidityTint = Color(red: 239 / 255, green: 246 / 255, blue: 255 / 255)
        static let visibilityTint = Color(red: 250 / 255, green: 245 / 255, blue: 255 / 255)
        static let pressureTint = Color(red: 255 / 255, green: 247 / 255, blue: 237 / 255)
        static let cloudsTint = Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
        static let windTint = Color(red: 240 / 255, green: 253 / 255, blue: 250 / 255)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                noteCard
                weatherHeroCard
                metricsGrid
                windCard
                coordinatesStrip
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Tok.canvas)
        .navigationTitle("Деталі нотатки")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Cards

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(note.text ?? "")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Tok.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let createdAt = note.createdAt {
                noteMetaRow(date: createdAt)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(whiteCardChrome(cornerRadius: 16))
    }

    private func noteMetaRow(date: Date) -> some View {
        HStack(spacing: 8) {
            Text(noteMetaLeading(date: date))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Tok.meta)
            Text("•")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Tok.bullet)
            Text(noteMetaTime(date: date))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Tok.meta)
        }
    }

    private var weatherHeroCard: some View {
        let style = heroStyle(for: note.weatherMain ?? "")
        let loc = note.locationDisplay ?? "—"
        let condition = (note.weatherDescription ?? "—").capitalized
        let feels = safeIntDegrees(note.feelsLike)

        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.95))
                    Text(loc)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
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
                    .padding(.top, 4)

                Text("Відчувається як \(feels)°")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: style.symbolName)
                .font(.system(size: 88))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.88))
                .offset(x: 4, y: 8)
                .accessibilityHidden(true)
        }
        .padding(20)
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
                title: "Вологість",
                mainValue: "\(note.humidity)",
                unit: "%",
                systemImage: "humidity.fill",
                iconTint: Tok.humidityTint,
                iconColor: Color(red: 43 / 255, green: 127 / 255, blue: 255 / 255)
            )
            metricTile(
                title: "Видимість",
                mainValue: visibilityMainText(note.visibilityKm),
                unit: visibilityUnitText(note.visibilityKm),
                systemImage: "eye.fill",
                iconTint: Tok.visibilityTint,
                iconColor: Color(red: 147 / 255, green: 51 / 255, blue: 234 / 255)
            )
            metricTile(
                title: "Тиск",
                mainValue: "\(note.pressure)",
                unit: " гПа",
                systemImage: "gauge.with.dots.needle.67percent",
                iconTint: Tok.pressureTint,
                iconColor: Color(red: 234 / 255, green: 88 / 255, blue: 12 / 255)
            )
            metricTile(
                title: "Хмарність",
                mainValue: "\(note.clouds)",
                unit: "%",
                systemImage: "cloud.fill",
                iconTint: Tok.cloudsTint,
                iconColor: Color(red: 107 / 255, green: 114 / 255, blue: 128 / 255)
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
                        .fill(Tok.windTint)
                        .frame(width: 48, height: 48)
                    Image(systemName: "wind")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Вітер")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Tok.primaryText)
                    Text("Швидкість і напрямок")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Tok.meta)
                }
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Швидкість")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Tok.meta)
                    windValueLine(main: String(format: "%.1f", speed), unit: "м/с")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Напрямок")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Tok.meta)
                        windDirectionValue(degrees: deg, cardinal: cardinal)
                    }
                    windCompass(degrees: deg)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(whiteCardChrome(cornerRadius: 16))
    }

    private var coordinatesStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Координати локації")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Tok.meta)
            HStack {
                coordinateInline(label: "Широта", value: formatCoordDegrees(note.latitude))
                Spacer(minLength: 16)
                coordinateInline(label: "Довгота", value: formatCoordDegrees(note.longitude))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(uiColor: .secondarySystemBackground),
                            Color(uiColor: .tertiarySystemBackground),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Tok.stripBorder, lineWidth: 1)
                )
        )
    }

    // MARK: - Subviews / chrome

    private func whiteCardChrome(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Tok.cardBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 1.5, x: 0, y: 1)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func metricTile(
        title: String,
        mainValue: String,
        unit: String,
        systemImage: String,
        iconTint: Color,
        iconColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconTint)
                        .frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(iconColor)
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Tok.label)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            metricValueText(main: mainValue, unit: unit)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(whiteCardChrome(cornerRadius: 16))
    }

    private func metricValueText(main: String, unit: String) -> Text {
        let mainFont = Font.system(size: 30, weight: .semibold)
        let unitFont = Font.system(size: 18, weight: .semibold)
        if unit == "%" {
            return Text(main + unit)
                .font(mainFont)
                .foregroundStyle(Tok.primaryText)
                .monospacedDigit()
        }
        if unit.isEmpty {
            return Text(main)
                .font(mainFont)
                .foregroundStyle(Tok.primaryText)
                .monospacedDigit()
        }
        return Text(main)
            .font(mainFont)
            .foregroundStyle(Tok.primaryText)
            .monospacedDigit()
        + Text(unit)
            .font(unitFont)
            .foregroundStyle(Tok.primaryText)
    }

    private func windValueLine(main: String, unit: String) -> some View {
        (Text(main)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(Tok.primaryText)
            .monospacedDigit()
        + Text(unit)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Tok.primaryText))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    private func windDirectionValue(degrees: Double, cardinal: String) -> some View {
        Group {
            if degrees.isFinite {
                (Text("\(safeIntDegrees(degrees))°")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Tok.primaryText)
                    .monospacedDigit()
                + Text(" · ")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Tok.meta)
                + Text(cardinal)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Tok.primaryText))
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Tok.primaryText)
            }
        }
        .multilineTextAlignment(.trailing)
    }

    private func windCompass(degrees: Double) -> some View {
        ZStack {
            Circle()
                .fill(Tok.windTint)
                .frame(width: 48, height: 48)
            Image(systemName: "location.north.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255))
                .rotationEffect(.degrees(degrees.isFinite ? degrees : 0))
                .accessibilityLabel("Напрямок вітру")
        }
    }

    private func coordinateInline(label: String, value: String) -> some View {
        (Text("\(label): ")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Tok.label)
        + Text(value)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(Tok.primaryText))
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
                "sun.max.fill"
            )
        case "clouds":
            return (grayMistHeroGradient, "cloud.fill")
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
                "cloud.rain.fill"
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
                "cloud.bolt.rain.fill"
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
                "cloud.snow.fill"
            )
        case "mist", "fog", "haze":
            return (grayMistHeroGradient, "cloud.fog.fill")
        default:
            return (grayMistHeroGradient, "cloud.sun.fill")
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
        return " км"
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
        if cal.isDateInToday(date) { return "Сьогодні" }
        if cal.isDateInYesterday(date) { return "Вчора" }
        return date.formatted(.dateTime.day().month(.wide))
    }

    private func noteMetaTime(date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened))
    }
}
