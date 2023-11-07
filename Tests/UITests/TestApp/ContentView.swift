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
    @EnvironmentObject var standard: ExampleStandard
    @State var displayQuestionnaire = false
    @State var displayWalkTest = false

    
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
                    isPresented: $displayQuestionnaire,
                    completionStepMessage: "Completed",
                    questionnaireResponse: { response in
                        print(response)
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
                    WalkTestStartView(
                        time: 10,
                        isPresented: $displayWalkTest,
                        completion: completion,
                        description: "Walk Test"
                    )
                }
            }
            Spacer()
        }
    }
    
    func completion(result: Result<WalkTestResponse, WalkTestError>) {
        switch result {
        case .success:
            print("Previous walk test was successful")
        case .failure:
            print("Previous walk test was unsuccessful")
        }
    }
}
