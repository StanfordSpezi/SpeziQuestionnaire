//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import ModelsR4
import ResearchKit
import ResearchKitOnFHIR
import SwiftUI


/// Renders a FHIR `Questionnaire`.
public struct QuestionnaireView: View {
    @EnvironmentObject private var questionnaireDataSource: QuestionnaireDataSource
    @Binding private var presentationState: PresentationState<ORKTaskResult>

    private let questionnaire: Questionnaire
    private let completionStepMessage: String?
    
    
    public var body: some View {
        if let task = createTask(questionnaire: questionnaire) {
            ORKOrderedTaskView(
                tasks: task,
                presentationState: $presentationState,
                tintColor: .accentColor
            )
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onChange(of: presentationState, perform: { newValue in
                    _Concurrency.Task { @MainActor in
                        switch newValue {
                        case .complete(let result):
                            let fhirResponse = result.fhirResponse
                            fhirResponse.subject = Reference(reference: FHIRPrimitive(FHIRString("My Patient")))
                            await questionnaireDataSource.add(fhirResponse)
                        default:
                            return
                        }
                    }
                })
        } else {
            Text("QUESTIONNAIRE_LOADING_ERROR_MESSAGE")
        }
    }
    
    
    /// - Parameters:
    ///   - questionnaire: The  `Questionnaire` that should be displayed.
    ///   - isPresented: Indication from the questionnaire view if should be presented (not "Done" pressed or cancelled).
    ///   - completionStepMessage: Optional completion message that can be appended at the end of the questionnaire.
    ///   - questionnaireResponse: Optional response closure that can be used to manually obtain the `QuestionnaireResponse`.
    public init(
        questionnaire: Questionnaire,
        completionStepMessage: String? = nil,
        presentationState: Binding<PresentationState<ORKTaskResult>> = .constant(.active)
    ) {
        self.questionnaire = questionnaire
        self.completionStepMessage = completionStepMessage
        self._presentationState = presentationState
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
            print("Error creating task: \(error)")
            return nil
        }
    }
}


#if DEBUG
struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(questionnaire: Questionnaire.dateTimeExample, presentationState: .constant(.active))
    }
}
#endif
