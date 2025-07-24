//
//  ChronosafeApp.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 23/07/25.
//

import SwiftUI
import SwiftData

@main
struct ChronosafeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Capsule.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("❌ Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
