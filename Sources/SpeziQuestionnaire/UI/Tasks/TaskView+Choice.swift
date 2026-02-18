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
    struct ChoiceAnswering: View { // TOOD better name!
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.ChoiceConfig
        @Binding var response: QuestionnaireResponses.Response
        
        var body: some View {
            ForEach(config.options) { option in
                Row(task: task, config: config, option: option, response: $response)
            }
            if config.hasFreeTextOtherOption {
                // TODO
            }
        }
    }
}


extension TaskView.ChoiceAnswering {
    // This needs to be a separate view bc of the sheet presentation
    private struct Row: View {
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.ChoiceConfig
        let option: Questionnaire.Task.Kind.ChoiceConfig.Option
        @Binding var response: QuestionnaireResponses.Response
        @State private var isShowingFollowUpQuestionsSheet = false
        
//        private var responseStorage: QuestionnaireResponses.ChoiceResponse {
//            get {
//                responses[responseFor: task.id].value.choiceValue
//            }
//            nonmutating set {
//                responses[responseFor: task.id].value.choiceValue = newValue
//            }
//        }
        
        var body: some View {
            ChoiceRow(
                title: option.title,
                subtitle: option.subtitle,
                isSelected: response.value.choiceValue.didSelect(option: option)
            ) {
                let oldSelectionState = response.value.choiceValue.didSelect(option: option)
                if !config.allowsMultipleSelection {
                    if oldSelectionState {
                        // was selected before; we're now deselecting
                        response = .init(value: .choice(.init(selectedOptions: [])))
                    } else {
                        // was not selected before; we're now selecting
                        response = .init(value: .choice(.init(selectedOptions: [option])))
                    }
                } else {
                    if oldSelectionState {
                        response.value.choiceValue.deselect(option: option)
                        response.nestedResponses[.choiceOption(option.id)] = nil
                    } else {
                        response.value.choiceValue.select(option: option)
                    }
                }
                if !oldSelectionState, !config.followUpTasks.isEmpty {
                    // the option wasn't selected before, but is now, and also we have some follow up tasks.
                    isShowingFollowUpQuestionsSheet = true
                }
            }
            .sheet(isPresented: $isShowingFollowUpQuestionsSheet) {
                NavigationStack {
                    QuestionnaireSectionView(
                        nestedQuestionsFor: task,
                        sections: [Questionnaire.Section(id: "0", tasks: config.followUpTasks)],
                        responses: $response[nestedResponsesFor: .choiceOption(option.id)]
                    ) { result in
                        switch result {
                        case .success:
                            isShowingFollowUpQuestionsSheet = false
                        case .cancelled:
                            isShowingFollowUpQuestionsSheet = false
                            // we need to un-select the option and clear out the nested responses
                            response.value.choiceValue.deselect(option: option)
                            response.nestedResponses[.choiceOption(option.id)] = nil
                        }
                    }
//                    QuestionnaireSectionView(
//                        questionnaire: <#T##Questionnaire#>,
//                        section: <#T##Questionnaire.Section#>,
//                        resultHandler: <#T##(QuestionnaireSheet.Result) async -> Void#>
//                    )
                }
            }
        }
    }
}
