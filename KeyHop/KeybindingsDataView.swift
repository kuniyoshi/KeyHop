import SwiftUI
import SwiftData
import AppKit
struct KeybindingsDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KeybindingsData.order) private var keybindingsData: [KeybindingsData]
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var selectedData: KeybindingsData?
    @StateObject private var loginItemManager = LoginItemManager.shared
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack {
                    Text("Settings")
                        .font(.headline)
                    Spacer()
                }
                HStack {
                    Toggle("Launch at login", isOn: Binding(
                        get: { loginItemManager.isEnabled },
                        set: { newValue in
                            loginItemManager.setLoginItem(enabled: newValue)
                        }
                    ))
                    Spacer()
                }
                Divider()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            List {
                ForEach(keybindingsData) { data in
                    Button(action: {
                        selectedData = data
                    }) {
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: data.applicationPath))
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(data.isEnabled ? 1.0 : 0.5)
                            VStack(alignment: .leading) {
                                Text(data.applicationPath)
                                    .opacity(data.isEnabled ? 1.0 : 0.5)
                                Text(data.formattedKeybinding).font(.caption)
                                    .opacity(data.isEnabled ? 1.0 : 0.5)
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
