//
//  DataController.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import Foundation
import Combine

import Foundation
import SwiftData

@MainActor
class DataController: ObservableObject {
    static let shared = DataController()

    let container: ModelContainer
    let context: ModelContext

    init() {
        do {
            let schema = Schema([Capsule.self])
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [config])
            context = ModelContext(container)
        } catch {
            fatalError("❌ Failed to initialize SwiftData container: \(error)")
        }
    }

    func addCapsule(_ capsule: Capsule) {
        context.insert(capsule)
        save()
    }

    func removeCapsule(_ capsule: Capsule) {
        context.delete(capsule)
        save()
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }

    func fetchCapsules() -> [Capsule] {
        do {
            let descriptor = FetchDescriptor<Capsule>(sortBy: [.init(\.unlockDate)])
            return try context.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch capsules: \(error)")
            return []
        }
    }
}
