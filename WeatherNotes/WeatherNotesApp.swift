//
//  WeatherNotesApp.swift
//  WeatherNotes
//
//  Created by Yurii on 21.04.2026.
//

import SwiftUI

@main
struct WeatherNotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NotesListView(managedObjectContext: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
