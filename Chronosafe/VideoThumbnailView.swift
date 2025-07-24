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
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)

        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
            guard let cgImage = cgImage, error == nil else {
                print("Failed to generate thumbnail: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.thumbnail = uiImage
            }
        }
    }
}
