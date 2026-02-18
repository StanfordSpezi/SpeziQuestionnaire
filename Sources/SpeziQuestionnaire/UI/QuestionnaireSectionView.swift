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
struct QuestionnaireSectionView<Header: View>: View {
    private enum Context {
        case regular(questionnaire: Questionnaire)
        case answerNestedQuestions(
            parentTask: Questionnaire.Task,
            sections: [Questionnaire.Section]
        )
        
        var allSections: [Questionnaire.Section] {
            switch self {
            case .regular(let questionnaire):
                questionnaire.sections
            case .answerNestedQuestions(parentTask: _, let sections):
                sections
            }
        }
    }
    
    @Environment(ManagedNavigationStack.Path.self) private var navigationPath
    @Environment(QuestionnaireResponses.self) private var responses
    
    private let header: Header
    private let context: Context
    private let section: Questionnaire.Section
    private let resultHandler: @MainActor (QuestionnaireSheet.Result) async -> Void
    
    @State private var indicateMissingResponses = false
    
    var body: some View {
        @Bindable var responses = responses
        ScrollViewReader { scrollViewProxy in
            Form {
                header
                ForEach(section.tasks) { task in
                    TaskView(section: section, task: task, response: $responses.responses[task.id]) {
                        if indicateMissingResponses && responses.isMissingResponse(for: task) {
                            Text("Missing Response")
                                .foregroundStyle(.red)
                        }
                    }
                    .id(task.id)
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
                .tint(!responses.isComplete(in: section) ? .some(.gray.secondary) : .none)
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline) // in case the title is long
        .toolbar {
            toolbarContent
        }
    }
    
    private var title: String? {
        switch context {
        case .regular(let questionnaire):
            questionnaire.metadata.title
        case .answerNestedQuestions:
            nil
        }
    }
    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if responses.isComplete(in: section) && responses.nextSection(after: section, in: context.allSections) == nil {
                // if we're about to complete the questionnaire, we turn this into a Done button
                toolbarDoneButton
            } else {
                CancelButton(context: context) {
                    await resultHandler(.cancelled)
                }
            }
        }
    }
    
    @ViewBuilder private var toolbarDoneButton: some View {
        if #available(iOS 26, *) {
            AsyncButton(role: .confirm) {
                await resultHandler(.completed(responses))
            } label: {
                Text("Submit")
            }
        } else {
            AsyncButton {
                await resultHandler(.completed(responses))
            } label: {
                Label("Submis", systemImage: "checkmark")
            }
            .labelStyle(.iconOnly)
        }
    }
    
    private init(
        context: Context,
        section: Questionnaire.Section,
        resultHandler: @escaping @MainActor (QuestionnaireSheet.Result) async -> Void,
        header: Header
    ) {
        self.context = context
        self.section = section
        self.resultHandler = resultHandler
        self.header = header
    }
    
    init(
        questionnaire: Questionnaire,
        section: Questionnaire.Section,
        resultHandler: @escaping @MainActor (QuestionnaireSheet.Result) async -> Void,
        @ViewBuilder header: @MainActor () -> Header = { EmptyView() }
    ) {
        self.init(
            context: .regular(questionnaire: questionnaire),
            section: section,
            resultHandler: resultHandler,
            header: header()
        )
    }
    
    init(
        nestedQuestionsFor parentTask: Questionnaire.Task,
        sections: [Questionnaire.Section],
        resultHandler: @escaping @MainActor (QuestionnaireSheet.Result) -> Void,
        @ViewBuilder header: @MainActor () -> Header = { EmptyView() }
    ) {
        self.init(
            context: .answerNestedQuestions(parentTask: parentTask, sections: sections),
            section: sections[0],
            resultHandler: resultHandler,
            header: header()
        )
    }
    
    
    private func advance(using scrollViewProxy: ScrollViewProxy) async {
        if let problematicTask = responses.firstTaskPreventingCompletion(of: section) {
            indicateMissingResponses = true
            withAnimation {
                // IDEA can we make it that when the animation is done, we have the section flash in red for a short moment?
                scrollViewProxy.scrollTo(problematicTask.id)
            }
        } else if let nextSection = responses.nextSection(after: section, in: context.allSections) {
            navigationPath.append {
                QuestionnaireSectionView(
                    context: context,
                    section: nextSection,
                    resultHandler: resultHandler,
                    header: header
                )
            }
            indicateMissingResponses = false
        } else {
            // IDEA: have a (cusomizable) "you're done!" confirmation page before dismissing the sheet?
            await resultHandler(.completed(responses))
        }
    }
}


extension QuestionnaireSectionView {
    private struct CancelButton: View {
        let context: Context
        let action: @MainActor () async -> Void
        
        @State private var showConfirmation = false
        
        var body: some View {
            button
                .confirmationDialog(
                    confirmTitle,
                    isPresented: $showConfirmation,
                    titleVisibility: .visible,
                    actions: {
                        AsyncButton("Yes", role: .destructive, action: action)
                        Button("No", role: .cancel) {}
                    },
                    message: {
                        Text(confirmMessage)
                    }
                )
        }
        
        private var confirmTitle: String {
            switch context {
            case .regular:
                "Cancel Questionnaire"
            case .answerNestedQuestions:
                "Discard Nested Responses"
            }
        }
        
        private var confirmMessage: String {
            switch context {
            case .regular:
                "Are you sure you want to cancel the questionnaire?\nYour responses will be lost."
            case .answerNestedQuestions:
                "This will de-select the '' option and " // TODO
            }
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
