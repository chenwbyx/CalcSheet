<p align="center">
  <img width="160" src="CalcSheet/Assets.xcassets/AppIcon.appiconset/AppIcon.png" alt="CalcSheet">
</p>

<h1 align="center">CalcSheet</h1>

<p align="center">
  A minimalist calculator for macOS that lives in your menu bar — like a sticky note for math.
</p>

<p align="center">
  <a href="https://github.com/chenwbyx/CalcSheet/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/chenwbyx/CalcSheet?style=flat-square"></a>
  <img alt="macOS 15+" src="https://img.shields.io/badge/macOS-15%2B-black?style=flat-square&logo=apple">
  <img alt="Swift 6" src="https://img.shields.io/badge/Swift-6.0-orange?style=flat-square&logo=swift">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square"></a>
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.zh-CN.md">中文</a>
</p>

<p align="center">
  <a href="https://github.com/chenwbyx/CalcSheet/releases">Download</a> ·
  <a href="https://github.com/chenwbyx/CalcSheet/issues">Report Issue</a>
</p>

---

## Features

- **Natural input** — Type expressions like `128 * 3.5` or `sqrt(144)`, get results as you type
- **Persistent history** — Every calculation stays visible, scroll through your work
- **Keyboard first** — Global hotkey to show/hide, `⌘R` to clear, `⌘,` for settings
- **Always on top** — Pin the window to keep it above other apps
- **Lightweight** — Lives in the menu bar, no Dock icon, stays out of your way
- **Customizable** — Adjust font size, theme (auto/dark/light), and more
- **Auto-copy** — Results copied to clipboard automatically (optional)

## Supported Expressions

### Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` `-` `*` `/` | Basic arithmetic | `128 * 3.5` |
| `%` | Modulo | `10 % 3` = 1 |
| `^` | Power | `2 ^ 10` = 1024 |
| `<<` `>>` | Bit shift | `1 << 8` = 256 |
| `&` `\|` | Bitwise AND / OR | `12 & 10` = 8 |
| `~` | Bitwise NOT (unary) | `~0` = -1 |
| `()` | Parentheses | `(1 + 2) * 3` |

### Functions

| Category | Functions |
|----------|-----------|
| Rounding | `abs`, `ceil`, `floor`, `round`, `trunc`, `sign` |
| Roots | `sqrt`, `cbrt` |
| Exponential | `exp`, `log` (ln), `ln`, `log2`, `log10` |
| Trigonometric | `sin`, `cos`, `tan`, `asin`, `acos`, `atan` |
| Hyperbolic | `sinh`, `cosh`, `tanh` |
| Multi-arg | `max`, `min`, `pow`, `hypot` |

### Constants

`pi`, `e`, `ln2`, `ln10`, `log2e`, `log10e`, `sqrt2`, `sqrt1_2`

## Screenshots

<p align="center">
  <img src="assets/screenshot.png" alt="CalcSheet screenshot" width="420">
</p>

## Installation

Download the latest release from [GitHub Releases](https://github.com/chenwbyx/CalcSheet/releases), open the `.dmg`, and drag **CalcSheet** to your Applications folder.

### Build from Source

Requires macOS 15+ and Xcode 16+.

```bash
git clone https://github.com/chenwbyx/CalcSheet.git
cd CalcSheet
xcodebuild -project CalcSheet.xcodeproj -scheme CalcSheet -configuration Release build
```

## Tech Stack

- **Swift** + **SwiftUI**
- macOS 15+
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by @sindresorhus

## License

[MIT](LICENSE) © 2026 xiaobo.chen
