//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TaskView<Header: View>: View {
    @Environment(QuestionnaireResponses.self) private var allResponses
    
    let section: Questionnaire.Section
    let task: Questionnaire.Task
    @Binding var response: QuestionnaireResponses.Response
    @ViewBuilder let header: @MainActor () -> Header
    
    var body: some View {
        if allResponses.shouldEnable(task: task) {
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
            switch allResponses.validateResponse(for: task) {
            case .ok:
                EmptyView()
            case .invalid(let message):
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Task:\(task.id)")
    }
    
    @ViewBuilder private var mainContent: some View {
        switch task.kind.variant {
        case .instructional(let text):
            Instructions(text: text)
        case .choice(let config):
            ChoiceAnswering(task: task, config: config, response: $response)
        case .freeText(let config):
            FreeTextEntry(config: config, response: $response.value.stringValue.withDefault(""))
        case .dateTime(let config):
            DatePickerRow(config: config, response: $response.value.dateValue)
        case .numeric(let config):
            NumericInputRow(config: config, response: $response.value.numberValue)
        case .boolean:
            yesNoRows
        case .fileAttachment(let config):
            FileAttachmentQuestionView(config: config, attachments: $response.value.attachmentsValue.withDefault([]))
        case let .custom(questionKind, config):
            questionKind.makeView(for: task, using: config, response: $response).intoAnyView()
        }
    }
    
    @ViewBuilder private var yesNoRows: some View {
        SimpleChoiceRow(option: .init(id: "true", title: "Yes"), isSelected: Binding {
            response.value.boolValue == true
        } set: { isSelected in
            response.value.boolValue = isSelected ? true : nil
        })
        SimpleChoiceRow(option: .init(id: "false", title: "No"), isSelected: Binding {
            response.value.boolValue == false
        } set: { isSelected in
            response.value.boolValue = isSelected ? false : nil
        })
    }
}


extension QuestionKindDefinition {
    @MainActor
    @ViewBuilder
    fileprivate static func makeView(
        for task: Questionnaire.Task,
        using config: any QuestionKindConfig,
        response: Binding<QuestionnaireResponses.Response>
    ) -> some SwiftUI.View {
        if let config = config as? Config {
            self.makeView(for: task, using: config, response: response)
        } else {
            EmptyView()
        }
    }
}


extension View {
    func intoAnyView() -> AnyView {
        AnyView(self)
    }
}
