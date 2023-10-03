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
public struct TimedWalkView: View {
    @EnvironmentObject private var questionnaireDataSource: QuestionnaireDataSource
    
    @Binding private var isPresented: Bool
    
    private let identifier: String?
    private let distanceInMeters: Double?
    private let timeLimit: TimeInterval?
    private let turnAroundTimeLimit: TimeInterval?
    private let timedWalkResponse: ((ORKTimedWalkResult) async -> Void)?

        
    public var body: some View {
        if let task = createTask() {
            ORKOrderedTaskView(
                tasks: task,
                isPresented: $isPresented,
                timedWalkResponse: { response in
                    await timedWalkResponse?(response)
                    await questionnaireDataSource.add(response)
                },
                tintColor: .accentColor
            )
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
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
        identifier: String?,
        distanceInMeters: Double?,
        timeLimit: TimeInterval?,
        turnAroundTimeLimit: TimeInterval?,
        isPresented: Binding<Bool> = .constant(true),
        timedWalkResponse: (@MainActor (ORKTimedWalkResult) async -> Void)? = nil
    ) {
        self.identifier = identifier
        self.distanceInMeters = distanceInMeters
        self.timeLimit = timeLimit
        self.turnAroundTimeLimit = turnAroundTimeLimit
        self._isPresented = isPresented
        self.timedWalkResponse = timedWalkResponse
    }
    
    
    /// Creates a ResearchKit navigable task from a questionnaire
    /// - Parameter questionnaire: a questionnaire
    /// - Returns: a ResearchKit ordered task
    private func createTask() -> ORKOrderedTask? {
        // Create a navigable task from the Questionnaire
        do {
            return try timedWalk(withIdentifier: identifier, intendedUseDescription: "", distanceInMeters: distanceInMeters, timeLimit: timeLimit, turnAroundTimeLimit: turnAroundTimeLimit, includeAssistiveDeviceForm: false, options: ORKPredefinedTaskOption(rawValue: 0))
        } catch {
            print("Error creating task: \(error)")
            return nil
        }
    }
}


#if DEBUG
struct TimedWalkView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(questionnaire: Questionnaire.dateTimeExample, isPresented: .constant(false))
    }
}
#endif
