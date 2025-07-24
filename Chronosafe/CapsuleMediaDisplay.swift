//
//  CapsuleMediaDisplay.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import Foundation
import SwiftUI
import AVKit

struct CapsuleMediaDisplay: View {
    let media: CapsuleMedia

    var body: some View {
        switch media.type {
        case .image:
            VStack {
                if let url = media.fileURL,
                   FileManager.default.fileExists(atPath: url.path),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                } else {
                    Text("Image not available")
                        .foregroundColor(.red)
                }
            }

        case .video:
            VStack {
                if let url = media.fileURL, FileManager.default.fileExists(atPath: url.path) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300)
                } else {
                    Text("Video not available")
                        .foregroundColor(.red)
                }
            }

        case .audio:
            VStack {
                if let url = media.fileURL, FileManager.default.fileExists(atPath: url.path) {
                    AudioPlayerView(audioURL: url)
                } else {
                    Text("Audio not available")
                        .foregroundColor(.red)
                }
            }

        case .text:
            Text(media.text ?? "")
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}
