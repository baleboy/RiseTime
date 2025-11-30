//
//  RiseTimeApp.swift
//  RiseTime
//
//  Created by Francesco Balestrieri on 24.11.2025.
//

import SwiftUI
import SwiftData

@main
struct RiseTimeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            Experiment.self
        ])
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
                .task {
                    await NotificationManager.shared.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
