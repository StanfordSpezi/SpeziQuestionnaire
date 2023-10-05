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
    @State var presentationState: PresentationState<ORKTaskResult> = .idle

    
    var body: some View {
        Text("No. of surveys complete: \(standard.surveyResponseCount)")
        Button("Display Questionnaire") {
            presentationState = .active
        }
            .sheet(isPresented: $presentationState.presented) {
                QuestionnaireView(
                    questionnaire: Questionnaire.gcs,
                    completionStepMessage: "Completed",
                    presentationState: $presentationState
                )
            }
    }
}
