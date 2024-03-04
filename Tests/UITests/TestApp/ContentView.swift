//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SpeziWalkTest
import SwiftUI


struct ContentView: View {
    @Environment(ExampleStandard.self) var standard
    @State var displayQuestionnaire = false
    @State var displayWalkTest = false
    private var walkTime = 10.0
    private var description: String {
        if walkTime < 90.0 {
            """
            This is the Walk Test.
            
            Please find an environment where you can walk straight for \(Int(walkTime)) seconds.
            """
        } else {
            """
            This is the Walk Test.

            Please find an environment where you can walk straight for \(Int(walkTime) / 60) minutes.
            """
        }
    }

    
    var body: some View {
        VStack {
            Spacer()
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
            Spacer()
            Text("No. of walk tests complete: \(standard.walkTestResponseCount)")
            Button("Display Walk Test") {
                displayWalkTest.toggle()
            }
                .sheet(isPresented: $displayWalkTest) {
                    NavigationStack {
                        TimedWalkTestView { result in
                            switch result {
                            case .success:
                                print("Previous walk test was successful")
                            case .failure:
                                print("Previous walk test was unsuccessful")
                            }
                        }
                    }
                }
            Spacer()
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
