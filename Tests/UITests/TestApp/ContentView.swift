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
    @EnvironmentObject var standard: ExampleStandard
    @State var surveyResponseCount = 0
    @State var displayQuestionnaire = false
    
    
    var body: some View {
        Text("No. of surveys complete: \(surveyResponseCount)")
            .onReceive(standard.objectWillChange) { _ in
                Task { @MainActor in
                    surveyResponseCount = await standard.surveyResponseCount
                }
            }
        Button("Display Questionnaire") {
            displayQuestionnaire.toggle()
        }
            .sheet(isPresented: $displayQuestionnaire) {
                QuestionnaireView(questionnaire: Questionnaire.gcs)
            }
    }
}
