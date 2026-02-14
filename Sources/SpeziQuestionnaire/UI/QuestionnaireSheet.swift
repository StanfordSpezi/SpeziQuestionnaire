//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import SwiftUI
private import SpeziViews


public struct QuestionnaireSheet: View {
    private let questionnaire: Questionnaire
    private let resultHandler: @MainActor (Result) async -> Void
    
    @State private var navigationPath = ManagedNavigationStack.Path()
    @State private var responses: QuestionnaireResponses
    
    public var body: some View {
        ManagedNavigationStack(path: navigationPath) {
            if let section = questionnaire.sections.first {
                QuestionnaireSectionView(questionnaire: questionnaire, section: section)
            } else {
                // TODO??
                ContentUnavailableView("Questionnaire is Empty" as String, image: "exclamationmark.triangle")
            }
        }
        .environment(responses)
        .interactiveDismissDisabled()
    }
    
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
    public enum Result {
        case success(QuestionnaireResponses)
        case cancelled
    }
}
