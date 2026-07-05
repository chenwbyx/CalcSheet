# CalcSheet

A minimalist calculator for macOS that lives in your menu bar — like a sticky note for math.

Type expressions naturally, see results instantly. Every line stays on screen so you can review your work or copy any result.

## Features

- **Natural input** — Type expressions like `128 * 3.5` or `sqrt(144)`, get results as you type
- **Persistent history** — Every calculation stays visible, scroll through your work
- **Keyboard first** — Global hotkey to show/hide, `⌘R` to clear, `⌘,` for settings
- **Always on top** — Pin the window to keep it above other apps
- **Lightweight** — Lives in the menu bar, no Dock icon, stays out of your way
- **Customizable** — Adjust font size, theme (auto/dark/light), and more
- **Auto-copy** — Results copied to clipboard automatically (optional)

## Screenshots

> TODO: Add screenshots

## Installation

### Build from Source

Requires macOS 15+ and Xcode 16+.

```bash
git clone https://github.com/chenwbyx/CalcSheet.git
cd CalcSheet
xcodebuild -project CalcSheet.xcodeproj -scheme CalcSheet -configuration Release build
```

The built app will be in Xcode's DerivedData directory. You can also open the project in Xcode and run it directly.

### From Releases

> TODO: Upload first release

## Usage

1. **Launch** — CalcSheet appears in your menu bar
2. **Show/Hide** — Click the menu bar icon or use the global hotkey
3. **Calculate** — Type any math expression, results appear automatically
4. **Clear** — Press `⌘R` to clear all history
5. **Pin** — Click the pin icon to keep the window on top
6. **Settings** — Press `⌘,` or choose Settings from the menu bar menu

### Supported Expressions

- Basic arithmetic: `+`, `-`, `*`, `/`
- Parentheses: `(1 + 2) * 3`
- Functions: `sqrt()`, `sin()`, `cos()`, `tan()`, `log()`, `abs()`, etc.
- Constants: `pi`, `e`
- Percentage: `200 * 15%`

## Tech Stack

- **Swift** + **SwiftUI**
- macOS 15+
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by @sindresorhus

## License

MIT License. See [LICENSE](LICENSE) for details.

## Credits

- Icons designed with [Icon Composer](https://developer.apple.com/sf-symbols/) by Apple
- Inspired by the simplicity of sticky notes

---

<p align="center">Made with ❤️ by <a href="https://github.com/chenwbyx">chenwbyx</a></p>
