//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziViews
public import SwiftUI


/// Presents a ``Questionnaire`` for answering.
///
/// Unless externally provided, the sheet implicitly creates and owns a ``QuestionnaireResponses`` instance,
/// which, upon successful completion of the questionnaire, will be made available via the result handler.
///
/// The `QuestionnaireSheet` uses an internal `NavigationStack` to display the questionnaire's content;
/// each section in the input questionnaire is displayed as one page on the stack.
///
/// The following example shows how to present a questionnaire:
/// ```swift
/// struct AnswerQuestionnaire: View {
///     @State var activeQuestionnaire: Questionnaire?
///
///     var body: some View {
///         Button("Answer GAD-7") {
///             activeQuestionnaire = .gad7
///         }
///         .sheet(item: $activeQuestionnaire) { item in
///             QuestionnaireSheet(questionnaire: item) { result in
///                 switch result {
///                 case .completed(let responses):
///                     // ... save the response to your data store
///                 case .cancelled:
///                     break
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct QuestionnaireSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let questionnaire: Questionnaire
    private let completionStepConfig: CompletionStepConfig
    private let resultHandler: @MainActor (Result) async -> Void
    
    @State private var responses: QuestionnaireResponses
    
    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        ManagedNavigationStack {
            if let section = questionnaire.sections.first {
                QuestionnaireSectionView(
                    questionnaire: questionnaire,
                    section: section,
                    completionStepConfig: completionStepConfig
                ) { result in
                    responses.purgeResponsesToDisabledTasks()
                    await resultHandler(result)
                    dismiss()
                }
                .interactiveDismissDisabled()
                .environment(responses)
            } else {
                ContentUnavailableView("Questionnaire is Empty" as String, image: "exclamationmark.triangle")
            }
        }
        .accessibilityIdentifier("SpeziQuestionnaireNavStack")
    }
    
    /// Creates a new `QuestionnaireSheet`
    ///
    /// - parameter questionnaire: The ``Questionnaire`` that should be answered.
    /// - parameter responses: The ``QuestionnaireResponses`` that should be used when answering the questionnaire.
    ///     If set to `nil`, a new, empty object will implicitly be created and used.
    ///     Use this parameter to display or edit existing, previously-collected responses.
    /// - parameter completionStepConfig: Whether the questionnaire sheet should present a completion page once the user has finished the questionnaire.
    /// - parameter resultHandler: A closure that is invoked when the questionnaire is completed, or cancelled by the user.
    ///     The sheet dismisses itself once this closure has returned.
    public init(
        _ questionnaire: Questionnaire,
        responses: QuestionnaireResponses? = nil,
        completionStepConfig: CompletionStepConfig = .enable,
        resultHandler: @escaping @MainActor (Result) async -> Void
    ) {
        self.questionnaire = questionnaire.withConditionsSimplified()
        self.completionStepConfig = completionStepConfig
        self.responses = responses ?? QuestionnaireResponses(questionnaire: questionnaire)
        self.resultHandler = resultHandler
    }
}


extension QuestionnaireSheet {
    /// The result of answering a questionnaire.
    public enum Result {
        /// The user successfully filled out the whole questionnaire.
        case completed(QuestionnaireResponses)
        /// The user cancelled the questionnaire.
        case cancelled
    }
}
