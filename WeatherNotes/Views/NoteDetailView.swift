import CoreData
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
    @StateObject private var viewModel: NoteDetailViewModel

    private let metricColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    init(note: WeatherNote) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(note: note))
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

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.noteText)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(DetailColors.primaryText(colorScheme))
                .tracking(0.07)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let createdAt = viewModel.note.createdAt {
                noteMetaRow(date: createdAt)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(detailCardChrome(cornerRadius: 16))
    }

    private func noteMetaRow(date: Date) -> some View {
        HStack(spacing: 8) {
            Text(viewModel.noteMetaLeading(for: date))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DetailColors.secondaryText(colorScheme))
                .tracking(-0.15)
            Text("•")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DetailColors.metaBullet(colorScheme))
                .tracking(-0.15)
            Text(viewModel.noteMetaTime(for: date))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DetailColors.secondaryText(colorScheme))
                .tracking(-0.15)
        }
    }

    private var weatherHeroCard: some View {
        let style = viewModel.heroStyle(for: viewModel.note.weatherMain ?? "")
        let loc = viewModel.locationDisplayFormatted
        let apiDescription = viewModel.heroWeatherDescription
        let conditionDisplay = apiDescription.isEmpty ? "—" : apiDescription
        let feels = viewModel.feelsLike

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

                Text("\(viewModel.heroTemperature)°")
                    .font(.system(size: 72, weight: .light))
                    .tracking(0.12)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)

                Text(conditionDisplay)
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
                mainValue: "\(viewModel.note.humidity)",
                unit: "%",
                systemImage: "humidity",
                iconWell: DetailColors.humidityWell(colorScheme),
                iconAccent: DetailColors.humidityAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.visibility"),
                mainValue: viewModel.visibilityMainText(),
                unit: viewModel.visibilityUnitText(),
                systemImage: "eye",
                iconWell: DetailColors.visibilityWell(colorScheme),
                iconAccent: DetailColors.visibilityAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.pressure"),
                mainValue: "\(viewModel.note.pressure)",
                unit: L10n.string("note_detail.metric.pressure.unit"),
                systemImage: "gauge.with.dots.needle.67percent",
                iconWell: DetailColors.pressureWell(colorScheme),
                iconAccent: DetailColors.pressureAccent
            )
            metricTile(
                title: L10n.string("note_detail.metric.clouds"),
                mainValue: "\(viewModel.note.clouds)",
                unit: "%",
                systemImage: "cloud",
                iconWell: DetailColors.cloudsWell(colorScheme),
                iconAccent: DetailColors.cloudsAccent
            )
        }
    }

    private var windCard: some View {
        let deg = viewModel.note.windDirection
        let cardinal = viewModel.windCardinalSymbol()
        let degreeLabel = viewModel.windDirectionDegreesText()

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
                    windValueLine(main: viewModel.windSpeedFormatted(), unit: L10n.string("note_detail.wind.speed.unit"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(L10n.string("note_detail.wind.direction_label"))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(DetailColors.secondaryText(colorScheme))
                            .tracking(-0.15)
                        windDirectionColumn(degrees: deg, degreeLabel: degreeLabel, cardinal: cardinal)
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
                coordinateInline(
                    label: L10n.string("note_detail.coordinates.latitude"),
                    value: viewModel.formatCoordDegrees(viewModel.note.latitude)
                )
                Spacer(minLength: 16)
                coordinateInline(
                    label: L10n.string("note_detail.coordinates.longitude"),
                    value: viewModel.formatCoordDegrees(viewModel.note.longitude)
                )
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

    private func windDirectionColumn(degrees: Double, degreeLabel: String, cardinal: String) -> some View {
        Group {
            if degrees.isFinite {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(degreeLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DetailColors.secondaryText(colorScheme))
                        .tracking(-0.15)
                    Text(cardinal)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(DetailColors.primaryText(colorScheme))
                        .tracking(0.07)
                }
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
}
