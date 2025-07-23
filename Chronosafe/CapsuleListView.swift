import SwiftUI

struct CapsuleListView: View {
    @State private var capsules: [Capsule] = [
        Capsule(title: "Birthday Surprise", description: "Open on your birthday!", unlockDate: Date().addingTimeInterval(3600), media: []),
        Capsule(title: "Anniversary Video", description: "A special message.", unlockDate: Date().addingTimeInterval(-3600), media: [])
    ]
    @State private var showNewCapsule = false
    
    var body: some View {
        NavigationView {
            List(capsules) { capsule in
                NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(capsule.title)
                                .font(.headline)
                            Text("Unlocks: \(capsule.unlockDate, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if Date() < capsule.unlockDate {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Time Capsules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewCapsule = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewCapsule) {
                NewCapsuleView { newCapsule in
                    capsules.append(newCapsule)
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct CapsuleDetailView: View {
    let capsule: Capsule
    var body: some View {
        VStack {
            Text(capsule.title)
                .font(.largeTitle)
            Text(capsule.description)
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