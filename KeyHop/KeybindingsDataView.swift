import SwiftUI
import SwiftData
import AppKit

struct KeybindingsDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KeybindingsData.order) private var keybindingsData: [KeybindingsData]
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var selectedData: KeybindingsData?

    var body: some View {
        VStack {
            List {
                ForEach(keybindingsData) { data in
                    Button(action: {
                        selectedData = data
                    }) {
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: data.applicationPath))
                                .resizable()
                                .frame(width: 24, height: 24)

                            VStack(alignment: .leading) {
                                Text(data.applicationPath)
                                Text(data.formattedKeybinding).font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }

            if let selectedData = selectedData {
                KeybindingsDataDetailView(data: selectedData)
                    .padding()
            } else {
                Text("Select an item")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func addItem() {
        withAnimation {
            let newOrder = keybindingsData.isEmpty ? 0 : keybindingsData.count
            let newItem = KeybindingsData(
                applicationPath: "Example.app",
                modifies: ["option", "command", "shift", "control"],
                key: "t"
            )
            newItem.order = newOrder
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(keybindingsData[index])
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            var updatedItems = keybindingsData
            updatedItems.move(fromOffsets: source, toOffset: destination)

            for (index, item) in updatedItems.enumerated() {
                item.order = index
            }

            do {
                try modelContext.save()
            } catch {
                errorMessage = "Failed to reorder items: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    KeybindingsDataView()
        .modelContainer(for: KeybindingsData.self, inMemory: true)
}
