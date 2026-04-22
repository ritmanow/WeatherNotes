import CoreData
import SwiftUI

// MARK: - ListScreen colors (Figma light ~22:3, dark ~22:31; adaptive for all iPhone sizes)

private enum ListColors {
    /// Main canvas behind header + content (#f9fafb light / #101828 dark).
    static func screen(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 16 / 255, green: 24 / 255, blue: 40 / 255)
            : Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
    }

    /// Header bar surface (white / #1e2939).
    static func headerBar(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color(red: 1, green: 1, blue: 1)
    }

    /// Note cards & empty-state icon disc (lifted from canvas in dark).
    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 30 / 255, green: 41 / 255, blue: 57 / 255)
            : Color(red: 1, green: 1, blue: 1)
    }

    /// Figma light: #f3f4f6 — dark: #364153.
    static func cardBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
    }

    /// Figma light: #e5e7eb — dark: #364153.
    static func headerDivider(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
    }

    static func primaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.primary
    }

    static func secondaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255) : Color.secondary
    }

    static func emptyTitle(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 209 / 255, green: 213 / 255, blue: 220 / 255) : Color.primary
    }

    static func emptyHint(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 106 / 255, green: 114 / 255, blue: 130 / 255) : Color.secondary
    }

    static func textCondition(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255) : Color(uiColor: .secondaryLabel)
    }

    /// Weather phrase on list card (Figma light #4a5565).
    static func listCardCondition(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
            : Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
    }

    static func bullet(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 74 / 255, green: 85 / 255, blue: 101 / 255)
            : Color(red: 209 / 255, green: 213 / 255, blue: 220 / 255)
    }

    static func themeButtonFill(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 54 / 255, green: 65 / 255, blue: 83 / 255)
            : Color(uiColor: .tertiarySystemFill)
    }

    /// Light: #2b7fff — Dark: #155dfc (Figma).
    static func addButton(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 21 / 255, green: 93 / 255, blue: 252 / 255)
            : Color(red: 43 / 255, green: 127 / 255, blue: 1)
    }

    static func cardShadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.1)
    }
}

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(ThemePreference.storageKey) private var themeRaw = ThemePreference.system.rawValue

    @StateObject private var listViewModel: NotesListViewModel

    @State private var isPresentingAdd = false

    init(managedObjectContext: NSManagedObjectContext) {
        _listViewModel = StateObject(wrappedValue: NotesListViewModel(viewContext: managedObjectContext))
    }

    private var themePreference: ThemePreference {
        ThemePreference(rawValue: themeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ListColors.screen(colorScheme)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    listHeader
                    if listViewModel.isEmpty {
                        emptyStateView
                    } else {
                        listContent
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            /// `sheet` leaves a system white strip above the card on some sizes (e.g. SE) in dark mode; full-screen avoids that chrome.
            .fullScreenCover(isPresented: $isPresentingAdd) {
                AddNoteView(context: viewContext) {
                    isPresentingAdd = false
                }
            }
        }
        .background(ListColors.screen(colorScheme).ignoresSafeArea(edges: .all))
        .preferredColorScheme(themePreference.colorScheme)
    }

    private var listContent: some View {
        List {
            ForEach(listViewModel.notes) { note in
                NavigationLink {
                    NoteDetailView(note: note)
                } label: {
                    NoteRowView(note: note, listViewModel: listViewModel)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(NoteCardChrome())
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation {
                            listViewModel.delete(note)
                        }
                    } label: {
                        Label(L10n.string("notes_list.action.delete"), systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSpacing(16)
        .padding(.top, 16)
    }

    // MARK: Header (Figma: white bar, 1px border #e5e7eb, soft shadow)

    private var listHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.string("notes_list.title"))
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(ListColors.primaryText(colorScheme))
                    .tracking(0.07)
                Text(listViewModel.noteCountSubtitle(for: listViewModel.notes.count))
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(ListColors.secondaryText(colorScheme))
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
        .background(ListColors.headerBar(colorScheme))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ListColors.headerDivider(colorScheme))
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
                .foregroundStyle(ListColors.primaryText(colorScheme))
                .frame(width: 44, height: 44)
                .background(Circle().fill(ListColors.themeButtonFill(colorScheme)))
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
                .background(Circle().fill(ListColors.addButton(colorScheme)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.string("notes_list.action.add.accessibility"))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
    }

    // MARK: Empty state (Figma: cloud in ~112pt disc @ ~50% opacity, title 20 medium, hint 14; no card chrome)

    private var emptyStateView: some View {
        GeometryReader { proxy in
            let maxContent = min(proxy.size.width - 32, 400)
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                VStack(spacing: 20) {
                    Image("EmptyStateCloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                        .accessibilityHidden(true)

                    Text(L10n.string("notes_list.empty.title"))
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .foregroundStyle(ListColors.emptyTitle(colorScheme))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: maxContent)

                    Text(L10n.string("notes_list.empty.body"))
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(ListColors.emptyHint(colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: maxContent)
                }
                .frame(maxWidth: .infinity)
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}

// MARK: - Note card chrome (Figma: 16pt radius, border #f3f4f6, soft elevation)

private struct NoteCardChrome: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let shadow = ListColors.cardShadow(colorScheme)
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ListColors.card(colorScheme))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(ListColors.cardBorder(colorScheme), lineWidth: 0.5)
        }
        .shadow(color: shadow, radius: 1, x: 0, y: 1)
        .shadow(color: shadow, radius: 2, x: 0, y: 1)
    }
}

private struct NoteRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let note: WeatherNote
    @ObservedObject var listViewModel: NotesListViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.text ?? "")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundStyle(ListColors.primaryText(colorScheme))
                    .lineLimit(2)
                    .tracking(-0.44)
                if let createdAt = note.createdAt {
                    dateMetaRow(createdAt)
                }
                let apiLine = listViewModel.listConditionLine(for: note)
                if !apiLine.isEmpty {
                    Text(apiLine)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(ListColors.listCardCondition(colorScheme))
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 8) {
                Image(systemName: listViewModel.symbolName(for: note.weatherMain ?? ""))
                    .font(.system(size: 40, weight: .regular))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(ListColors.addButton(colorScheme))
                Text("\(listViewModel.listTemperature(for: note))°")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(ListColors.primaryText(colorScheme))
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
            Text(listViewModel.relativeDayLabel(for: date))
            Text("•")
                .foregroundStyle(ListColors.bullet(colorScheme))
            Text(listViewModel.timePortion(for: date))
        }
        .font(.system(size: 14, weight: .regular, design: .default))
        .foregroundStyle(ListColors.secondaryText(colorScheme))
        .tracking(-0.15)
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    NotesListView(managedObjectContext: persistence.container.viewContext)
        .environment(\.managedObjectContext, persistence.container.viewContext)
}
