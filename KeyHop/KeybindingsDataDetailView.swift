import SwiftUI
import SwiftData
import AppKit

struct KeybindingsDataDetailView: View {
    @Bindable var data: KeybindingsData
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var keybindingText: String = ""

    init(data: KeybindingsData) {
        self.data = data
        self._keybindingText = State(initialValue: data.formattedKeybinding)
    }

    var body: some View {
        Form {
            Section(header: Text("Application Details")) {
                HStack {
                    TextField("Application Path", text: $data.applicationPath)

                    Button(action: {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = true
                        panel.treatsFilePackagesAsDirectories = false

                        if panel.runModal() == .OK {
                            if let url = panel.url {
                                data.applicationPath = url.path
                                saveChanges()
                            }
                        }
                    }) {
                        Image(systemName: "folder")
                    }
                    .help("Browse for application")
                }
                .onChange(of: data.applicationPath) {
                    saveChanges()
                }

                TextField("Keybindings", text: $keybindingText)
                    .onChange(of: keybindingText) { oldValue, newValue in
                        if oldValue != newValue {
                            parseKeybinding()
                            saveChanges()
                        }
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

    private func parseKeybinding() {
        let components = keybindingText.split(separator: "-")

        if components.count > 1 {
            let newModifiers = components.dropLast().map { String($0).lowercased() }
            data.modifies = newModifiers
            data.key = String(components.last!).lowercased()
        } else if components.count == 1 {
            data.modifies = []
            data.key = String(components[0]).lowercased()
        }
    }

    private func saveChanges() {
        do {
            if let context = data.modelContext {
                try context.save()
                print("Changes saved successfully")

                NotificationCenter.default.post(
                    name: Notification.Name("KeybindingsDataChanged"),
                    object: nil
                )
            } else {
                print("Warning: Model context is nil")
                errorMessage = "Failed to save: no model context available"
                showErrorAlert = true
            }
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Error saving changes: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    guard let container = try? ModelContainer(for: KeybindingsData.self, configurations: config) else {
        fatalError("Failed to create ModelContainer")
    }
    let data = KeybindingsData(applicationPath: "Example App", modifies: ["cmd"], key: "space")
    container.mainContext.insert(data)
    return KeybindingsDataDetailView(data: data)
        .modelContainer(container)
}
