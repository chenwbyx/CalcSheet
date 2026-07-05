//
//  SettingsView.swift
//  CalcSheet
//
//  Created by xiaobo.chen on 2026/7/3.
//

import SwiftUI
import KeyboardShortcuts

// MARK: - Sidebar sections

enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case launch
    case behavior
    case appearance
    case hotkey
    case about

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .launch:     return NSLocalizedString("sidebar.launch", comment: "")
        case .behavior:   return NSLocalizedString("sidebar.behavior", comment: "")
        case .appearance: return NSLocalizedString("sidebar.appearance", comment: "")
        case .hotkey:     return NSLocalizedString("sidebar.hotkey", comment: "")
        case .about:      return NSLocalizedString("sidebar.about", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .launch:     return "power"
        case .behavior:   return "switch.2"
        case .appearance: return "paintbrush"
        case .hotkey:     return "keyboard"
        case .about:      return "info.circle"
        }
    }

    var subtitle: String {
        switch self {
        case .launch:     return NSLocalizedString("sidebar.launch.subtitle", comment: "")
        case .behavior:   return NSLocalizedString("sidebar.behavior.subtitle", comment: "")
        case .appearance: return NSLocalizedString("sidebar.appearance.subtitle", comment: "")
        case .hotkey:     return NSLocalizedString("sidebar.hotkey.subtitle", comment: "")
        case .about:      return NSLocalizedString("sidebar.about.subtitle", comment: "")
        }
    }
}

// MARK: - Main View

struct SettingsView: View {
    @State private var selected: SettingsSection = .launch

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        launchSection
                        behaviorSection
                        appearanceSection
                        hotkeySection
                        aboutSection
                    }
                    .padding(24)
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .onReceive(NotificationCenter.default.publisher(for: .scrollToSettingsSection)) { note in
                    if let section = note.object as? SettingsSection {
                        selected = section
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(section, anchor: .top)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .automatic)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 720, minHeight: 520)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(SettingsSection.allCases, selection: $selected) { section in
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.displayName)
                        .font(.system(size: 13, weight: .medium))
                    Text(section.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            .tag(section)
        }
        .listStyle(.sidebar)
        .padding(.top, 8)
        .onChange(of: selected) { _, newSection in
            NotificationCenter.default.post(
                name: .scrollToSettingsSection,
                object: newSection
            )
        }
    }

    // MARK: - Launch / General

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(NSLocalizedString("section.launch", comment: ""))
            SettingsCard {
                SettingsToggleRow(
                    icon: "power",
                    title: NSLocalizedString("toggle.launchAtLogin.title", comment: ""),
                    subtitle: NSLocalizedString("toggle.launchAtLogin.subtitle", comment: "")
                ) {
                    SettingsStore.shared.launchAtLogin
                } onChange: {
                    SettingsStore.shared.launchAtLogin = $0
                }
                SettingsToggleRow(
                    icon: "menubar.rectangle",
                    title: NSLocalizedString("toggle.showMenuBarIcon.title", comment: ""),
                    subtitle: NSLocalizedString("toggle.showMenuBarIcon.subtitle", comment: "")
                ) {
                    SettingsStore.shared.showMenuBarIcon
                } onChange: { newValue in
                    SettingsStore.shared.showMenuBarIcon = newValue
                    NotificationCenter.default.post(name: .toggleMenuBarIcon, object: newValue)
                }
            }
        }
        .id(SettingsSection.launch)
    }

    // MARK: - Behavior

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(NSLocalizedString("section.behavior", comment: ""))
            SettingsCard {
                SettingsToggleRow(
                    icon: "macwindow",
                    title: NSLocalizedString("toggle.showWindowOnLaunch.title", comment: ""),
                    subtitle: NSLocalizedString("toggle.showWindowOnLaunch.subtitle", comment: "")
                ) {
                    SettingsStore.shared.showWindowOnLaunch
                } onChange: {
                    SettingsStore.shared.showWindowOnLaunch = $0
                }
                SettingsToggleRow(
                    icon: "doc.on.doc",
                    title: NSLocalizedString("toggle.autoCopyResult.title", comment: ""),
                    subtitle: NSLocalizedString("toggle.autoCopyResult.subtitle", comment: "")
                ) {
                    SettingsStore.shared.autoCopyResult
                } onChange: {
                    SettingsStore.shared.autoCopyResult = $0
                }
                SettingsToggleRow(
                    icon: "rectangle.dashed",
                    title: NSLocalizedString("toggle.rememberWindowState.title", comment: ""),
                    subtitle: NSLocalizedString("toggle.rememberWindowState.subtitle", comment: "")
                ) {
                    SettingsStore.shared.rememberWindowState
                } onChange: {
                    SettingsStore.shared.rememberWindowState = $0
                }
            }
        }
        .id(SettingsSection.behavior)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(NSLocalizedString("section.appearance", comment: ""))
            SettingsCard {
                // App Appearance
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "app.badge")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("appearance.app.title", comment: ""))
                                .font(.system(size: 13, weight: .medium))
                            Text(NSLocalizedString("appearance.app.subtitle", comment: ""))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Picker("", selection: Binding(
                        get: { SettingsStore.shared.appearance },
                        set: { SettingsStore.shared.appearance = $0 }
                    )) {
                        ForEach(AppAppearance.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.vertical, 4)

                Divider().padding(.leading, 38)

                // Font Size
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "textformat.size")
                                .font(.system(size: 16))
                                .foregroundStyle(.tint)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("appearance.fontSize.title", comment: ""))
                                    .font(.system(size: 13, weight: .medium))
                                Text(NSLocalizedString("appearance.fontSize.subtitle", comment: ""))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(Int(SettingsStore.shared.fontSize))pt")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                    Slider(
                        value: Binding(
                            get: { SettingsStore.shared.fontSize },
                            set: { SettingsStore.shared.fontSize = $0 }
                        ),
                        in: 14...32,
                        step: 1
                    )
                    HStack {
                        Text(NSLocalizedString("appearance.fontSize.small", comment: "")).font(.system(size: 10)).foregroundStyle(.tertiary)
                        Spacer()
                        Text(NSLocalizedString("appearance.fontSize.default", comment: "")).font(.system(size: 10)).foregroundStyle(.tertiary)
                        Spacer()
                        Text(NSLocalizedString("appearance.fontSize.large", comment: "")).font(.system(size: 10)).foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)

                Divider().padding(.leading, 38)

                // Editor Font
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "textformat")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("appearance.editorFont.title", comment: ""))
                                .font(.system(size: 13, weight: .medium))
                            Text(NSLocalizedString("appearance.editorFont.subtitle", comment: ""))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Picker("", selection: Binding(
                        get: { SettingsStore.shared.editorFont },
                        set: { SettingsStore.shared.editorFont = $0 }
                    )) {
                        Text("SF Mono").tag("SF Mono")
                        Text("Menlo").tag("Menlo")
                        Text("Monaco").tag("Monaco")
                        Text("Courier New").tag("Courier New")
                        Text("Andale Mono").tag("Andale Mono")
                        Text("PT Mono").tag("PT Mono")
                        Text("American Typewriter").tag("American Typewriter")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 170)
                }
                .padding(.vertical, 4)
            }
        }
        .id(SettingsSection.appearance)
    }

    // MARK: - Shortcuts

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(NSLocalizedString("section.hotkey", comment: ""))
            SettingsCard {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "command")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("hotkey.toggle.title", comment: ""))
                                .font(.system(size: 13, weight: .medium))
                            Text(NSLocalizedString("hotkey.toggle.subtitle", comment: ""))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
                .padding(.vertical, 4)
            }
        }
        .id(SettingsSection.hotkey)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(NSLocalizedString("section.about", comment: ""))
            SettingsCard {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("about.version", comment: ""))
                                .font(.system(size: 13, weight: .medium))
                            Text(NSLocalizedString("about.version.value", comment: ""))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        // Check for updates (placeholder)
                    } label: {
                        HStack(spacing: 4) {
                            Text(NSLocalizedString("about.checkUpdate", comment: ""))
                                .font(.system(size: 13))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
        .id(SettingsSection.about)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

// MARK: - Card Container

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: () -> Bool
    let onChange: (Bool) -> Void

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(get: isOn, set: onChange))
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let scrollToSettingsSection = Notification.Name("scrollToSettingsSection")
    static let toggleMenuBarIcon = Notification.Name("toggleMenuBarIcon")
}

#Preview {
    SettingsView()
        .frame(width: 800, height: 560)
}
