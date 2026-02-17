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
        
        var body: some View {
            ForEach(config.options) { option in
                Row(task: task, config: config, option: option)
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
        @Environment(QuestionnaireResponses.self) private var responses
        
        let task: Questionnaire.Task
        let config: Questionnaire.Task.Kind.ChoiceConfig
        let option: Questionnaire.Task.Kind.ChoiceConfig.Option
        @State private var isShowingFollowUpQuestionsSheet = false
        
        private var responseStorage: QuestionnaireResponses.ChoiceResponse {
            get { responses[responseFor: task.id].choiceValue }
            nonmutating set { responses[responseFor: task.id].choiceValue = newValue }
        }
        
        var body: some View {
            ChoiceRow(
                title: option.title,
                subtitle: option.subtitle,
                isSelected: responseStorage.didSelect(option: option)
            ) {
                let oldSelectionState = responseStorage.didSelect(option: option)
                if !config.allowsMultipleSelection {
                    if oldSelectionState {
                        // was selected before; we're now deselecting
                        responseStorage = .init(selectedOptions: [])
                    } else {
                        // was not selected before; we're now selecting
                        responseStorage = .init(selectedOptions: [.init(option: option)])
                    }
                } else {
                    if oldSelectionState {
                        responseStorage.deselect(option: option)
                    } else {
                        responseStorage.select(option: option)
                    }
                }
                if !oldSelectionState, !config.followUpTasks.isEmpty {
                    // the option wasn't selected before, but is now, and also we have some follow up tasks.
                    isShowingFollowUpQuestionsSheet = true
                }
            }
            .sheet(isPresented: $isShowingFollowUpQuestionsSheet) {
                Text(verbatim: "TODO")
            }
        }
    }
}
