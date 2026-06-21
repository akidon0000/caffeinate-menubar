<p align="center">
  <img src="assets/banner.svg" alt="CaffeinateMenuBar" width="100%"/>
</p>

<h1 align="center">CaffeinateMenuBar</h1>

<p align="center">
  <strong>Keep your Mac awake — from the menu bar.</strong><br/>
  A tiny, native SwiftUI front-end for macOS's built-in <code>caffeinate(8)</code>.
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-macOS%2013%2B-1B1B1F?style=flat-square&logo=apple"/>
  <img alt="Language" src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white"/>
  <img alt="UI" src="https://img.shields.io/badge/SwiftUI-MenuBarExtra-0A84FF?style=flat-square"/>
  <img alt="License" src="https://img.shields.io/badge/License-MIT-3A1A1A?style=flat-square"/>
  <img alt="PRs" src="https://img.shields.io/badge/PRs-welcome-FF8A8A?style=flat-square"/>
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ja.md">日本語</a>
</p>

---

<p align="center">
  <img src="assets/screenshot.svg" alt="Popover screenshot" width="640"/>
</p>

## ✨ Why?

`caffeinate` is the right tool to keep your Mac awake during a long build, render, or download — but typing flags into a terminal every time is annoying, and you have to leave the terminal open. **CaffeinateMenuBar** is the smallest reasonable GUI on top of it: live in the menu bar, click, tick the flags you want, set a timer (or leave it indefinite), hit **Start**.

When `caffeinate` is running, the menu bar icon turns a **soft red** so you always know your Mac is being held awake.

## 🚀 Features

- 🍵 **Menu-bar resident** — no Dock icon, no window clutter (`LSUIElement = YES`).
- 🔴 **At-a-glance state** — cup icon is filled and tinted soft red while active.
- ☑️ **All the flags, mouse-driven**: `-d` `-i` `-m` `-s` `-u`, each with a short description.
- ⏱ **Timer or until-stopped** — slider for 5–480 minutes, mapped to `-t <seconds>`.
- 💾 **Remembers your settings** via `@AppStorage`.
- 🧹 **Clean process management** — child `caffeinate` is terminated when you quit, time out, or hit Stop.

## 🧰 Requirements

- macOS **13.0** Ventura or later (uses SwiftUI `MenuBarExtra`)
- Xcode **15+** with the macOS SDK
- Optional: [XcodeGen](https://github.com/yonaskolb/XcodeGen) for regenerating the project from `project.yml`

## 📦 Install

### Option 1: Build from source (recommended)

```bash
git clone https://github.com/akidon0000/caffeinate-menubar.git
cd caffeinate-menubar

# Generate the Xcode project (only if you don't have CaffeinateMenuBar.xcodeproj or you edited project.yml)
xcodegen generate

# Release build, ad-hoc signed
xcodebuild -project CaffeinateMenuBar.xcodeproj \
  -scheme CaffeinateMenuBar -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build

# Install
cp -R build/Build/Products/Release/CaffeinateMenuBar.app /Applications/
open /Applications/CaffeinateMenuBar.app
```

### Option 2: Open in Xcode

```bash
open CaffeinateMenuBar.xcodeproj
```

Press **⌘R** to run.

> [!NOTE]
> The build is **ad-hoc signed** (`CODE_SIGN_IDENTITY=-`) because the app needs to `Process.run` `/usr/bin/caffeinate`, which is incompatible with the App Sandbox. Don't enable App Sandbox in Signing & Capabilities.

## 🖱 Usage

1. Click the cup icon in the menu bar.
2. Toggle the `caffeinate` flags you want.
3. Choose **Until stopped** or **Timer** (use the slider to pick minutes).
4. Hit **Start** — the icon turns soft red, and the header shows the countdown.
5. Click again → **Stop**, or just quit the app (⏻ button).

### Flag cheatsheet

| Flag | What it does |
| --- | --- |
| `-d` | Prevent the display from sleeping (screen stays on) |
| `-i` | Prevent the system from idle-sleeping |
| `-m` | Prevent the disk from idle-sleeping |
| `-s` | Prevent system sleep — **only effective on AC power** |
| `-u` | Declare user is active (5-second assertion by default) |

For full details, see `man caffeinate`.

## 🏗 Architecture

```
CaffeinateMenuBar/
├── CaffeinateMenuBarApp.swift   # @main, MenuBarExtra label + icon tint
├── CaffeinateController.swift   # ObservableObject managing the child Process
└── ContentView.swift            # Popover UI (toggles, slider, Start/Stop)
```

- `CaffeinateController` spawns `/usr/bin/caffeinate` via `Foundation.Process`, watches for termination, and runs a `Timer` to auto-stop when the chosen duration elapses.
- Settings persist via `@AppStorage` keys (`flag.d`, `flag.i`, …, `duration.mode`, `duration.minutes`).

## 🤝 Contributing

Contributions are very welcome — this is a small personal project, but PRs that improve it for everyone are appreciated.

Good places to help:

- 🌐 More UI translations (English, 日本語 are in place — others welcome)
- 🎨 A real `.icns` app icon (current logo is SVG-only)
- 🔋 Surface battery state in the popover (so `-s` is grayed out on battery)
- 🧪 Unit tests for `CaffeinateController` (process lifecycle, timer)
- 🧷 Launch-at-login toggle (`SMAppService`)
- 📦 A Homebrew Cask formula

### Workflow

1. Fork & branch (`feat/your-thing` or `fix/your-thing`).
2. Make focused commits — short subject + reason in body if non-obvious.
3. Make sure it still builds: `xcodebuild ... build` (see Install section).
4. Open a PR. Screenshots/GIFs for UI changes are great.
5. Be kind in reviews 🙂

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full checklist.

## 📜 License

[MIT](LICENSE) © akidon0000

## 🙏 Acknowledgements

- Apple's built-in [`caffeinate(8)`](x-man-page://caffeinate) — this project is just a friendlier face for it.
- Inspired by classic Mac utilities like Caffeine, Amphetamine, and KeepingYouAwake.
