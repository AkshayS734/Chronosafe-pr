import SwiftUI
import SwiftData

struct CapsuleListView: View {
    @Query(sort: [SortDescriptor(\Capsule.unlockDate)]) private var capsules: [Capsule]
    @Environment(\.modelContext) private var modelContext
    @State private var showNewCapsule = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(capsules) { capsule in
                    if Date() >= capsule.unlockDate {
                        NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                            capsuleRow(for: capsule)
                        }
                    } else {
                        capsuleRow(for: capsule)
                            .contentShape(Rectangle())
                            .disabled(true)
                            .opacity(0.8)
                    }
                }
                .onDelete(perform: deleteCapsule)
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
                    modelContext.insert(newCapsule)
                    try? modelContext.save()
                }
            }
        }
    }
    
    private func deleteCapsule(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(capsules[index])
        }
        try? modelContext.save()
    }
    @ViewBuilder
    private func capsuleRow(for capsule: Capsule) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(capsule.title)
                    .font(.headline)
                Text("Unlocks: \(capsule.unlockDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: Date() < capsule.unlockDate ? "lock.fill" : "lock.open.fill")
                .foregroundColor(Date() < capsule.unlockDate ? .red : .green)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
