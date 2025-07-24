//
//  CapsuleDetailView.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import SwiftUI
import AVKit

struct CapsuleDetailView: View {
    let capsule: Capsule

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(capsule.title)
                    .font(.largeTitle)
                    .padding(.top)
                Text(capsule.summary)
                    .font(.body)

                Text("Unlocks: \(capsule.unlockDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(Date() < capsule.unlockDate ? "Locked" : "Unlocked")
                    .font(.title2)
                    .foregroundColor(Date() < capsule.unlockDate ? .red : .green)

                if !capsule.media.isEmpty {
                    Divider()
                    Text("Media")
                        .font(.headline)
                    ForEach(capsule.media) { media in
                        CapsuleMediaDisplay(media: media)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Capsule Detail")
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
