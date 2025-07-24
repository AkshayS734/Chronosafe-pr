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
    var url: URL?
    var text: String?

    init(type: CapsuleMediaType, url: URL?, text: String?) {
        self.id = UUID()
        self.type = type
        self.url = url
        self.text = text
    }
}

enum CapsuleMediaType: String, Codable, CaseIterable {
    case image, video, audio, text
}
