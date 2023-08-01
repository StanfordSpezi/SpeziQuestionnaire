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


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
//    @EnvironmentObject var standard: ExampleStandard
    @State var displayQuestionnaire = false
    
    
    var body: some Scene {
        WindowGroup {
            VStack {
//                Text("No. of surveys complete \(standard.surveyResponseCount)")
                Button("Display Questionnaire") {
                    displayQuestionnaire.toggle()
                }
                .sheet(isPresented: $displayQuestionnaire) {
                    QuestionnaireView(questionnaire: Questionnaire.gcs)
                }
            }
            .spezi(appDelegate)
        }
    }
}
