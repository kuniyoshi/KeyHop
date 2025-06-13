# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KeyHop is a macOS application launcher written in Swift using SwiftUI and SwiftData. It enables users to launch applications using global hotkeys instead of ⌘-Tab switching. The project philosophy emphasizes simplicity and focused functionality over rich features.

## Development Commands

### Build and Test
```bash
# Build the project
xcodebuild clean build analyze -scheme KeyHop -project KeyHop.xcodeproj

# Run tests
xcodebuild test -scheme KeyHop -destination platform=macOS

# Lint Swift code
swiftlint lint --reporter relative-path
```

### Git Setup
```bash
# Configure git hooks (run once during setup)
git config core.hooksPath githooks
```

### Distribution
1. Archive in Xcode
2. Distribute App → Copy App
3. Create DMG: `create-dmg KeyHop.dmg KeyHop.v[version]/KeyHop.app`

## Architecture

### Core Components

- **HotkeyManager**: Singleton that manages global hotkey detection using Carbon CGEvent API. Creates an event tap to monitor system-wide key events and matches them against cached keybindings.

- **KeybindingsData**: SwiftData model storing application paths, modifier keys, and key assignments. Includes `isEnabled` field for toggling keybindings.

- **AppDelegate**: Handles macOS integration (status bar, window management, accessibility policy). App runs as LSUIElement (hidden from Dock).

### Data Flow

1. SwiftData model container initialized in KeyHopApp
2. HotkeyManager receives container reference and caches keybindings
3. Global key events trigger hotkey matching against cache
4. Matched keybindings launch associated applications via NSWorkspace
5. UI changes trigger NotificationCenter updates to refresh cache

### Key Files

- `KeyHopApp.swift`: App entry point with SwiftData setup
- `HotkeyManager.swift`: Core global hotkey detection logic
- `AppDelegate.swift`: macOS system integration
- `KeybindingsData.swift`: Data model for keybinding storage
- `KeybindingsDataView.swift`: Main UI list view
- `KeybindingsDataDetailView.swift`: Individual keybinding editor

## Requirements

- macOS with accessibility permissions enabled
- Xcode 16.2+ for development
- SwiftLint for code quality (configured in git hooks)

## Git Workflow

The project uses a pre-commit hook that automatically:
- Removes trailing whitespace from Swift files
- Converts whitespace-only lines to empty lines
- Re-stages modified files

Current version: 0.11.0 (based on distribution bundle)