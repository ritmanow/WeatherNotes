import CoreData
import SwiftUI

// MARK: - Figma AddNote (node 1:163) design tokens (SF Pro, ~393pt canvas)

private enum AddNoteStyle {
    static let pageBG = Color(uiColor: .systemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textMuted = Color(uiColor: .tertiaryLabel)
    static let labelGray = Color(uiColor: .label)
    static let borderLight = Color(uiColor: .separator).opacity(0.35)
    static let borderHeader = Color(uiColor: .separator)
    static let primaryBlue = Color(red: 0.169, green: 0.498, blue: 1) // #2b7fff
    static let pinCircle = Color(red: 0.86, green: 0.918, blue: 0.996) // #dbeafe
    static let infoBorder = Color(red: 0.86, green: 0.918, blue: 0.996) // #dbeafe
    static let infoDivider = Color(red: 0.745, green: 0.86, blue: 1) // #bedbff
    static let tipsBG = Color(red: 0.95, green: 0.95, blue: 0.96) // #f3f4f6
    static let gradientStart = Color(red: 0.937, green: 0.965, blue: 1) // #eff6ff
    static let gradientEnd = Color(red: 0.933, green: 0.949, blue: 1) // #eef2ff
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: AddNoteViewModel
    @State private var text = ""
    @FocusState private var isTextEditorFocused: Bool

    private let onSaved: () -> Void

    private let maxLength = 200

    init(context: NSManagedObjectContext, onSaved: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: AddNoteViewModel(
                context: context,
                weather: OpenWeatherWeatherService(),
                locationService: .shared,
                repository: WeatherNoteRepository(context: context)
            )
        )
        self.onSaved = onSaved
    }

    private var boundedNoteText: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                text = String(newValue.prefix(maxLength))
            }
        )
    }

    private var isDarkMode: Bool { colorScheme == .dark }

    var body: some View {
        VStack(spacing: 0) {
            addNoteHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isSaving {
                        HStack(alignment: .center, spacing: 12) {
                            ProgressView()
                            Text("Отримуємо погоду та зберігаємо...")
                                .font(.subheadline)
                                .foregroundStyle(AddNoteStyle.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    inputCard
                    if let message = viewModel.errorMessage, !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2)
                    }
                    infoCard
                    tipsCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            saveFooter
        }
        .background(AddNoteStyle.pageBG.ignoresSafeArea())
    }

    // MARK: - Header (back + title, white bar, bottom border, shadow)

    private var addNoteHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AddNoteStyle.primaryBlue)
                }
                .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Назад")

            Text("Нова нотатка")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(AddNoteStyle.textPrimary)
                .tracking(-0.45)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AddNoteStyle.borderHeader)
                .frame(height: 0.5)
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    // MARK: - Input card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Що ви робили?")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(AddNoteStyle.textSecondary)
                .tracking(-0.15)

            ZStack(alignment: .topLeading) {
                TextEditor(text: boundedNoteText)
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundStyle(AddNoteStyle.textPrimary)
                    .textInputAutocapitalization(.sentences)
                    .focused($isTextEditorFocused)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .accessibilityLabel("Нотатка")
                    .contentShape(Rectangle())
                if text.isEmpty {
                    Text("напр. пробіжка, дорога в офіс, прогулянка у парку…")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundStyle(AddNoteStyle.textMuted)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                isTextEditorFocused = true
            }
            HStack {
                Text("\(text.count)/\(maxLength)")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(AddNoteStyle.textMuted)
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AddNoteStyle.borderLight, lineWidth: 0.67)
        )
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    // MARK: - Info card (gradient, pin, dynamic highlight)

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AddNoteStyle.pinCircle)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AddNoteStyle.primaryBlue)
                }
                .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Автоматичний знімок погоди")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundStyle(infoCardTextColor)
                        .tracking(-0.15)
                    infoCardBodyText
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Rectangle()
                .fill(AddNoteStyle.infoDivider)
                .frame(height: 0.5)
            infoBulletGrid
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: infoGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(infoCardBorderColor, lineWidth: 0.67)
        )
    }

    private var infoCardBodyText: Text {
        let h = viewModel.infoCardLocationHighlight
        let body = Text("Погодні дані для ")
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundStyle(infoCardSecondaryTextColor)
        let mid = Text(h)
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundStyle(infoCardTextColor)
        let tail = Text(" будуть отримано та збережено разом з нотаткою.")
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundStyle(infoCardSecondaryTextColor)
        return body + mid + tail
    }

    private var infoBulletGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(infoGridRows, id: \.self) { row in
                infoRow(row)
            }
        }
    }

    private var infoGridRows: [String] {
        [
            "Температура та умови",
            "Вологість і тиск",
            "Швидкість і напрям вітру",
            "Видимість і хмарність",
        ]
    }

    private func infoRow(_ label: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AddNoteStyle.primaryBlue)
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(infoCardSecondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Tips card

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("💡")
                Text("Підказки")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AddNoteStyle.labelGray)
            }
            VStack(alignment: .leading, spacing: 6) {
                tipsLine("•", "Опишіть свою активність детальніше")
                tipsLine("•", "Погодні дані знімаються в момент збереження")
                tipsLine("•", "Нотатки зберігаються на вашому пристрої")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    private func tipsLine(_ bullet: String, _ line: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(bullet)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(AddNoteStyle.textMuted)
            Text(line)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(AddNoteStyle.textSecondary)
        }
    }

    // MARK: - Footer (save, disabled opacity 0.5)

    private var saveFooter: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AddNoteStyle.borderHeader)
                .frame(height: 0.5)
            Button {
                Task {
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let payload = String(trimmed.prefix(maxLength))
                    await viewModel.save(trimmedText: payload)
                    if viewModel.errorMessage == nil {
                        onSaved()
                        dismiss()
                    }
                }
            } label: {
                Text("Зберегти")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AddNoteStyle.primaryBlue)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .opacity(saveButtonEnabled && !viewModel.isSaving ? 1 : 0.5)
            .disabled(!saveButtonEnabled || viewModel.isSaving)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
    }

    private var saveButtonEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var infoGradientColors: [Color] {
        if isDarkMode {
            return [
                Color(red: 0.18, green: 0.23, blue: 0.33),
                Color(red: 0.15, green: 0.20, blue: 0.29),
            ]
        }
        return [AddNoteStyle.gradientStart, AddNoteStyle.gradientEnd]
    }

    private var infoCardBorderColor: Color {
        isDarkMode ? Color.white.opacity(0.15) : AddNoteStyle.infoBorder
    }

    private var infoCardTextColor: Color {
        isDarkMode ? .white : AddNoteStyle.textPrimary
    }

    private var infoCardSecondaryTextColor: Color {
        isDarkMode ? .white.opacity(0.85) : AddNoteStyle.textSecondary
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    AddNoteView(context: persistence.container.viewContext) {}
}
