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
    @Environment(QuestionnaireResponses.self) private var responses
    let task: Questionnaire.Task
    let config: Questionnaire.Task.Kind.DateTimeConfig
    
    var body: some View {
        let binding = Binding<Date> {
            if let response = responses[dateTimeResponseAt: task.id] {
                cal.date(from: response)! // what if this fails?
            } else {
                .now
            }
        } set: { newValue in
            // TODO there is no way to clear a response here!!
            responses[dateTimeResponseAt: task.id] = cal.dateComponents(config.style.components, from: newValue)
        }
        // TOOD make this look good!
        DatePicker("", selection: binding, displayedComponents: { () -> DatePickerComponents in
            switch config.style {
            case .dateOnly:
                .date
            case .timeOnly:
                .hourAndMinute
            case .dateAndTime:
                [.date, .hourAndMinute]
            }
        }())
//            .datePickerStyle(.graphical)
    }
}
