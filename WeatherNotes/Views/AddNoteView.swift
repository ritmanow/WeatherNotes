import CoreData
import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AddNoteViewModel
    @State private var text = ""

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
            Form {
                Section {
                    TextField("Нотатка", text: boundedNoteText, axis: .vertical)
                        .lineLimit(3 ... 10)
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(text.count)/\(maxLength)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if viewModel.isSaving {
                    Section {
                        HStack(alignment: .center, spacing: 12) {
                            ProgressView()
                            Text("Отримуємо погоду та зберігаємо...")
                                .font(.subheadline)
                        }
                        if !viewModel.weatherSourceHint.isEmpty {
                            Text(viewModel.weatherSourceHint)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let message = viewModel.errorMessage, !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        Task {
                            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            let payload = String(trimmed.prefix(maxLength))
                            await viewModel.save(trimmedText: payload)
                            if viewModel.errorMessage == nil {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSaving)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    AddNoteView(context: persistence.container.viewContext) {}
}
