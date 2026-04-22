//
//  ContentView.swift
//  WeatherNotes
//
//  Created by Yurii on 21.04.2026.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        NotesListView(managedObjectContext: managedObjectContext)
    }
}

#Preview {
    @Previewable @State var persistence = PersistenceController.preview
    ContentView()
        .environment(\.managedObjectContext, persistence.container.viewContext)
}
