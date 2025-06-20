import SwiftUI
import SwiftData
import AppKit
struct KeybindingsDataDetailView: View {
    @Bindable var data: KeybindingsData
    @State private var errorMessage = ""
    @State private var isValid = true
    @State private var showErrorAlert = false
    @State private var keybindingText: String = ""
    init(data: KeybindingsData) {
        self.data = data
        self._keybindingText = State(initialValue: data.formattedKeybinding)
    }
    var body: some View {
        Form {
            Section(header: Text("Set keybindings")) {
                Toggle("Enabled", isOn: $data.isEnabled)
                    .onChange(of: data.isEnabled) {
                        saveChanges()
                    }
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
                                isValid = validateInput()
                                saveChanges()
                            }
                        }
                    }) {
                        Image(systemName: "folder")
                    }
                    .help("Browse for application")
                }
                .onChange(of: data.applicationPath) {
                    isValid = validateInput()
                    saveChanges()
                }
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                TextField("Keybindings", text: $keybindingText)
                    .onChange(of: keybindingText) { oldValue, newValue in
                        if oldValue != newValue {
                            parseKeybinding()
                            isValid = validateInput()
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
        .onChange(of: data) { _, newData in
            keybindingText = newData.formattedKeybinding
        }
    }
    private func parseKeybinding() {
        let components = keybindingText.split(separator: "-")
        data.withOption = false
        data.withCommand = false
        data.withShift = false
        data.withControl = false
        data.key = ""
        for component in components.map({ String($0).lowercased() }) {
            switch component {
            case "option": data.withOption = true
            case "command": data.withCommand = true
            case "shift": data.withShift = true
            case "control": data.withControl = true
            default:
                data.key = component
            }
        }
    }
    private func validateInput() -> Bool {
        errorMessage = ""
        if !data.applicationPath.lowercased().hasSuffix(".app") {
            errorMessage = "Application path must end with .app"
            return false
        }
        if data.modifiers.isEmpty {
            errorMessage = "Keybindings must include at least one modifier (Option, Command, Shift, or Control)"
            return false
        }
        if data.key.isEmpty {
            errorMessage = "Keybindings must include a key"
            return false
        }
        if data.key.count > 1 {
            errorMessage = "Keybindings can only have one key"
            return false
        }
        return true
    }
    private func saveChanges() {
        if !isValid {
            return
        }
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
    let data = KeybindingsData(applicationPath: "Example App", modifies: ["command"], key: "space")
    container.mainContext.insert(data)
    return KeybindingsDataDetailView(data: data)
        .modelContainer(container)
}
