//
//  DataController.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import Foundation
import Combine
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
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    func addCapsule(_ capsule: Capsule) {
        for media in capsule.media {
            if let originalURL = media.fileURL ?? media.fileURL {
                print("📤 Original media URL: \(originalURL.path)")
                let fileExtension = originalURL.pathExtension
                if let filename = persistMediaFile(originalURL: originalURL, fileExtension: fileExtension) {
                    media.filename = filename
                    print("Persisted media: \(filename)")
                } else {
                    print("Failed to persist: \(originalURL.lastPathComponent)")
                }
            } else {
                print("Media has no URL")
            }
            media.capsule = capsule
        }

        context.insert(capsule)
        save()
    }
    
    func removeCapsule(_ capsule: Capsule) {
        for media in capsule.media {
            if let filename = media.filename {
                let fileURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(filename)
                deleteFile(at: fileURL)
            }
        }

        context.delete(capsule)
        save()
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func fetchCapsules() -> [Capsule] {
        do {
            let descriptor = FetchDescriptor<Capsule>(sortBy: [.init(\.unlockDate)])
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch capsules: \(error)")
            return []
        }
    }
    
    func persistMediaFile(originalURL: URL, fileExtension: String) -> String? {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let uniqueName = UUID().uuidString + "." + fileExtension
        let destinationURL = documents.appendingPathComponent(uniqueName)

        do {
            try fileManager.copyItem(at: originalURL, to: destinationURL)
            print("File saved at: \(destinationURL.path)")
            return uniqueName
        } catch {
            print("Failed to copy media file: \(error)")
            return nil
        }
    }
    
    private func deleteFile(at url: URL) {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                print("Deleted file: \(url.lastPathComponent)")
            }
        } catch {
            print("Failed to delete file: \(error)")
        }
    }
}
