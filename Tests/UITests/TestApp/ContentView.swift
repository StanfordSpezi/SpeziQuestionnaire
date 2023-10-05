//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import ResearchKit
import SpeziQuestionnaire
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var standard: ExampleStandard
    @State var questionnairePresentationState: PresentationState<QuestionnaireResponse> = .idle
    @State var fitnessCheckPresentationState: PresentationState<ORKFileResult> = .idle

    
    var body: some View {
        Text("No. of surveys complete: \(standard.surveyResponseCount)")
        Text("No. of fitness checks complete: \(standard.fitnessCheckCount)")
        Button("Display Questionnaire") {
            questionnairePresentationState = .active
        }
        Button("Display Fitness Check") {
            fitnessCheckPresentationState = .active
        }
            .sheet(isPresented: $questionnairePresentationState.presented) {
                QuestionnaireView(
                    questionnaire: Questionnaire.gcs,
                    completionStepMessage: "Completed",
                    presentationState: $questionnairePresentationState
                )
            }
            .sheet(isPresented: $fitnessCheckPresentationState.presented) {
                FitnessCheckView(
                    identifier: "",
                    intendedUseDescription: "6 Minute Walk Test",
                    walkDuration: 10,
                    restDuration: 10,
                    presentationState: $fitnessCheckPresentationState
                )
            }
    }
}
