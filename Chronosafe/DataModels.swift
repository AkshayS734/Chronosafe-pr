import Foundation

struct Capsule: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var unlockDate: Date
    var media: [CapsuleMedia]
}

enum CapsuleMediaType: String, Codable {
    case image, video, audio, text
}

struct CapsuleMedia: Identifiable, Codable {
    var id: UUID = UUID()
    var type: CapsuleMediaType
    var url: URL? // For image/video/audio
    var text: String? // For text messages
}