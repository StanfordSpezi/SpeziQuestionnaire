//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import SpeziQuestionnaire
import SwiftUI


struct ContentView: View {
    @Environment(ExampleStandard.self) var standard
    @State var displayQuestionnaire = false
    
    
    var body: some View {
        Text("No. of surveys complete: \(standard.surveyResponseCount)")
        Button("Display Questionnaire") {
            displayQuestionnaire.toggle()
        }
            .sheet(isPresented: $displayQuestionnaire) {
                QuestionnaireView(
                    questionnaire: Questionnaire.gcs,
                    completionStepMessage: "Completed",
                    questionnaireResult: { _ in
                        displayQuestionnaire = false

                        standard.surveyResponseCount += 1
                        try? await Task.sleep(for: .seconds(0.5))
                    }
                )
            }
    }
}
