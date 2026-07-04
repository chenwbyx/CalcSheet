//
//  CalculatorState.swift
//  CalcSheet
//
//  Created by xiaobo.chen on 2026/7/3.
//

import Foundation

@Observable
final class CalculatorState {
    var lines: [CalcLine] = [CalcLine()]

    private let evaluator = ExpressionEvaluator()
    private var undoStack: [[CalcLine]] = []

    // MARK: - 求值

    /// 返回 nil 表示：空表达式 或 求值失败（视图层对非空+nil 显示 Error）
    func evaluate(_ expression: String) -> String? {
        evaluator.evaluate(expression)
    }

    // MARK: - 行操作

    func addLine(after index: Int, expression: String = "") -> CalcLine.ID {
        saveUndoState()
        let newLine = CalcLine(expression: expression)
        lines.insert(newLine, at: index + 1)
        return newLine.id
    }

    func deleteLine(at index: Int) -> CalcLine.ID {
        saveUndoState()
        guard lines.count > 1 else {
            lines[0].expression = ""
            return lines[0].id
        }
        lines.remove(at: index)
        return lines[max(0, index - 1)].id
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        lines = previous
    }

    func clearAll() {
        saveUndoState()
        lines = [CalcLine()]
        evaluator.clearCache()
    }

    private func saveUndoState() {
        undoStack.append(lines)
        if undoStack.count > 50 { undoStack.removeFirst() }
    }
}
