import SwiftUI
import SwiftData

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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: KeybindingsData.self, configurations: config)
    let data = KeybindingsData(applicationPath: "Example App", keybindings: "Cmd+Space")
    container.mainContext.insert(data)
    return KeybindingsDataDetailView(data: data)
        .modelContainer(container)
}
