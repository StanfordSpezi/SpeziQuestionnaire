//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziViews
import SwiftUI


struct QuestionnaireSectionView: View {
    @Environment(ManagedNavigationStack.Path.self)
    private var navigationPath
    
    @Environment(QuestionnaireResponses.self)
    private var responses
    
    let questionnaire: Questionnaire
    let section: Questionnaire.Section
    
    @State private var indicateMissingResponses = false
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            Form {
                ForEach(section.tasks) { task in
                    TaskView(section: section, task: task) {
                        if indicateMissingResponses && responses.isMissingResponse(for: task, in: section) {
                            Text("Missing Response")
                                .foregroundStyle(.red)
                        }
                    }
                    .id(ComponentPath(section.id, task.id))
                }
                Button {
                    advance(using: scrollViewProxy)
                } label: {
                    Text("Continue")
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
                .buttonStyleGlassProminent()
                // if we're missing responses, we keep the button enabled,
                // but tapping it won't proceed to the next section, but rather will scroll to the missing question
                .tint(responses.isMissingResponses(in: section) ? .some(.gray.secondary) : .none)
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle(questionnaire.metadata.title)
        .navigationBarTitleDisplayMode(.inline) // in case the title is long
        .toolbar {
            if #available(iOS 26, *) {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        // TODO show a confirmation alert and somehow propagate the cancellation back to the Sheet!
                    }
                }
//            } else {
//                // TODO fallback!!!
            }
        }
    }
    
    
    private func advance(using scrollViewProxy: ScrollViewProxy) {
        if let missedTask = responses.firstTaskWithMissingResponse(in: section) {
            indicateMissingResponses = true
            withAnimation {
                scrollViewProxy.scrollTo(ComponentPath(section.id, missedTask.id))
            }
        } else if let nextSection = responses.questionnaire.section(after: section) {
            navigationPath.append {
                QuestionnaireSectionView(questionnaire: questionnaire, section: nextSection)
            }
            indicateMissingResponses = false
        } else {
            // is at end. report to Sheet!!!!!!!
        }
    }
}
