import CoreData
import SwiftUI

// MARK: - Figma ListScreen (node 1:5) palette

private enum ListPalette {
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textCondition = Color(uiColor: .secondaryLabel)
    static let borderHeader = Color(uiColor: .separator)
    static let borderCard = Color(uiColor: .separator).opacity(0.35)
    static let bullet = Color(uiColor: .tertiaryLabel)
    static let themeButtonFill = Color(uiColor: .tertiarySystemFill)
    static let addButton = Color(red: 43 / 255, green: 127 / 255, blue: 1) // #2b7fff
    static let white = Color(uiColor: .systemBackground)
}

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
                ListPalette.screenBackground
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    listHeader
                    if notes.isEmpty {
                        emptyStateView
                    } else {
                        listContent
                    }
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

    private var listContent: some View {
        List {
            ForEach(notes) { note in
                NavigationLink {
                    NoteDetailView(note: note)
                } label: {
                    NoteRowView(note: note)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(NoteCardChrome())
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSpacing(16)
        .padding(.top, 12)
    }

    // MARK: Header (Figma: white bar, 1px border #e5e7eb, soft shadow)

    private var listHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Погодні нотатки")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(ListPalette.textPrimary)
                    .tracking(0.07)
                Text(noteCountSubtitle(notes.count))
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(ListPalette.textSecondary)
                    .tracking(-0.15)
            }
            Spacer(minLength: 8)
            headerThemeButton
            headerAddButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ListPalette.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ListPalette.borderHeader)
                .frame(maxWidth: .infinity, maxHeight: 0.5)
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var headerThemeButton: some View {
        Button {
            themeRaw = themePreference.next().rawValue
        } label: {
            Image(systemName: themePreference.toolbarIconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ListPalette.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(ListPalette.themeButtonFill))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(themePreference.accessibilityLabel)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var headerAddButton: some View {
        Button {
            isPresentingAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(ListPalette.addButton))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Додати нотатку")
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
    }

    // MARK: Empty state (Ukrainian)

    private var emptyStateView: some View {
        VStack {
            Spacer(minLength: 32)
            ZStack {
                NoteCardChrome()
                VStack(spacing: 16) {
                    Image(systemName: "note.text.badge.plus")
                        .font(.system(size: 48, weight: .regular))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(ListPalette.textSecondary)
                    Text("Ще немає нотаток")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundStyle(ListPalette.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("Натисніть кнопку з «+» у правому верхньому куті, щоб створити нотатку з погодою.")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(ListPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .frame(minHeight: 220)
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Note card chrome (Figma: 16pt radius, border #f3f4f6, soft elevation)

private struct NoteCardChrome: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ListPalette.white)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(ListPalette.borderCard, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private struct NoteRowView: View {
    let note: WeatherNote

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.text ?? "")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundStyle(ListPalette.textPrimary)
                    .lineLimit(2)
                    .tracking(-0.44)
                if let createdAt = note.createdAt {
                    dateMetaRow(createdAt)
                }
                if !conditionString(for: note).isEmpty {
                    Text(conditionString(for: note).localizedCapitalized)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(ListPalette.textCondition)
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 8) {
                Image(systemName: symbolName(for: note.weatherMain ?? ""))
                    .font(.system(size: 32, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(ListPalette.addButton)
                Text("\(listTemperature(note))°")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(ListPalette.textPrimary)
                    .monospacedDigit()
                    .tracking(0.07)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .accessibilityElement(children: .combine)
    }

    private func dateMetaRow(_ date: Date) -> some View {
        HStack(spacing: 8) {
            Text(relativeDayLabel(for: date))
            Text("•")
                .foregroundStyle(ListPalette.bullet)
            Text(timePortion(date))
        }
        .font(.system(size: 14, weight: .regular, design: .default))
        .foregroundStyle(ListPalette.textSecondary)
        .tracking(-0.15)
    }

    private func relativeDayLabel(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Сьогодні" }
        if cal.isDateInYesterday(date) { return "Вчора" }
        return date.formatted(
            .dateTime.day().month(.abbreviated)
                .locale(Locale(identifier: "uk_UA"))
        )
    }

    private func timePortion(_ date: Date) -> String {
        date.formatted(
            .dateTime.hour().minute()
                .locale(Locale(identifier: "uk_UA"))
        )
    }

    private func conditionString(for note: WeatherNote) -> String {
        let desc = (note.weatherDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !desc.isEmpty { return desc.localizedLowercase }
        let main = (note.weatherMain ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return main.localizedLowercase
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
