//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TaskView<Header: View>: View {
    @Environment(QuestionnaireResponses.self)
    private var responses
    
    let section: Questionnaire.Section
    let task: Questionnaire.Task
    @ViewBuilder let header: @MainActor () -> Header
    
    var body: some View {
        if responses.evaluate(task.enabledCondition) {
            content
        }
    }
    
    private var content: some View {
        Section {
            if !task.title.isEmpty || !task.subtitle.isEmpty {
                VStack(alignment: .leading) {
                    if !task.title.isEmpty {
                        Text(markdown: task.title)
                            .font(.headline)
                    }
                    if !task.subtitle.isEmpty {
                        Text(markdown: task.subtitle)
                            .font(.subheadline)
                    }
                }
            }
            mainContent
        } header: {
            header()
        } footer: {
            if !task.footer.isEmpty {
                Text(markdown: task.footer)
            }
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        switch task.kind {
        case .instructional(let text):
            Text(markdown: text)
        case .singleChoice(let options), .multipleChoice(let options):
            makeSCMCRows(for: options)
        case .freeText:
            TextEditor(text: Binding<String> {
                responses[freeTextResponseAt: [section.id, task.id]] ?? ""
            } set: { newValue in
                responses[freeTextResponseAt: [section.id, task.id]] = newValue
            })
            .frame(minHeight: 100, maxHeight: 372) // starts to scroll once max height is reached
        case .dateTime(let style):
            DateTimeRow(path: [section.id, task.id], style: style)
        }
    }
    
    private func makeSCMCRows(for options: [Questionnaire.Task.SCMCOption]) -> some View {
        ForEach(options) { option in
            SCMCRow(option: option, isSelected: Binding<Bool> {
                responses[section: section, task: task, option: option]
            } set: {
                responses[section: section, task: task, option: option] = $0
            })
        }
    }
}


extension TaskView {
    private struct SCMCRow: View {
        @Environment(\.colorScheme) private var colorScheme
        let option: Questionnaire.Task.SCMCOption
        @Binding var isSelected: Bool
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(markdown: option.title)
                        if !option.subtitle.isEmpty {
                            Text(markdown: option.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(colorScheme.textLabelForegroundStyle)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                }
            }
        }
    }
}


extension TaskView {
    private struct DateTimeRow: View {
        @Environment(\.calendar) private var cal
        @Environment(QuestionnaireResponses.self) private var responses
        let path: ComponentPath
        let style: Questionnaire.Task.Kind.DateTimeStyle
        
        var body: some View {
            let binding = Binding<Date> {
                if let response = responses[dateTimeResponseAt: path] {
                    cal.date(from: response)! // what if this fails?
                } else {
                    .now
                }
            } set: { newValue in
                // TODO there is no way to clear a response here!!
                responses[dateTimeResponseAt: path] = cal.dateComponents(style.components, from: newValue)
            }
            // TOOD make this look good!
            DatePicker("", selection: binding, displayedComponents: { () -> DatePickerComponents in
                switch style {
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
}


extension Questionnaire.Task.Kind.DateTimeStyle {
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


extension ColorScheme {
    var textLabelForegroundStyle: Color {
        self == .dark ? .white : .black
    }
}
