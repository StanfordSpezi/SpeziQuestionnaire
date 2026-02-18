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
public struct QuestionnaireSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let questionnaire: Questionnaire
    private let resultHandler: @MainActor (Result) async -> Void
    
    @State private var responses: QuestionnaireResponses
    
    @_documentation(visibility: internal)
    public var body: some View {
        ManagedNavigationStack {
            if let section = questionnaire.sections.first {
                QuestionnaireSectionView(questionnaire: questionnaire, section: section) { result in
                    await resultHandler(result)
                    dismiss()
                }
            } else {
                ContentUnavailableView("Questionnaire is Empty" as String, image: "exclamationmark.triangle")
            }
        }
        .interactiveDismissDisabled()
        .environment(responses)
    }
    
    /// Creates a new `QuestionnaireSheet`
    ///
    /// - parameter questionnaire: The ``Questionnaire`` that should be answered.
    /// - parameter resultHandler: A closure that is invoked when the questionnaire is completed, or cancelled by the user.
    ///     The sheet dismisses itself once this closure has returned.
    public init(
        _ questionnaire: Questionnaire,
        resultHandler: @escaping @MainActor (Result) async -> Void
    ) {
        self.questionnaire = questionnaire
        self.responses = QuestionnaireResponses(questionnaire: questionnaire)
        self.resultHandler = resultHandler
    }
    
//    private var welcomePage: some View { // ???
//    }
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
