//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DatePickerRow: View {
    @Environment(\.calendar) private var cal
    let config: Questionnaire.Task.Kind.DateTimeConfig
    @Binding var response: DateComponents?
    
    var body: some View {
        let binding = Binding<Date> {
            if let response = response {
                // Q // what if this fails?
                cal.date(from: response)! // swiftlint:disable:this force_unwrapping
            } else {
                .now
            }
        } set: { newValue in
            response = cal.dateComponents(config.style.components, from: newValue)
        }
        DatePicker(label, selection: binding, displayedComponents: components)
            .datePickerStyle(.compact)
    }
    
    private var label: String {
        switch config.style {
        case .dateOnly:
            "Enter Date"
        case .timeOnly:
            "Enter Time"
        case .dateAndTime:
            // Ideally we'd have "Enter Date and Time",
            // but that's too long and will cause the date picker to get displayed below the label :/
            "Enter Date"
        }
    }
    
    private var components: DatePickerComponents {
        switch config.style {
        case .dateOnly:
            .date
        case .timeOnly:
            .hourAndMinute
        case .dateAndTime:
            [.date, .hourAndMinute]
        }
    }
}


extension Questionnaire.Task.Kind.DateTimeConfig.Style {
    var components: Set<Calendar.Component> {
        switch self {
        case .dateOnly:
            [.year, .month, .day]
        case .timeOnly:
            [.hour, .minute, .second]
        case .dateAndTime:
            [.year, .month, .day, .hour, .minute, .second]
        }
    }
}
