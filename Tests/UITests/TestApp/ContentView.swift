//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SpeziTimedWalkTest
import SwiftUI


struct ContentView: View {
    @Environment(ExampleStandard.self) var standard
    @State var displayQuestionnaire = false
    @State var displayWalkTest = false

    
    private var timedWalkTest: TimedWalkTest {
        TimedWalkTest(walkTime: 5)
    }
    
    var body: some View {
        VStack {
            Spacer()
            questionnaireView
            Spacer()
            timedWalkTestView
            Spacer()
        }
    }
    
    @ViewBuilder @MainActor private var questionnaireView: some View {
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
    
    @ViewBuilder @MainActor private var timedWalkTestView: some View {
        Text("No. of walk tests complete: \(standard.timedWalkTestResponseCount)")
        Button("Display Walk Test") {
            displayWalkTest.toggle()
        }
            .sheet(isPresented: $displayWalkTest) {
                NavigationStack {
                    TimedWalkTestView(timedWalkTest: timedWalkTest) { result in
                        switch result {
                        case .completed:
                            print("Previous walk test was successful")
                            standard.timedWalkTestResponseCount += 1
                        case .failed:
                            print("Previous walk test was unsuccessful")
                        case .cancelled:
                            print("Previous walk test was cancelled")
                        }
                        displayWalkTest = false
                    }
                }
            }
    }
}
