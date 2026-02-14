//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziViews
import SwiftUI


/// Displays a section of tasks within a questionnaire, as a single page on the navigation stack.
struct QuestionnaireSectionView: View {
    @Environment(ManagedNavigationStack.Path.self) private var navigationPath
    
    @Environment(QuestionnaireResponses.self) private var responses
    @Environment(\.questionnaireSheetResultHandler) private var resultHandler
    
    @Environment(\.dismiss) private var dismiss
    
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
                AsyncButton {
                    await advance(using: scrollViewProxy)
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
            ToolbarItem(placement: .cancellationAction) {
                CancelButton {
                    await resultHandler?(.cancelled)
                    dismiss()
                }
            }
        }
    }
    
    
    
    private func advance(using scrollViewProxy: ScrollViewProxy) async {
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
            await resultHandler?(.success(responses))
            dismiss()
        }
    }
}


extension QuestionnaireSectionView {
    private struct CancelButton: View {
        @State private var showConfirmation = false
        let onDismiss: @MainActor () async -> Void
        
        var body: some View {
            button
                .confirmationDialog(
                    "Cancel Questionnaire",
                    isPresented: $showConfirmation,
                    titleVisibility: .visible,
                    actions: {
                        AsyncButton("Yes", role: .destructive, action: onDismiss)
                        Button("No", role: .cancel) {}
                    },
                    message: {
                        Text("Are you sure you want to cancel the questionnaire?\nYour responses will be lost.")
                    }
                )
        }
        
        @ViewBuilder private var button: some View {
            if #available(iOS 26, *) {
                Button(role: .cancel) {
                    showConfirmation = true
                }
            } else {
                Button {
                    showConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .accessibilityLabel("Cancel")
                }
            }
        }
    }
}
