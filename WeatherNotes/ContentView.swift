//
//  ContentView.swift
//  WeatherNotes
//
//  Created by Yurii on 21.04.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NotesListView()
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    ContentView()
        .environment(\.managedObjectContext, persistence.container.viewContext)
}
