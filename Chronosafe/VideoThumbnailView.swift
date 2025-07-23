import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "video")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.purple)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    private func generateThumbnail() {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)
            if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            }
        }
    }
} 