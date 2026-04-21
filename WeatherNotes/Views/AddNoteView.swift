import CoreData
import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: AddNoteViewModel
    @State private var text = ""
    @FocusState private var isNoteFieldFocused: Bool

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

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.isSaving {
                            loadingBlock
                        }

                        if let message = viewModel.errorMessage, !message.isEmpty {
                            errorBanner(message)
                        }

                        inputCard
                        infoCard
                        tipsCard
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Нова нотатка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomSaveBar
            }
        }
    }

    // MARK: - Blocks

    private var loadingBlock: some View {
        HStack(alignment: .center, spacing: 12) {
            ProgressView()
            VStack(alignment: .leading, spacing: 4) {
                Text("Отримуємо погоду та зберігаємо...")
                    .font(.subheadline.weight(.medium))
                if !viewModel.weatherSourceHint.isEmpty {
                    Text(viewModel.weatherSourceHint)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemRed).opacity(colorScheme == .dark ? 0.18 : 0.10))
            )
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Текст нотатки")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Опишіть, що відбувається…")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 6)
                        .allowsHitTesting(false)
                }
                TextEditor(text: boundedNoteText)
                    .focused($isNoteFieldFocused)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120, maxHeight: 220)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.55), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isNoteFieldFocused = true
            }

            HStack {
                Spacer()
                Text("\(text.count)/\(maxLength)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.accentColor, Color(.secondarySystemFill))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Автоматичний знімок погоди")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Погода підтягується автоматично для поточної локації (або Київ, якщо геолокація недоступна).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .overlay(Color(.separator))

            VStack(alignment: .leading, spacing: 8) {
                bulletRow("До 200 символів на нотатку.")
                bulletRow("Під час збереження показуємо джерело локації.")
                bulletRow("Помилки мережі — зрозумілі повідомлення українською.")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: infoGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(infoBorderColor, lineWidth: 1)
        )
    }

    private var infoGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.10, green: 0.14, blue: 0.24),
                Color(red: 0.12, green: 0.12, blue: 0.20),
            ]
        }
        return [
            Color(red: 0.94, green: 0.97, blue: 1.0),
            Color(red: 0.93, green: 0.95, blue: 1.0),
        ]
    }

    private var infoBorderColor: Color {
        colorScheme == .dark ? Color(.separator) : Color(red: 0.86, green: 0.92, blue: 0.99)
    }

    private func bulletRow(_ line: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            Text(line)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Поради")
                .font(.subheadline.weight(.semibold))
            Text("Переконайтеся, що є інтернет і (за бажанням) дозвіл на геолокацію — так прогноз буде точнішим.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    private var bottomSaveBar: some View {
        VStack(spacing: 0) {
            Divider()
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
                Text("Зберегти нотатку")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor)
            )
            .opacity((saveButtonEnabled && !viewModel.isSaving) ? 1 : 0.45)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color(.systemBackground))
            .disabled(!saveButtonEnabled || viewModel.isSaving)
        }
    }

    private var saveButtonEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    AddNoteView(context: persistence.container.viewContext) {}
}
