//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension TaskView {
    struct NumericInputRow: View {
        @Environment(QuestionnaireResponses.self) private var responses
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.NumericTaskConfig
        
        var body: some View {
            switch config.inputMode {
            case .numberPad:
                numberPad()
            case .slider(let stepValue):
                if let minimum = config.minimum, let maximum = config.maximum {
                    slider(bounds: minimum...maximum, stepValue: stepValue)
                } else {
                    // if we don't have both limits, we fall back to the number-pad-based input
                }
            }
        }
        
        @ViewBuilder
        private func numberPad() -> some View {
            @Bindable var responses = responses
            NumberTextField("TODO title", value: $responses[numericResponseAt: task.id])
        }
        
        @ViewBuilder
        private func slider(bounds: ClosedRange<Double>, stepValue: Double) -> some View {
            let binding = Binding<Double> {
                responses[numericResponseAt: task.id] ?? 0
            } set: { newValue in
                responses[numericResponseAt: task.id] = newValue
            }
            // TODO use onEditingChanged to commit the update to the responses? (instead of live-updating it all the time)
            // would that even be needed?
            HStack {
                Slider(value: binding, in: bounds, step: stepValue)
//                Text(binding.wrappedValue, format: .number)
//                    .monospacedDigit()
            }
        }
    }
}


private struct NumberTextField<Value: BinaryFloatingPoint>: View {
    // Note: using a NumberFormatter() instead of the new `FloatingPointFormatStyle<Double>.number` API,
    // because of https://github.com/swiftlang/swift-foundation/issues/135
    private let formatter = NumberFormatter()
    
    private let title: String
    @Binding private var value: Value?
    
    var body: some View {
        TextField(title, value: $value, formatter: formatter, prompt: Text(verbatim: "0"))
//            .keyboardType(allowsDecimalEntry ? .decimalPad : .numberPad) // TODO
    }
    
    init(_ title: String, value: Binding<Value?>) {
        self.title = title
        self._value = value
    }
}
