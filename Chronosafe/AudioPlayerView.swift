//
//  AudioPlayerView.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var player: AVAudioPlayer?

    var body: some View {
        HStack {
            Button(action: {
                if player?.isPlaying == true {
                    player?.stop()
                } else {
                    play()
                }
            }) {
                Image(systemName: player?.isPlaying == true ? "stop.circle" : "play.circle")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }

            Text(audioURL.lastPathComponent)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .onDisappear {
            player?.stop()
        }
    }

    private func play() {
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Audio playback failed: \(error)")
        }
    }
}
