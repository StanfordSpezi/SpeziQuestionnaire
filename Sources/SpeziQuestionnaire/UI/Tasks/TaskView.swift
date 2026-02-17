//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TaskView<Header: View>: View {
    @Environment(QuestionnaireResponses.self) private var responses
    
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
            // IDEA: We could add a "Question x of y" thing here, like RK does,
            // but since these question indices would change dynamically based on which questions are currently enabled/disabled,
            // it might not be the best idea.
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
            switch responses.validateResponse(for: task) {
            case .ok:
                EmptyView()
            case .invalid(let message):
                Text(message)
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        switch task.kind {
        case .instructional(let text):
            Text(markdown: text)
        case .choice(let config):
//            makeSCMCRows(for: config.options)
            ChoiceAnswering(task: task, config: config)
        case .freeText(let config):
            textEditor(for: config)
        case .dateTime(let config):
            DatePickerRow(task: task, config: config)
        case .numeric(let config):
            NumericInputRow(task: task, config: config)
        case .boolean:
            SCMCRow(option: .init(id: "0", title: "Yes"), isSelected: Binding {
                responses[responseFor: task.id].boolValue == true
            } set: { isSelected in
                responses[responseFor: task.id].boolValue = isSelected ? true : nil
            })
            SCMCRow(option: .init(id: "1", title: "No"), isSelected: Binding {
                responses[responseFor: task.id].boolValue == false
            } set: { isSelected in
                responses[responseFor: task.id].boolValue = isSelected ? false : nil
            })
        case .fileAttachment(let config):
            FileAttachmentQuestionView(task: task, config: config)
        }
    }
    
//    private func makeSCMCRows(for options: [Questionnaire.Task.Kind.ChoiceConfig.Option]) -> some View {
//        ForEach(options) { option in
//            SCMCRow(option: option, isSelected: Binding<Bool> {
//                responses[task: task, option: option]
//            } set: {
//                responses[task: task, option: option] = $0
//            })
//        }
//    }
    
    private func textEditor(for config: Questionnaire.Task.Kind.FreeTextConfig) -> some View {
        TextEditor(text: Binding<String> {
            responses[responseFor: task.id].stringValue ?? ""
//            responses[freeTextResponseFor: task.id] ?? ""
        } set: { newValue in
//            responses[freeTextResponseFor: task.id] = newValue
            responses[responseFor: task.id].stringValue = newValue
        })
        .frame(minHeight: 100, maxHeight: 372) // starts to scroll once max height is reached
        .textInputAutocapitalization(config.disableAutocomplete ? .never : nil)
        .autocorrectionDisabled(config.disableAutocomplete)
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
