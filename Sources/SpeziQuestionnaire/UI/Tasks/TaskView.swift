//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

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
                responses[freeTextResponseAt: task.id] ?? ""
            } set: { newValue in
                responses[freeTextResponseAt: task.id] = newValue
            })
            .frame(minHeight: 100, maxHeight: 372) // starts to scroll once max height is reached
        case .dateTime(let config):
            DatePickerRow(task: task, config: config)
        case .numeric(let config):
            NumericInputRow(task: task, config: config)
        case .boolean:
            SCMCRow(option: .init(id: "0", title: "Yes"), isSelected: Binding {
                responses[booleanResponseAt: task.id] == true
            } set: { newValue in
                responses[booleanResponseAt: task.id] = newValue
            })
            SCMCRow(option: .init(id: "1", title: "No"), isSelected: Binding {
                responses[booleanResponseAt: task.id] == false
            } set: { newValue in
                responses[booleanResponseAt: task.id] = !newValue
            })
        case .fileAttachment(let config):
            FileAttachmentQuestionView(task: task, config: config)
        }
    }
    
    private func makeSCMCRows(for options: [Questionnaire.Task.SCMCOption]) -> some View {
        ForEach(options) { option in
            SCMCRow(option: option, isSelected: Binding<Bool> {
                responses[task: task, option: option]
            } set: {
                responses[task: task, option: option] = $0
            })
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


extension ColorScheme {
    var textLabelForegroundStyle: Color {
        self == .dark ? .white : .black
    }
}
