//
//  CapsuleDetailView.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import Foundation
import SwiftUI

struct CapsuleDetailView: View {
    let capsule: Capsule
    var body: some View {
        VStack {
            Text(capsule.title)
                .font(.largeTitle)
            Text(capsule.summary)
                .padding()
            Text("Unlocks: \(capsule.unlockDate, formatter: dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(Date() < capsule.unlockDate ? "Locked" : "Unlocked")
                .font(.title2)
                .foregroundColor(Date() < capsule.unlockDate ? .red : .green)
            Spacer()
        }
        .padding()
        .navigationTitle("Capsule Detail")
    }
}
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
