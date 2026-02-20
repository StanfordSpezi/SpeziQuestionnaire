//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


extension TaskView {
    struct ChoiceAnswering: View { // better name?!!
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.ChoiceConfig
        @Binding var response: QuestionnaireResponses.Response
        
        var body: some View {
            ForEach(config.options) { option in
                Row(task: task, config: config, option: option, response: $response)
            }
            if config.hasFreeTextOtherOption {
                ChoiceRow(
                    id: "openChoice",
                    title: "Other",
                    subtitle: "",
                    isSelected: response.value.choiceValue.didSelectFreeTextOtherOption
                ) {
                    if config.allowsMultipleSelection {
                        response.value.choiceValue.didSelectFreeTextOtherOption.toggle()
                    } else {
                        let oldSelectionState = response.value.choiceValue.didSelectFreeTextOtherOption
                        if oldSelectionState {
                            // we just deselected this option
                            response.value.choiceValue = .init(selectedOptions: [])
                        } else {
                            // we just selected it
                            response.value.choiceValue = .init(selectedOptions: [], freeTextOtherResponse: "")
                        }
                    }
                } accessoryIfSelected: {
                    TextField("", text: $response.value.choiceValue.freeTextOtherResponse.withDefault(""), prompt: Text(verbatim: "…"))
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
}


extension TaskView.ChoiceAnswering {
    // This needs to be a separate view bc of the sheet presentation
    private struct Row: View {
        @Environment(QuestionnaireResponses.self) private var responses
        
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.ChoiceConfig
        let option: Questionnaire.Task.Kind.ChoiceConfig.Option
        @Binding var response: QuestionnaireResponses.Response
        @State private var isShowingFollowUpQuestionsSheet = false
        
        var body: some View {
            ChoiceRow(
                id: option.id,
                title: option.title,
                subtitle: option.subtitle,
                isSelected: response.value.choiceValue.didSelect(option.id)
            ) {
                let oldSelectionState = response.value.choiceValue.didSelect(option.id)
                if !config.allowsMultipleSelection {
                    if oldSelectionState {
                        // was selected before; we're now deselecting
                        response = .init(value: .choice(.init(selectedOptions: [])))
                    } else {
                        // was not selected before; we're now selecting
                        response = .init(value: .choice(.init(selectedOptions: [option.id])))
                    }
                } else {
                    if oldSelectionState {
                        response.value.choiceValue.deselect(option.id)
                        response.nestedResponses[.choiceOption(option.id)] = nil
                    } else {
                        response.value.choiceValue.select(option.id)
                    }
                }
                // we need this bc the condition of the nested task needs to be evaluated in the correct context.
                let innerResponses = responses.view(
                    appending: QuestionnaireResponses.ResponsePath(taskId: task.id).appending(choiceOption: option.id)
                )
                if !oldSelectionState, config.followUpTasks.contains(where: { innerResponses.shouldEnable(task: $0) }) {
                    // the option wasn't selected before, but is now, and also we have some follow up tasks.
                    isShowingFollowUpQuestionsSheet = true
                }
            }
            .sheet(isPresented: $isShowingFollowUpQuestionsSheet) {
                ManagedNavigationStack {
                    QuestionnaireSectionView(
                        nestedQuestionsFor: task,
                        selectedOptionTitle: option.title,
                        sections: [Questionnaire.Section(id: "0", tasks: config.followUpTasks)],
                        completionStepConfig: .disable
                    ) { result in
                        switch result {
                        case .completed:
                            isShowingFollowUpQuestionsSheet = false
                        case .cancelled:
                            isShowingFollowUpQuestionsSheet = false
                            // we need to un-select the option and clear out the nested responses
                            response.value.choiceValue.deselect(option.id)
                            response.nestedResponses[.choiceOption(option.id)] = nil
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Text("Follow-Up")
                                .font(.headline)
                            Text("Please answer the follow-up questions below, for the **'\(option.title)'** option you just selected.")
                                .font(.subheadline)
                        }
                    }
                    .navigationTitle("Follow-Up: \(option.title)")
                }
                .accessibilityIdentifier("SpeziQuestionnaireNavStack")
                .interactiveDismissDisabled()
                .environment(
                    responses.view(
                        appending: QuestionnaireResponses.ResponsePath(taskId: task.id).appending(choiceOption: option.id)
                    )
                )
            }
        }
    }
}
