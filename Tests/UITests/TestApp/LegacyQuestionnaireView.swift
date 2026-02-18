//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
private import ResearchKit
private import ResearchKitOnFHIR
import ResearchKitSwiftUI
import SwiftUI


/// Present a FHIR `Questionnaire` to the user.
///
/// Note that the ``QuestionnaireView`` does not dismiss itself; the presenting view is responsible for this.
///
/// The following example shows how to present a questionnaire:
/// ```swift
/// struct ExampleQuestionnaireView: View {
///     @State var displayQuestionnaire = false
///
///     var body: some View {
///         Button("Answer Questionnaire") {
///             displayQuestionnaire = true
///         }
///         .sheet(isPresented: $displayQuestionnaire) {
///             QuestionnaireView(questionnaire: Questionnaire.gcs) { result in
///                 switch result {
///                 case .completed(let response):
///                     displayQuestionnaire = false
///                     await upload(response)
///                 case .cancelled, .failed:
///                     // handle somehow
///                     displayQuestionnaire = false
///                 }
///             }
///         }
///     }
/// }
/// ```
struct LegacyQuestionnaireView: View {
    private let questionnaire: ModelsR4.Questionnaire
    private let questionnaireResult: @MainActor (QuestionnaireResult) async -> Void
    private let completionStepMessage: String?
    private let cancelBehavior: CancelBehavior
    
    
    var body: some View {
        if let task = createTask(questionnaire: questionnaire) {
            ORKOrderedTaskView(tasks: task, tintColor: .accentColor, cancelBehavior: cancelBehavior, result: handleResult)
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .interactiveDismissDisabled()
        } else {
            Text("Questionnaire could not be loaded.")
        }
    }
    
    
    /// - Parameters:
    ///   - questionnaire: The  `Questionnaire` that should be displayed.
    ///   - completionStepMessage: Optional completion message that can be appended at the end of the questionnaire.
    ///   - cancelBehavior: The cancel behavior of view. The default setting allows cancellation and asks for confirmation before the view is dismissed.
    ///   - questionnaireResult: Result closure that processes the ``QuestionnaireResult``.
    init(
        questionnaire: ModelsR4.Questionnaire,
        completionStepMessage: String? = nil,
        cancelBehavior: CancelBehavior = .shouldConfirmCancel,
        questionnaireResult: @escaping @MainActor (QuestionnaireResult) async -> Void
    ) {
        self.questionnaire = questionnaire
        self.completionStepMessage = completionStepMessage
        self.cancelBehavior = cancelBehavior
        self.questionnaireResult = questionnaireResult
    }
    
    
    private func handleResult(_ result: TaskResult) async {
        let questionnaireResult: QuestionnaireResult
        switch result {
        case let .completed(result):
            questionnaireResult = .completed(result.fhirResponse)
        case .cancelled:
            questionnaireResult = .cancelled
        case .failed(let error):
            questionnaireResult = .failed(error)
        }
        await self.questionnaireResult(questionnaireResult)
    }

    
    /// Creates a ResearchKit navigable task from a questionnaire
    /// - Parameter questionnaire: a questionnaire
    /// - Returns: a ResearchKit navigable task
    private func createTask(questionnaire: ModelsR4.Questionnaire) -> ORKNavigableOrderedTask? {
        // Create a completion step to add to the end of the Questionnaire (optional)
        var completionStep: ORKCompletionStep?
        if let completionStepMessage {
            completionStep = ORKCompletionStep(identifier: "completion-step")
            completionStep?.text = completionStepMessage
        }
        
        // Create a navigable task from the Questionnaire
        do {
            return try ORKNavigableOrderedTask(questionnaire: questionnaire, completionStep: completionStep)
        } catch {
            print("Failed to create ORK task: \(error)")
            return nil
        }
    }
}


extension LegacyQuestionnaireView {
    /// The result of a questionnaire.
    enum QuestionnaireResult {
        /// The questionnaire was successfully completed with a `QuestionnaireResponse`.
        case completed(ModelsR4.QuestionnaireResponse)
        /// The questionnaire task was cancelled by the user.
        case cancelled
        /// The questionnaire task failed due to an error.
        case failed(_ error: any Error)
    }
}
