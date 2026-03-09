//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SwiftUI


extension TaskView {
    struct NumericInputRow: View {
        let config: Questionnaire.Task.Kind.NumericTaskConfig
        @Binding var response: Double?
        
        var body: some View {
            switch config.inputMode {
            case .numberPad(let numberKind):
                numberPad(numberKind)
            case .slider(let stepValue):
                if let minimum = config.minimum, let maximum = config.maximum {
                    slider(bounds: minimum...maximum, stepValue: stepValue)
                } else {
                    // if we don't have both limits, we fall back to the number-pad-based input
                    numberPad(.decimal)
                }
            }
        }
        
        @ViewBuilder
        private func numberPad(_ numberKind: Questionnaire.Task.Kind.NumericTaskConfig.NumberKind) -> some View {
            NumberTextField(
                "", // ???
                value: $response,
                allowsDecimalEntry: { () -> Bool in
                    switch numberKind {
                    case .integer:
                        false
                    case .decimal:
                        true
                    }
                }()
            )
            .enableDismissalViaKeyboardAccessory()
        }
        
        @ViewBuilder
        private func slider(bounds: ClosedRange<Double>, stepValue: Double) -> some View {
            let binding = Binding<Double> {
                response ?? bounds.contains(0) ? 0 : bounds.lowerBound
            } set: { newValue in
                response = newValue
            }
            VStack {
                Text(binding.wrappedValue, format: .number)
                    .font(.title)
                    .bold()
                    .monospacedDigit()
                Slider(value: binding, in: bounds, step: stepValue) {
                    EmptyView() // doesn't seem to get displayed anyway?
                } minimumValueLabel: {
                    Text(bounds.lowerBound, format: .number)
                } maximumValueLabel: {
                    Text(bounds.upperBound, format: .number)
                }
            }
        }
    }
}


private struct NumberTextField<Value: BinaryFloatingPoint>: View {
    // Note: using a NumberFormatter() instead of the new `FloatingPointFormatStyle<Double>.number` API,
    // because of https://github.com/swiftlang/swift-foundation/issues/135
    @State private var formatter = NumberFormatter()
    
    private let title: String
    private let allowsDecimalEntry: Bool
    @Binding private var value: Value?
    
    var body: some View {
        TextField(title, value: $value, formatter: formatter, prompt: Text(verbatim: "0"))
            .keyboardType(allowsDecimalEntry ? .decimalPad : .numberPad)
    }
    
    init(_ title: String, value: Binding<Value?>, allowsDecimalEntry: Bool) {
        self.title = title
        self._value = value
        self.allowsDecimalEntry = allowsDecimalEntry
    }
}
