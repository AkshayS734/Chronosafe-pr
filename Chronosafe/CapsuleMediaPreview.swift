import SwiftUI
import AVFoundation
import AVKit

struct CapsuleMediaPreview: View {
    let media: CapsuleMedia
    let onDelete: (() -> Void)?
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var isPlaying: Bool = false
    @State private var playbackProgress: Double = 0.0
    @State private var timer: Timer? = nil
    @State private var isScrubbing: Bool = false
    @State private var showImageFullScreen: Bool = false
    @State private var showVideoFullScreen: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            switch media.type {
            case .image:
                if let url = media.fileURL, let uiImage = UIImage(contentsOfFile: url.path) {
                    Button(action: { showImageFullScreen = true }) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            case .video:
                ZStack {
                    if let url = media.fileURL {
                        VideoThumbnailView(url: url)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.purple, lineWidth: 1))
                        Button(action: { showVideoFullScreen = true }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.purple)
                                .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .offset(x: 0, y: 0)
                    } else {
                        Image(systemName: "video")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.purple)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            case .audio:
                Image(systemName: "mic")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.orange)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                if let url = media.fileURL {
                    Button(action: {
                        if isPlaying {
                            pauseAudio()
                        } else {
                            playAudio(url: url)
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    HStack(spacing: 4) {
                        Text(formatTime(playbackProgress))
                            .font(.caption.monospacedDigit())
                            .frame(width: 36, alignment: .trailing)
                        Slider(value: Binding(
                            get: {
                                playbackProgress
                            },
                            set: { newValue in
                                playbackProgress = newValue
                                if let player = audioPlayer {
                                    player.currentTime = newValue
                                }
                            }
                        ), in: 0...(audioPlayer?.duration ?? 1), step: 0.01, onEditingChanged: { editing in
                            isScrubbing = editing
                            if !editing, let player = audioPlayer {
                                player.currentTime = playbackProgress
                            }
                        })
                        .frame(width: 100)
                        Text(formatTime(audioPlayer?.duration ?? 0))
                            .font(.caption.monospacedDigit())
                            .frame(width: 36, alignment: .leading)
                    }
                }
            case .text:
                Image(systemName: "text.bubble")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(media.type.rawValue.capitalized)
                    .font(.headline)
                if let text = media.text, media.type == .text {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                } else if let url = media.fileURL {
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .onDisappear { stopAudio() }
        // Full screen image
        .fullScreenCover(isPresented: $showImageFullScreen) {
            if let url = media.fileURL, let uiImage = UIImage(contentsOfFile: url.path) {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                    Button(action: { showImageFullScreen = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
        // Full screen video
        .fullScreenCover(isPresented: $showVideoFullScreen) {
            if let url = media.fileURL {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    VideoPlayer(player: AVPlayer(url: url))
                        .ignoresSafeArea()
                    Button(action: { showVideoFullScreen = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    private func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    private func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        stopTimer()
        playbackProgress = 0.0
    }
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if let player = audioPlayer, !isScrubbing {
                playbackProgress = player.currentTime
                if !player.isPlaying {
                    isPlaying = false
                    stopTimer()
                }
            }
        }
    }
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 
