//
//  ContentView.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CapsuleListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
