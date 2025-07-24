//
//  CapsuleMediaButton.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import SwiftUI

struct CapsuleMediaButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(18)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
