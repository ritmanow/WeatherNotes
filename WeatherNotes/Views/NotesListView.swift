import CoreData
import SwiftUI

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage(ThemePreference.storageKey) private var themeRaw = ThemePreference.system.rawValue

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeatherNote.createdAt, ascending: false)],
        animation: .default
    )
    private var notes: FetchedResults<WeatherNote>

    @State private var isPresentingAdd = false

    private var themePreference: ThemePreference {
        ThemePreference(rawValue: themeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    listHeader
                    List {
                        ForEach(notes) { note in
                            NavigationLink {
                                NoteDetailView(note: note)
                            } label: {
                                NoteRowView(note: note)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(8)
                    .padding(.top, 12)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentingAdd) {
                AddNoteView(context: viewContext) {
                    isPresentingAdd = false
                }
            }
        }
        .preferredColorScheme(themePreference.colorScheme)
    }

    private var listHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Погодні нотатки")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(noteCountSubtitle(notes.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            headerCircleButton(
                systemName: themePreference.toolbarIconName,
                accessibilityLabel: themePreference.accessibilityLabel
            ) {
                themeRaw = themePreference.next().rawValue
            }
            headerCircleButton(systemName: "plus", accessibilityLabel: "Додати нотатку") {
                isPresentingAdd = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color(.systemGroupedBackground))
    }

    private func headerCircleButton(
        systemName: String,
        accessibilityLabel label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(Color(.secondarySystemGroupedBackground))
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func noteCountSubtitle(_ count: Int) -> String {
        let word: String
        let n10 = count % 10
        let n100 = count % 100
        if (11...14).contains(n100) {
            word = "нотаток"
        } else if n10 == 1 {
            word = "нотатка"
        } else if (2...4).contains(n10) {
            word = "нотатки"
        } else {
            word = "нотаток"
        }
        return "\(count) \(word)"
    }

    private func deleteNotes(at offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Intentionally quiet; Core Data save errors are rare for deletes in-app.
            }
        }
    }
}

private struct NoteRowView: View {
    let note: WeatherNote

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.text ?? "")
                    .lineLimit(2)
                if let createdAt = note.createdAt {
                    Text(createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                Text("\(listTemperature(note))°")
                    .font(.subheadline.monospacedDigit())
                Image(systemName: symbolName(for: note.weatherMain ?? ""))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    private func listTemperature(_ note: WeatherNote) -> Int {
        let t = note.temperature
        guard t.isFinite else { return 0 }
        return Int(t.rounded())
    }

    private func symbolName(for weatherMain: String) -> String {
        switch weatherMain.lowercased() {
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        case "rain": return "cloud.rain.fill"
        case "drizzle": return "cloud.drizzle.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "snow": return "cloud.snow.fill"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        case "smoke", "dust", "sand", "ash", "squall", "tornado": return "wind"
        default: return "cloud.sun.fill"
        }
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    NotesListView()
        .environment(\.managedObjectContext, persistence.container.viewContext)
}
