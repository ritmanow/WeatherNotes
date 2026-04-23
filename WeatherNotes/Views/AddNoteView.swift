import CoreData
import SwiftUI

// MARK: - AddNoteScreen palette (Figma light 1:161 / 1:233 / 1:305, dark 1:853 / 1:925 / 1:997)

private enum AddNoteColors {
    static func canvas(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
            : Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
    }

    static func headerBar(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color.white
    }

    static func headerDivider(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
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

    static func activityFieldLabel(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func placeholder(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255)
            : Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
    }

    static func characterCount(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255)
            : Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
    }

    static func secondaryLabel(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255)
    }

    static func tipsTitle(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 209 / 255, green: 213 / 255, blue: 220 / 255)
            : Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
    }

    static func tipsBody(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func tipsBullet(_ scheme: ColorScheme) -> Color {
        Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
    }

    static func tipsCardBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
    }

    static func accentBlue(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 21 / 255, green: 93 / 255, blue: 252 / 255)
            : Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }

    /// Save CTA: light #2b7fff — dark #155dfc.
    static func saveButtonFill(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 21 / 255, green: 93 / 255, blue: 252 / 255)
            : Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }

    static func cardShadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.1)
    }

    static func infoGradient(_ scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [
                Color(red: 28 / 255, green: 57 / 255, blue: 142 / 255).opacity(0.2),
                Color(red: 49 / 255, green: 44 / 255, blue: 133 / 255).opacity(0.2),
            ]
        }
        return [
            Color(red: 239 / 255, green: 246 / 255, blue: 255 / 255),
            Color(red: 238 / 255, green: 242 / 255, blue: 255 / 255),
        ]
    }

    static func infoCardBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 25 / 255, green: 60 / 255, blue: 184 / 255)
            : Color(red: 219 / 255, green: 234 / 255, blue: 254 / 255)
    }

    static func infoDivider(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 25 / 255, green: 60 / 255, blue: 184 / 255)
            : Color(red: 190 / 255, green: 219 / 255, blue: 255 / 255)
    }

    static func infoPinWell(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 25 / 255, green: 60 / 255, blue: 184 / 255).opacity(0.5)
            : Color(red: 219 / 255, green: 234 / 255, blue: 254 / 255)
    }

    static func infoPinIcon(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }

    static func infoTitle(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
    }

    static func infoBodySecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func infoBodyEmphasis(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
    }

    static func infoBulletLabel(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func bulletDot(_ scheme: ColorScheme) -> Color {
        Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @AppStorage(ThemePreference.storageKey) private var themeRaw = ThemePreference.system.rawValue

    @StateObject private var viewModel: AddNoteViewModel
    @State private var text = ""
    @State private var isErrorAlertPresented = false
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

    private var themePreference: ThemePreference {
        ThemePreference(rawValue: themeRaw) ?? .system
    }

    /// Aligns with the in-app theme toggle; sheets do not always inherit `preferredColorScheme` from the presenter (visible as wrong sheet chrome on some devices).
    private var colorScheme: ColorScheme {
        switch themePreference {
        case .system: systemColorScheme
        case .light: .light
        case .dark: .dark
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            AddNoteColors.canvas(colorScheme)
                .ignoresSafeArea(edges: .all)
            VStack(spacing: 0) {
                addNoteHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.isSaving {
                            HStack(alignment: .center, spacing: 12) {
                                ProgressView()
                                Text(L10n.string("add_note.loading"))
                                    .font(.subheadline)
                                    .foregroundStyle(AddNoteColors.secondaryLabel(colorScheme))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        inputCard
                        infoCard
                        tipsCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
                saveFooter
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .preferredColorScheme(themePreference.colorScheme)
        .onChange(of: viewModel.errorMessage) { _, newValue in
            isErrorAlertPresented = newValue != nil && !newValue!.isEmpty
        }
        .alert(
            L10n.string("add_note.error.alert_title"),
            isPresented: $isErrorAlertPresented
        ) {
            Button(L10n.string("common.action.ok"), role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header (back + title, Figma bar + divider + shadow)

    private var addNoteHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AddNoteColors.accentBlue(colorScheme))
                }
                .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("common.accessibility.back"))

            Text(L10n.string("add_note.title"))
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(AddNoteColors.primaryText(colorScheme))
                .tracking(-0.45)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AddNoteColors.headerBar(colorScheme))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AddNoteColors.headerDivider(colorScheme))
                .frame(height: 0.5)
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    // MARK: - Input card

    private var inputCard: some View {
        let shadow = AddNoteColors.cardShadow(colorScheme)
        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.string("add_note.field.activity_label"))
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(AddNoteColors.activityFieldLabel(colorScheme))
                .tracking(-0.15)

            ZStack(alignment: .topLeading) {
                TextEditor(text: boundedNoteText)
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundStyle(AddNoteColors.primaryText(colorScheme))
                    .tracking(-0.44)
                    .textInputAutocapitalization(.sentences)
                    .focused($isTextEditorFocused)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .accessibilityLabel(L10n.string("add_note.field.note.accessibility"))
                    .contentShape(Rectangle())
                if text.isEmpty {
                    Text(L10n.string("add_note.field.note.placeholder"))
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundStyle(AddNoteColors.placeholder(colorScheme))
                        .tracking(-0.44)
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
                    .foregroundStyle(AddNoteColors.characterCount(colorScheme))
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AddNoteColors.cardFill(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AddNoteColors.cardBorder(colorScheme), lineWidth: 0.67)
        )
        .shadow(color: shadow, radius: 1, x: 0, y: 1)
        .shadow(color: shadow, radius: 2, x: 0, y: 1)
    }

    // MARK: - Info card (gradient, pin, grid)

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AddNoteColors.infoPinWell(colorScheme))
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(AddNoteColors.infoPinIcon(colorScheme))
                }
                .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.string("add_note.info.title"))
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundStyle(AddNoteColors.infoTitle(colorScheme))
                        .tracking(-0.15)
                    infoCardBodyText
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Rectangle()
                .fill(AddNoteColors.infoDivider(colorScheme))
                .frame(height: 0.67)
            infoBulletGrid
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: AddNoteColors.infoGradient(colorScheme),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AddNoteColors.infoCardBorder(colorScheme), lineWidth: 0.67)
        )
    }

    private var infoCardBodyText: Text {
        let h = viewModel.infoCardLocationHighlight
        let body = Text(L10n.string("add_note.info.body.prefix"))
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundStyle(AddNoteColors.infoBodySecondary(colorScheme))
            .tracking(-0.15)
        let mid = Text(h)
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundStyle(AddNoteColors.infoBodyEmphasis(colorScheme))
            .tracking(-0.15)
        let tail = Text(L10n.string("add_note.info.body.suffix"))
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundStyle(AddNoteColors.infoBodySecondary(colorScheme))
            .tracking(-0.15)
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
            L10n.string("add_note.info.grid.temperature_conditions"),
            L10n.string("add_note.info.grid.humidity_pressure"),
            L10n.string("add_note.info.grid.wind"),
            L10n.string("add_note.info.grid.visibility_clouds"),
        ]
    }

    private func infoRow(_ label: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AddNoteColors.bulletDot(colorScheme))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(AddNoteColors.infoBulletLabel(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Tips card

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("💡")
                Text(L10n.string("add_note.tips.title"))
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AddNoteColors.tipsTitle(colorScheme))
            }
            VStack(alignment: .leading, spacing: 6) {
                tipsLine("•", L10n.string("add_note.tips.activity"))
                tipsLine("•", L10n.string("add_note.tips.capture"))
                tipsLine("•", L10n.string("add_note.tips.storage"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AddNoteColors.tipsCardBackground(colorScheme))
        )
    }

    private func tipsLine(_ bullet: String, _ line: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(bullet)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(AddNoteColors.tipsBullet(colorScheme))
            Text(line)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(AddNoteColors.tipsBody(colorScheme))
        }
    }

    // MARK: - Footer (save)

    private var saveFooter: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AddNoteColors.headerDivider(colorScheme))
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
                Text(L10n.string("common.action.save"))
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .tracking(-0.31)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AddNoteColors.saveButtonFill(colorScheme))
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
        .background(AddNoteColors.headerBar(colorScheme))
    }

    private var saveButtonEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    AddNoteView(context: persistence.container.viewContext) {}
}
