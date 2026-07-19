//
//  Age2App.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 10.07.2026.
//

import SwiftUI
import SwiftData
// import UserNotifications
// import UIKit

@main
struct Age2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
