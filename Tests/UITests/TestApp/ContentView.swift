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

    
    var body: some View {
        VStack {
            Spacer()
            questionnaire
            Spacer()
            timedWalkTest
            Spacer()
        }
    }
    
    @ViewBuilder @MainActor private var questionnaire: some View {
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
    
    @ViewBuilder @MainActor private var timedWalkTest: some View {
        Text("No. of walk tests complete: \(standard.timedWalkTestResponseCount)")
        Button("Display Walk Test") {
            displayWalkTest.toggle()
        }
            .sheet(isPresented: $displayWalkTest) {
                NavigationStack {
                    TimedWalkTestView { result in
                        switch result {
                        case .success:
                            print("Previous walk test was successful")
                            standard.timedWalkTestResponseCount += 1
                        case .failure:
                            print("Previous walk test was unsuccessful")
                        }
                        displayWalkTest = false
                    }
                }
            }
    }
    
    
    func completion(result: Result<TimedWalkTestResult, TimedWalkTestError>) {
        switch result {
        case .success:
            print("Previous walk test was successful")
        case .failure:
            print("Previous walk test was unsuccessful")
        }
    }
}
