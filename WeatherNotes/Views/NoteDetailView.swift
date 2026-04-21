import SwiftUI

struct NoteDetailView: View {
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
                coordinatesCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Нотатка")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Cards

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.text ?? "")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let createdAt = note.createdAt {
                Text(createdAt, format: Date.FormatStyle(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("Локація: \(note.locationDisplay ?? "—")")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var weatherHeroCard: some View {
        let style = heroStyle(for: note.weatherMain ?? "")
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Погода")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(note.weatherDescription ?? "—")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 8)
                Image(systemName: style.symbolName)
                    .font(.system(size: 40))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.95))
            }
            HStack(alignment: .firstTextBaseline, spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Температура")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(safeIntDegrees(note.temperature))°C")
                        .font(.title.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Відчувається як")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(safeIntDegrees(note.feelsLike))°C")
                        .font(.title3.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(style.gradient)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: metricColumns, spacing: 12) {
            metricTile(
                title: "Вологість",
                value: "\(note.humidity)%",
                systemImage: "humidity.fill"
            )
            metricTile(
                title: "Видимість",
                value: formatVisibility(note.visibilityKm),
                systemImage: "eye.fill"
            )
            metricTile(
                title: "Тиск",
                value: "\(note.pressure) hPa",
                systemImage: "gauge.with.dots.needle.67percent"
            )
            metricTile(
                title: "Хмарність",
                value: "\(note.clouds)%",
                systemImage: "cloud.fill"
            )
        }
    }

    private var windCard: some View {
        let deg = note.windDirection
        let cardinal = WindDirection.cardinalSymbol(degrees: deg)
        return VStack(alignment: .leading, spacing: 12) {
            Label("Вітер", systemImage: "wind")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Швидкість")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f м/с", note.windSpeed.finiteOrZero))
                        .font(.body.monospacedDigit().weight(.medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Напрямок")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(safeIntDegrees(deg))° · \(cardinal)")
                        .font(.body.monospacedDigit().weight(.medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var coordinatesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Координати")
                .font(.subheadline.weight(.semibold))
            HStack(spacing: 16) {
                coordinatePill(label: "Широта", value: formatCoord(note.latitude))
                coordinatePill(label: "Довгота", value: formatCoord(note.longitude))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Subviews / style

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
    }

    private func metricTile(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(cardBackground)
    }

    private func coordinatePill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.monospacedDigit().weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.45, green: 0.52, blue: 0.62),
                        Color(red: 0.32, green: 0.38, blue: 0.48),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.fill"
            )
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
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.58, blue: 0.60),
                        Color(red: 0.40, green: 0.42, blue: 0.44),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.fog.fill"
            )
        default:
            return (
                LinearGradient(
                    colors: [
                        Color(red: 0.40, green: 0.48, blue: 0.62),
                        Color(red: 0.55, green: 0.60, blue: 0.72),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                "cloud.sun.fill"
            )
        }
    }

    // MARK: - Formatting (existing guards)

    private func formatVisibility(_ km: Double) -> String {
        let v = km.finiteOrZero
        if v <= 0 { return "—" }
        return String(format: "%.0f км", v)
    }

    private func safeIntDegrees(_ value: Double) -> Int {
        guard value.isFinite else { return 0 }
        return Int(value.rounded())
    }

    private func formatCoord(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        return String(format: "%.4f", value)
    }
}
