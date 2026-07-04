//
//  SettingsStore.swift
//  CalcSheet
//
//  Created by xiaobo.chen on 2026/7/3.
//

import Foundation
import SwiftUI
import ServiceManagement

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "自动"
    case dark = "深色"
    case light = "浅色"
    var id: String { rawValue }
}

@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    // MARK: - 启动

    var launchAtLogin: Bool {
        didSet { save(\.launchAtLogin, launchAtLogin); applyLaunchAtLogin() }
    }
    var showMenuBarIcon: Bool {
        didSet { save(\.showMenuBarIcon, showMenuBarIcon) }
    }
    var showWindowOnLaunch: Bool {
        didSet { save(\.showWindowOnLaunch, showWindowOnLaunch) }
    }

    // MARK: - 行为

    var autoCopyResult: Bool {
        didSet { save(\.autoCopyResult, autoCopyResult) }
    }
    var rememberWindowState: Bool {
        didSet { save(\.rememberWindowState, rememberWindowState) }
    }

    // MARK: - 外观

    var appearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "appearance")
            applyAppearance()
        }
    }
    var fontSize: Double {
        didSet { save(\.fontSize, fontSize) }
    }
    var editorFont: String {
        didSet { save(\.editorFont, editorFont) }
    }

    // MARK: - 固定窗口（不持久化，退出即重置）

    var isPinned = false

    // MARK: - Init

    private init() {
        let d = UserDefaults.standard
        launchAtLogin      = d.object(forKey: "launchAtLogin") as? Bool ?? false
        showMenuBarIcon    = d.object(forKey: "showMenuBarIcon") as? Bool ?? true
        showWindowOnLaunch = d.object(forKey: "showWindowOnLaunch") as? Bool ?? false
        autoCopyResult     = d.object(forKey: "autoCopyResult") as? Bool ?? true
        rememberWindowState = d.object(forKey: "rememberWindowState") as? Bool ?? true
        appearance = AppAppearance(rawValue: d.string(forKey: "appearance") ?? "") ?? .system
        fontSize       = d.object(forKey: "fontSize") as? Double ?? 22.0
        editorFont     = d.string(forKey: "editorFont") ?? "SF Mono"
    }

    // MARK: - 持久化

    private func save<T>(_ keyPath: KeyPath<SettingsStore, T>, _ value: T) {
        switch value {
        case let b as Bool:   UserDefaults.standard.set(b, forKey: keyName(keyPath))
        case let s as String: UserDefaults.standard.set(s, forKey: keyName(keyPath))
        case let n as Double: UserDefaults.standard.set(n, forKey: keyName(keyPath))
        case let n as Int:    UserDefaults.standard.set(n, forKey: keyName(keyPath))
        default: break
        }
    }

    private func keyName<T>(_ kp: KeyPath<SettingsStore, T>) -> String {
        switch kp {
        case \.launchAtLogin:      return "launchAtLogin"
        case \.showMenuBarIcon:    return "showMenuBarIcon"
        case \.showWindowOnLaunch: return "showWindowOnLaunch"
        case \.autoCopyResult:     return "autoCopyResult"
        case \.rememberWindowState:return "rememberWindowState"
        case \.appearance:         return "appearance"
        case \.fontSize:           return "fontSize"
        case \.editorFont:         return "editorFont"
        default:                   return ""
        }
    }

    // MARK: - 应用设置

    func applyLaunchAtLogin() {
        guard #available(macOS 13.0, *) else { return }
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("SMAppService error: \(error)")
        }
    }

    func applyAppearance() {
        switch appearance {
        case .system: NSApp.appearance = nil
        case .dark:   NSApp.appearance = NSAppearance(named: .darkAqua)
        case .light:  NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
}
