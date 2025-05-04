import SwiftUI
import SwiftData

struct KeybindingsDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var keybindingsData: [KeybindingsData]
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
                        VStack(alignment: .leading) {
                            Text(data.applicationPath)
                            Text(data.formattedKeybinding).font(.caption)
                        }
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
            let newItem = KeybindingsData(
                applicationPath: "/Applications/kitty.app",
                modifies: ["option", "command"],
                key: "t"
            )
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
        }
    }
}

#Preview {
    KeybindingsDataView()
        .modelContainer(for: KeybindingsData.self, inMemory: true)
}
