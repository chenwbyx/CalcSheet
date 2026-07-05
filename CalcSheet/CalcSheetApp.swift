//
//  CalcSheetApp.swift
//  CalcSheet
//
//  Created by xiaobo.chen on 2026/7/3.
//

import SwiftUI
import KeyboardShortcuts

// MARK: - 全局快捷键名称

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}

@main
struct CalcSheetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .defaultSize(width: 0, height: 0)
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: PinnablePanel!
    private var settingsWindow: NSWindow?

    private let settings = SettingsStore.shared

    func applicationDidFinishLaunching(_ note: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupPanel()
        applyMenuBarIcon()
        setupHotKey()
        observeNotifications()

        // 根据设置决定是否启动时显示窗口
        if settings.showWindowOnLaunch {
            showPanel()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: 窗口

    private func setupPanel() {
        panel = PinnablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 440),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        panel.isReleasedWhenClosed = false
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: ContentView())

        // 窗口因失去焦点自动隐藏时，保存位置
        panel.willAutoHide = { [weak self] in
            self?.savePanelFrame()
        }

        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        // 恢复窗口位置
        if settings.rememberWindowState {
            if let data = UserDefaults.standard.data(forKey: "panelFrame"),
               let frame = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data)?.rectValue {
                panel.setFrame(frame, display: true)
            } else {
                panel.center()
            }
        } else {
            panel.center()
        }
    }

    // MARK: Pin 状态管理（与 NSWindow 生命周期绑定）

    private func applyPinState() {
        panel.applyPinState(settings.isPinned)
    }

    // MARK: 保存窗口状态

    private func savePanelFrame() {
        guard settings.rememberWindowState else { return }
        if let data = try? NSKeyedArchiver.archivedData(
            withRootObject: NSValue(rect: panel.frame),
            requiringSecureCoding: true
        ) {
            UserDefaults.standard.set(data, forKey: "panelFrame")
        }
    }

    // MARK: 菜单栏图标

    private func applyMenuBarIcon() {
        if settings.showMenuBarIcon {
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                if let button = statusItem?.button {
                    button.image = NSImage(systemSymbolName: "plus.forwardslash.minus", accessibilityDescription: "CalcSheet")
                }

                let menu = NSMenu()

                let showHideItem = NSMenuItem(
                    title: NSLocalizedString("menu.toggle", comment: ""),
                    action: #selector(toggleFromMenu),
                    keyEquivalent: ""
                )
                showHideItem.target = self
                menu.addItem(showHideItem)

                menu.addItem(NSMenuItem.separator())

                let settingsItem = NSMenuItem(
                    title: NSLocalizedString("menu.settings", comment: ""),
                    action: #selector(showSettings),
                    keyEquivalent: ","
                )
                settingsItem.target = self
                menu.addItem(settingsItem)

                menu.addItem(NSMenuItem.separator())

                let quitItem = NSMenuItem(
                    title: NSLocalizedString("menu.quit", comment: ""),
                    action: #selector(quitApp),
                    keyEquivalent: "q"
                )
                quitItem.target = self
                menu.addItem(quitItem)

                statusItem?.menu = menu
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }

    @objc private func toggleFromMenu() {
        toggle()
    }

    @objc private func quitApp() {
        savePanelFrame()
        NSApp.terminate(nil)
    }

    @objc private func showSettings() {
        // 打开设置时隐藏计算器面板，避免遮挡
        if panel.isVisible {
            savePanelFrame()
            panel.orderOut(nil)
        }

        // 复用已有窗口，避免重复创建
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = NSLocalizedString("window.settings.title", comment: "")
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView())
        window.makeKeyAndOrderFront(nil)
        settingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: 通知监听

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            forName: .hidePanel,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.hidePanel()
        }
        NotificationCenter.default.addObserver(
            forName: .togglePin,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyPinState()
        }
        NotificationCenter.default.addObserver(
            forName: .toggleMenuBarIcon,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyMenuBarIcon()
        }
        // 快捷键由 KeyboardShortcuts 库处理，无需手动监听
        NotificationCenter.default.addObserver(
            forName: .openSettings,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showSettings()
        }
    }

    // MARK: 快捷键（KeyboardShortcuts 库 — 可靠的全局快捷键方案）

    private func setupHotKey() {
        // 从旧版 Carbon 存储迁移自定义快捷键
        migrateOldHotkeySettings()

        // 设置默认快捷键（如果没有自定义）
        if KeyboardShortcuts.getShortcut(for: .togglePanel) == nil {
            KeyboardShortcuts.setShortcut(
                .init(.c, modifiers: [.option, .shift]),
                for: .togglePanel
            )
        }

        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            self?.toggle()
        }
    }

    /// 将旧版 UserDefaults 中保存的快捷键迁移到 KeyboardShortcuts
    private func migrateOldHotkeySettings() {
        let d = UserDefaults.standard
        guard d.object(forKey: "hotkeyKeyCode") != nil else { return }

        let keyCode = d.integer(forKey: "hotkeyKeyCode")
        let modifiers = d.integer(forKey: "hotkeyModifiers")

        // 写入 KeyboardShortcuts 格式
        let shortcut = KeyboardShortcuts.Shortcut(
            carbonKeyCode: keyCode,
            carbonModifiers: modifiers
        )
        KeyboardShortcuts.setShortcut(shortcut, for: .togglePanel)

        // 清除旧键，避免重复迁移
        d.removeObject(forKey: "hotkeyKeyCode")
        d.removeObject(forKey: "hotkeyModifiers")
    }

    // MARK: 显示/隐藏

    private func toggle() {
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        // 全局快捷键呼出时，先关闭系统设置窗口，避免共存
        closeSystemSettingsWindow()
        // 恢复保存的位置（如果启用）
        if settings.rememberWindowState,
           let data = UserDefaults.standard.data(forKey: "panelFrame"),
           let frame = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data)?.rectValue {
            panel.setFrame(frame, display: true)
        } else {
            panel.center()
        }
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closeSystemSettingsWindow() {
        settingsWindow?.close()
    }

    func hidePanel() {
        savePanelFrame()
        panel.orderOut(nil)
    }
}

// MARK: - 支持 Pin 的 NSPanel 子类

/// 将窗口显示/隐藏逻辑绑定到 NSWindow 生命周期（resignKey），
/// 而非依赖 SwiftUI 状态变量。
/// - Pin=true:  app 失去焦点时也不隐藏，window level 保持 floating
/// - Pin=false: app 失去焦点时自动隐藏，恢复普通 floating panel 行为
private final class PinnablePanel: NSPanel {
    var isPinned = false
    /// 窗口因失去焦点自动隐藏前调用，用于保存窗口位置
    var willAutoHide: (() -> Void)?

    override func resignKey() {
        super.resignKey()
        // 只在「整个 app 失去焦点」时才隐藏；
        // 如果是同 app 内其他窗口（如 Settings）抢了 key window，则保持可见。
        if !isPinned && !NSApp.isActive {
            willAutoHide?()
            orderOut(nil)
        }
    }

    /// Pin 状态切换时同步更新 hidesOnDeactivate 和 window level
    func applyPinState(_ pinned: Bool) {
        isPinned = pinned
        hidesOnDeactivate = !pinned
        level = pinned ? .floating : .floating
    }
}
