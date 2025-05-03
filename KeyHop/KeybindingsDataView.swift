//
//
//

import SwiftUI
import SwiftData

struct KeybindingsDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var keybindingsData: [KeybindingsData]
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(keybindingsData) { data in
                    NavigationLink {
                        KeybindingsDataDetailView(data: data)
                    } label: {
                        Text(data.applicationPath)
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = KeybindingsData(applicationPath: "New Application", keybindings: "")
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

struct KeybindingsDataDetailView: View {
    @Bindable var data: KeybindingsData
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Application Details")) {
                TextField("Application Path", text: $data.applicationPath)
                    .onChange(of: data.applicationPath) {
                        saveChanges()
                    }
                
                TextField("Keybindings", text: $data.keybindings)
                    .onChange(of: data.keybindings) {
                        saveChanges()
                    }
            }
        }
        .navigationTitle("Edit Keybinding")
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveChanges() {
        do {
            try data.modelContext?.save()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}

struct KeybindingsDataView_Previews: PreviewProvider {
    static var previews: some View {
        KeybindingsDataView()
            .modelContainer(for: KeybindingsData.self, inMemory: true)
    }
}
