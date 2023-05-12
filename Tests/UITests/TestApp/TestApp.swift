//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import FHIRQuestionnaires
import SwiftUI


@main
struct UITestsApp: App {
    @State var displayQuestionnaire = false
    
    
    var body: some Scene {
        WindowGroup {
            Button("Display Questionnaire") {
                displayQuestionnaire.toggle()
            }
                .sheet(isPresented: $displayQuestionnaire) {
                    QuestionnaireView(questionnaire: Questionnaire.gcs)
                }
        }
    }
}
