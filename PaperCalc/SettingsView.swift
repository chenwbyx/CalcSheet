//
//  SettingsView.swift
//  PaperCalc
//
//  Created by xiaobo.chen on 2026/7/3.
//

import SwiftUI
import KeyboardShortcuts

// MARK: - 侧边栏分类（5 个，与右侧分组一一对应）

enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case launch     = "启动"
    case behavior   = "行为"
    case appearance = "外观"
    case hotkey     = "快捷键"
    case about      = "关于"

    var id: String { rawValue }

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
        case .launch:     return "开机与菜单栏"
        case .behavior:   return "启动与计算行为"
        case .appearance: return "主题、字体与颜色"
        case .hotkey:     return "全局快捷键设置"
        case .about:      return "应用信息与支持"
        }
    }
}

// MARK: - 主视图

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

    // MARK: - 侧边栏

    private var sidebar: some View {
        List(SettingsSection.allCases, selection: $selected) { section in
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.rawValue)
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

    // MARK: - 启动

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("启动")
            SettingsCard {
                SettingsToggleRow(
                    icon: "power",
                    title: "开机时启动",
                    subtitle: "登录系统时自动启动应用"
                ) {
                    SettingsStore.shared.launchAtLogin
                } onChange: {
                    SettingsStore.shared.launchAtLogin = $0
                }
                SettingsToggleRow(
                    icon: "menubar.rectangle",
                    title: "在菜单栏显示图标",
                    subtitle: "在菜单栏中显示应用图标以便快速访问"
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

    // MARK: - 行为

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("行为")
            SettingsCard {
                SettingsToggleRow(
                    icon: "macwindow",
                    title: "启动时显示窗口",
                    subtitle: "应用启动时自动显示主窗口"
                ) {
                    SettingsStore.shared.showWindowOnLaunch
                } onChange: {
                    SettingsStore.shared.showWindowOnLaunch = $0
                }
                SettingsToggleRow(
                    icon: "doc.on.doc",
                    title: "自动复制结果",
                    subtitle: "计算结果自动复制到剪贴板"
                ) {
                    SettingsStore.shared.autoCopyResult
                } onChange: {
                    SettingsStore.shared.autoCopyResult = $0
                }
                SettingsToggleRow(
                    icon: "rectangle.dashed",
                    title: "保留窗口状态",
                    subtitle: "记住窗口大小和位置"
                ) {
                    SettingsStore.shared.rememberWindowState
                } onChange: {
                    SettingsStore.shared.rememberWindowState = $0
                }
            }
        }
        .id(SettingsSection.behavior)
    }

    // MARK: - 外观

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("外观")
            SettingsCard {
                // 应用外观
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "app.badge")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("应用外观")
                                .font(.system(size: 13, weight: .medium))
                            Text("自动跟随系统，也可以固定为深色或浅色")
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
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.vertical, 4)

                Divider().padding(.leading, 38)

                // 字体大小
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "textformat.size")
                                .font(.system(size: 16))
                                .foregroundStyle(.tint)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("字体大小  Aa")
                                    .font(.system(size: 13, weight: .medium))
                                Text("调整编辑器和结果的字体大小")
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
                        Text("小").font(.system(size: 10)).foregroundStyle(.tertiary)
                        Spacer()
                        Text("默认").font(.system(size: 10)).foregroundStyle(.tertiary)
                        Spacer()
                        Text("大").font(.system(size: 10)).foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)

                Divider().padding(.leading, 38)

                // 编辑器字体
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "textformat")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("编辑器字体")
                                .font(.system(size: 13, weight: .medium))
                            Text("选择编辑器使用的字体")
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

    // MARK: - 快捷键

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("快捷键")
            SettingsCard {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "command")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("显示/隐藏窗口")
                                .font(.system(size: 13, weight: .medium))
                            Text("全局快捷键，可在任意应用中呼出")
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

    // MARK: - 关于

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("关于")
            SettingsCard {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("版本")
                                .font(.system(size: 13, weight: .medium))
                            Text("当前版本 1.0.0")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        // 检查更新（预留）
                    } label: {
                        HStack(spacing: 4) {
                            Text("检查更新")
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

    // MARK: - 小组件

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

// MARK: - 卡片容器

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

// MARK: - Toggle 行

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

// MARK: - 通知

extension Notification.Name {
    static let scrollToSettingsSection = Notification.Name("scrollToSettingsSection")
    static let toggleMenuBarIcon = Notification.Name("toggleMenuBarIcon")
}

#Preview {
    SettingsView()
        .frame(width: 800, height: 560)
}
