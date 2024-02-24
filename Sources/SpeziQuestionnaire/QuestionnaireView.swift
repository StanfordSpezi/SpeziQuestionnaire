//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import ModelsR4
import OSLog
import ResearchKit
import ResearchKitOnFHIR
import ResearchKitSwiftUI
import SwiftUI


/// Present a FHIR `Questionnaire` to the user.
///
/// The following example shows how to present a questionnaire:
/// ```swift
/// struct ExampleQuestionnaireView: View {
///     @State var displayQuestionnaire = false
///     
///     
///     var body: some View {
///         Button("Display Questionnaire") {
///             displayQuestionnaire.toggle()
///         }
///             .sheet(isPresented: $displayQuestionnaire) {
///                 QuestionnaireView(
///                     questionnaire: Questionnaire.gcs,
///                     isPresented: $displayQuestionnaire
///                 )
///             }
///     }
/// }
/// ```
public struct QuestionnaireView: View {
    private static let logger = Logger(subsystem: "edu.stanford.spezi.questionnaire", category: "QuestionnaireView")

    private let questionnaire: Questionnaire
    private let questionnaireResult: (QuestionnaireResult) async -> Void
    private let completionStepMessage: String?
    
    
    public var body: some View {
        if let task = createTask(questionnaire: questionnaire) {
            ORKOrderedTaskView(tasks: task, tintColor: .accentColor, result: handleResult)
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .interactiveDismissDisabled()
        } else {
            Text("QUESTIONNAIRE_LOADING_ERROR_MESSAGE")
        }
    }
    
    
    /// - Parameters:
    ///   - questionnaire: The  `Questionnaire` that should be displayed.
    ///   - completionStepMessage: Optional completion message that can be appended at the end of the questionnaire.
    ///   - questionnaireResult: Result closure that processes the ``QuestionnaireResult``.
    public init(
        questionnaire: Questionnaire,
        completionStepMessage: String? = nil,
        questionnaireResult: @escaping @MainActor (QuestionnaireResult) async -> Void
    ) {
        self.questionnaire = questionnaire
        self.completionStepMessage = completionStepMessage
        self.questionnaireResult = questionnaireResult
    }

    private func handleResult(_ result: TaskResult) async {
        let questionnaireResult: QuestionnaireResult
        switch result {
        case let .completed(result):
            let fhirResponse = result.fhirResponse
            questionnaireResult = .completed(result.fhirResponse)
        case .cancelled:
            questionnaireResult = .cancelled
        case .failed:
            questionnaireResult = .failed
        }

        await self.questionnaireResult(questionnaireResult)
    }

    
    /// Creates a ResearchKit navigable task from a questionnaire
    /// - Parameter questionnaire: a questionnaire
    /// - Returns: a ResearchKit navigable task
    private func createTask(questionnaire: Questionnaire) -> ORKNavigableOrderedTask? {
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
            Self.logger.error("Failed to create ORK task: \(error)")
            return nil
        }
    }
}


#if DEBUG
#Preview {
    QuestionnaireView(questionnaire: .dateTimeExample) { response in
        print("Received response \(response)")
    }
}
#endif
