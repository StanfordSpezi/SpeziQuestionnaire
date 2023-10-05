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
public struct FitnessCheckView: View {
    @EnvironmentObject private var fitnessCheckDataSource: FitnessCheckDataSource
    @Binding private var presentationState: PresentationState<ORKFileResult>
    @State private var internalState: PresentationState<ORKResult>

    
    private let identifier: String
    private let intendedUseDescription: String?
    private let walkDuration: TimeInterval
    private let restDuration: TimeInterval

        
    public var body: some View {
        let task = createTask()
        ORKOrderedTaskView(
            tasks: task,
            presentationState: $internalState,
            tintColor: .accentColor
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: presentationState, perform: { newValue in
            _Concurrency.Task { @MainActor in
                switch newValue {
                // TODO: EDIT LOGIC HERE AFTER READING DOCUMENTATION
                case .complete(let result):
                    await fitnessCheckDataSource.add(result)
                default:
                    return
                }
            }
        })
    }
    
    
    /// - Parameters:
    ///   - questionnaire: The  `Questionnaire` that should be displayed.
    ///   - isPresented: Indication from the questionnaire view if should be presented (not "Done" pressed or cancelled).
    ///   - completionStepMessage: Optional completion message that can be appended at the end of the questionnaire.
    ///   - questionnaireResponse: Optional response closure that can be used to manually obtain the `QuestionnaireResponse`.
    public init(
        identifier: String = UUID().uuidString,
        intendedUseDescription: String?,
        walkDuration: TimeInterval = 360,
        restDuration: TimeInterval = 60,
        presentationState: Binding<PresentationState<ORKFileResult>> = .constant(.active),
        internalState: PresentationState<ORKResult> = .active
    ) {
        self.identifier = identifier
        self.intendedUseDescription = intendedUseDescription
        self.walkDuration = walkDuration
        self.restDuration = restDuration
        self._presentationState = presentationState
        self.internalState = internalState
    }
    
    
    /// Creates a ResearchKit navigable task from a questionnaire
    /// - Parameter questionnaire: a questionnaire
    /// - Returns: a ResearchKit ordered task
    private func createTask() -> ORKOrderedTask {
        // Create a navigable task from the Questionnaire
        return ORKOrderedTask.fitnessCheck(
            withIdentifier: identifier,
            intendedUseDescription: intendedUseDescription,
            walkDuration: walkDuration,
            restDuration: restDuration,
            options: ORKPredefinedTaskOption(rawValue: 0)
        )
    }
}


#if DEBUG
struct FitnessCheckView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessCheckView(
            identifier: "",
            intendedUseDescription: "",
            walkDuration: 360,
            restDuration: 5
        )
    }
}
#endif
