//
//  CalcLineView.swift
//  CalcSheet
//
//  Created by xiaobo.chen on 2026/7/3.
//

import SwiftUI

struct CalcLineView: View {
    @Binding var line: CalcLine
    let focus: FocusState<CalcLine.ID?>.Binding
    let onSubmit: () -> Void
    let onShiftEnter: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDeleteEmpty: () -> Void
    let onCopyResult: () -> Void
    let onHidePanel: () -> Void
    let isFocused: Bool
    let result: String?
    let fontSize: Double
    let editorFont: String

    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $line.expression)
                .textFieldStyle(.plain)
                .font(.custom(editorFont, size: fontSize))
                .focused(focus, equals: line.id)
                .onKeyPress(.return, phases: .down) { press in
                    if press.modifiers.contains(.shift) {
                        onShiftEnter()
                    } else {
                        onSubmit()
                    }
                    return .handled
                }
                .onKeyPress(.upArrow) { onMoveUp(); return .handled }
                .onKeyPress(.downArrow) { onMoveDown(); return .handled }
                .onKeyPress(.delete) {
                    guard line.expression.isEmpty else { return .ignored }
                    onDeleteEmpty()
                    return .handled
                }
                .onKeyPress(.escape) { onHidePanel(); return .handled }
                .onKeyPress("c", phases: .down) { press in
                    guard press.modifiers.contains(.command) else { return .ignored }
                    onCopyResult()
                    return .handled
                }

            Spacer(minLength: 16)

            if let result {
                Text(result)
                    .font(.custom(editorFont, size: fontSize * 0.92))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isFocused ? Color.accentColor.opacity(0.06) : .clear)
        )
    }
}
