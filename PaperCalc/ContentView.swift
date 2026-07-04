//
//  ContentView.swift
//  PaperCalc
//
//  Created by xiaobo.chen on 2026/7/3.
//

import SwiftUI

struct ContentView: View {
    @State private var state = CalculatorState()
    @FocusState private var focusedLineID: CalcLine.ID?

    private let settings = SettingsStore.shared

    var body: some View {
        @Bindable var state = state
        let fontSize = settings.fontSize
        let editorFont = settings.editorFont

        ZStack {
            // 背景：让 material 延伸到标题栏后面
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(.all, edges: .top)

            VStack(spacing: 0) {
                // 顶栏按钮（固定在滚动区域上方）
                HStack(spacing: 8) {
                    Button(action: togglePin) {
                        Image(systemName: settings.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15))
                            .foregroundStyle(settings.isPinned ? Color.accentColor : .secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .help(settings.isPinned ? "取消固定 (P)" : "固定窗口 (⌘P)")
                    .keyboardShortcut("p", modifiers: .command)

                    Spacer()

                    Button(action: clearAll) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)
                    .help("清空 (⌘R)")
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 8)

                // 滚动区域（完全在按钮下方，不会重叠）
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(state.lines.enumerated()), id: \.element.id) { index, line in
                                CalcLineView(
                                    line: $state.lines[index],
                                    focus: $focusedLineID,
                                    onSubmit:     { handleSubmit(at: index, proxy: proxy) },
                                    onShiftEnter: { handleShiftEnter(at: index, proxy: proxy) },
                                    onMoveUp:     { moveFocus(from: index, delta: -1) },
                                    onMoveDown:   { moveFocus(from: index, delta:  1) },
                                    onDeleteEmpty:{ handleDelete(at: index) },
                                    onCopyResult: { copyResult(at: index) },
                                    onHidePanel:  { NotificationCenter.default.post(name: .hidePanel, object: nil) },
                                    isFocused:    focusedLineID == line.id,
                                    result:       state.evaluate(line.expression),
                                    fontSize:     fontSize,
                                    editorFont:   editorFont
                                )
                                .id(line.id)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                if index < state.lines.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.12))
                                        .frame(height: 0.5)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: focusedLineID) { _, newID in
                        guard let newID else { return }
                        withAnimation(.easeInOut(duration: 0.12)) {
                            proxy.scrollTo(newID, anchor: .center)
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)

            // Cmd+Z 撤销（隐藏按钮）
            Button(action: state.undo) { }
                .keyboardShortcut("z", modifiers: .command)
                .opacity(0)
                .frame(width: 0, height: 0)

            // ⌘, 打开设置（隐藏按钮）
            Button(action: openSettings) { }
                .keyboardShortcut(",", modifiers: .command)
                .opacity(0)
                .frame(width: 0, height: 0)
        }
        .onAppear { focusedLineID = state.lines.last?.id }
    }

    // MARK: - 图钉

    private func togglePin() {
        settings.isPinned.toggle()
        NotificationCenter.default.post(name: .togglePin, object: settings.isPinned)
    }

    // MARK: - Enter 计算 + 结果带入下一行

    private func handleSubmit(at index: Int, proxy: ScrollViewProxy) {
        let expr = state.lines[index].expression.trimmingCharacters(in: .whitespaces)
        guard !expr.isEmpty else { return }

        let result = state.evaluate(expr)
        let newID = state.addLine(after: index, expression: result ?? "")

        if settings.autoCopyResult, let result {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(result, forType: .string)
        }

        DispatchQueue.main.async {
            focusedLineID = newID
            withAnimation(.easeInOut(duration: 0.12)) {
                proxy.scrollTo(newID, anchor: .bottom)
            }
        }
    }

    // MARK: - Shift+Enter 纯换行

    private func handleShiftEnter(at index: Int, proxy: ScrollViewProxy) {
        let expr = state.lines[index].expression.trimmingCharacters(in: .whitespaces)
        guard !expr.isEmpty else { return }

        let newID = state.addLine(after: index, expression: "")
        DispatchQueue.main.async {
            focusedLineID = newID
            withAnimation(.easeInOut(duration: 0.12)) {
                proxy.scrollTo(newID, anchor: .bottom)
            }
        }
    }

    // MARK: - 方向键导航

    private func moveFocus(from index: Int, delta: Int) {
        let target = index + delta
        guard state.lines.indices.contains(target) else { return }
        focusedLineID = state.lines[target].id
    }

    // MARK: - 空行删除

    private func handleDelete(at index: Int) {
        focusedLineID = state.deleteLine(at: index)
    }

    // MARK: - 复制结果

    private func copyResult(at index: Int) {
        if let result = state.evaluate(state.lines[index].expression) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(result, forType: .string)
        }
    }

    // MARK: - 清空

    private func clearAll() {
        state.clearAll()
        focusedLineID = state.lines.first?.id
    }

    // MARK: - 打开设置

    private func openSettings() {
        NotificationCenter.default.post(name: .openSettings, object: nil)
    }
}

// MARK: - 通知

extension Notification.Name {
    static let hidePanel = Notification.Name("hidePanel")
    static let togglePin = Notification.Name("togglePin")
    static let openSettings = Notification.Name("openSettings")
}

#Preview {
    ContentView()
        .frame(width: 580, height: 440)
}
