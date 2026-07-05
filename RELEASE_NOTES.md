# CalcSheet v1.0.0

## 🎉 First Release!

A minimalist menu bar calculator for macOS — like a sticky note for math.

---

## ✨ Features

### Core Functionality
- **Natural Input** — Type expressions like `128 * 3.5` or `sqrt(144)`, get results as you type
- **Persistent History** — Every calculation stays visible, scroll through your work
- **Always on Top** — Pin the window to keep it above other apps
- **Global Hotkey** — Quick access with customizable keyboard shortcut (default: `⌥⇧C`)

### Calculator Features
- **Basic Operators**: `+` `-` `*` `/` `%` `^`
- **Bitwise Operators**: `<<` `>>` `&` `|` `~`
- **Math Functions**: sqrt, cbrt, abs, ceil, floor, round, exp, log, ln, log2, log10
- **Trigonometric Functions**: sin, cos, tan, asin, acos, atan
- **Hyperbolic Functions**: sinh, cosh, tanh
- **Multi-argument Functions**: max, min, pow, hypot
- **Constants**: pi, e, ln2, ln10, log2e, log10e, sqrt2, sqrt1_2

### Customization
- Adjustable font size
- Theme support (Auto / Dark / Light)
- Optional auto-copy results to clipboard
- Configurable menu bar icon
- Remember window position and state

### User Experience
- **Keyboard First** — Global hotkey to show/hide, `⌘R` to clear, `⌘,` for settings
- **Lightweight** — Lives in the menu bar, no Dock icon
- **i18n Support** — English and Chinese (Simplified)

---

## 📦 Installation

1. Download `CalcSheet-1.0.0.dmg` from below
2. Open the DMG file
3. Drag **CalcSheet.app** to your Applications folder
4. Launch from Applications or Spotlight

> **Note**: This app is not signed with an Apple Developer certificate. If macOS blocks it, right-click the app and select "Open" to run it anyway.

---

## 🛠 Build from Source

```bash
git clone https://github.com/chenwbyx/CalcSheet.git
cd CalcSheet
xcodebuild -project CalcSheet.xcodeproj -scheme CalcSheet -configuration Release build
```

**Requirements**: macOS 15.0+ | Xcode 16.0+

---

## 🐛 Known Issues

- Power operator (`^`) is left-associative (not standard math convention)
- Some constant tests need adjustment (doesn't affect functionality)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

## 📄 License

MIT License © 2026 xiaobo.chen

---

## 🙏 Acknowledgments

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by @sindresorhus — Reliable global hotkey handling

---

**Full Changelog**: https://github.com/chenwbyx/CalcSheet/commits/v1.0.0
