# caffeinate-menubar

macOS menu bar app to control `caffeinate(8)` with mouse-friendly controls. Personal-use SwiftUI app (macOS 13+, uses `MenuBarExtra`).

## Features

- Lives in the menu bar (cup icon — filled while active)
- Toggles for `-d` `-i` `-m` `-s` `-u`
- Indefinite or timer mode (5–480 min slider, mapped to `-t <seconds>`)
- Remembers settings via `@AppStorage`
- Spawns and supervises `/usr/bin/caffeinate` directly

## Setup (one-time, in Xcode)

The repo ships source files only — create the Xcode project locally:

1. Xcode → **File ▸ New ▸ Project ▸ macOS ▸ App**
   - Product Name: `CaffeinateMenuBar`
   - Interface: **SwiftUI**, Language: **Swift**
   - Save the `.xcodeproj` at the repo root (next to this README).
2. Delete the generated `CaffeinateMenuBarApp.swift` / `ContentView.swift`, then drag in the files under [`CaffeinateMenuBar/`](CaffeinateMenuBar/) (Copy items: **off**, so the repo files stay the source of truth).
3. In the target's **Info** tab add **Application is agent (UIElement)** = `YES` (no Dock icon).
4. **Signing & Capabilities**: set your personal team. Leave **App Sandbox off** — sandboxed apps can't `Process.run` `/usr/bin/caffeinate`.
5. Deployment target: **macOS 13.0** or later (`MenuBarExtra` requirement).
6. Build & Run (⌘R). The cup icon appears in the menu bar.

## Usage

Click the cup → pick flags and duration → **Start**. Click again → **Stop**. Quitting the app also stops the child process.
