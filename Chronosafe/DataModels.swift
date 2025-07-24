import Foundation
import SwiftData

@Model
class Capsule {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var unlockDate: Date
    @Relationship(deleteRule: .cascade) var media: [CapsuleMedia]


    init(title: String, summary: String, unlockDate: Date, media: [CapsuleMedia]) {
        self.id = UUID()
        self.title = title
        self.summary = summary
        self.unlockDate = unlockDate
        self.media = media
    }
}

@Model
class CapsuleMedia {
    @Attribute(.unique) var id: UUID
    var type: CapsuleMediaType
    var filename: String?
    var text: String?
    @Relationship(inverse: \Capsule.media) var capsule: Capsule?
    
    init(type: CapsuleMediaType, filename: String?, text: String?) {
        self.id = UUID()
        self.type = type
        self.filename = filename
        self.text = text
    }
    var fileURL: URL? {
            guard let filename else { return nil }
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(filename)
        }
}

enum CapsuleMediaType: String, Codable, CaseIterable {
    case image, video, audio, text
}
